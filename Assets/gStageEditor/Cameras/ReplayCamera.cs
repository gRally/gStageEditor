using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class ReplayCamera : MonoBehaviour {

	public bool IsFixed = false;
	public float StartDistance = -1.0f;

    [Space(10), SerializeField]
    public float FocalLength = 50.0f;
    [SerializeField]
    public float Aperture = 1.8f;
    [SerializeField]
    public float SubjectDistance = 10.0f;

    [HideInInspector]
    public float FovX;
    [HideInInspector]
    public float Fov;
    [HideInInspector]
    public float DofNearLimit;
    [HideInInspector]
    public float DofFarLimit;

    void OnDrawGizmos()
    { 
        Gizmos.color = Color.magenta;
        Gizmos.DrawSphere(transform.position, 0.25f);
    }

    void Update()
    {
        calcFov();
        calcDof();
    }

    public void calcFov()
    {
        FovX = fov(FocalLength, 36.0f);
        Fov = fov(FocalLength, 24.0f);
    }

    public void calcDof()
    {
        float F = FocalLength * 0.0393701f;
        float f = Aperture;

        float S = SubjectDistance * 39.3701f;

        float H = (F * F) / (f * 0.001f);

        float DN = (H * S) / (H + (S - F));
        float DF = (H * S) / (H - (S - F));
        float D = DF - DN;

        D = D * 0.0833333f;

        DN = DN * 0.0833333f;

        DF = DF * 0.0833333f;

        //DofDistTotal = D;
        DofNearLimit = DN;
        DofFarLimit = DF;
    }

    float fov(float focalLength, float size)
    {
        var angsize = 2.0f * Mathf.Atan(size / (2.0f * focalLength));
        return (57.3f * angsize);
        //  Simplified calculation would be: return ((57.3 / focallength) * imagesize );
    }

    void OnDrawGizmosSelected()
    {
        if (true)
        {
            float dofNearM = DofNearLimit * 0.3048f;// feet to meters
            float dofFarM = DofFarLimit * 0.3048f; // feet to meters
            float dofFocusM = SubjectDistance;   // feet to meters

            Transform camTransform = this.transform;//TODO _nodalCamera.transform;

            Gizmos.matrix = Matrix4x4.TRS(camTransform.position, camTransform.rotation, camTransform.lossyScale);

            Vector3 toNear = Vector3.forward * dofNearM;
            Vector3 toFar = Vector3.forward * dofFarM;
            Vector3 toFocus = Vector3.forward * dofFocusM;
            Vector3 toNearClip = Vector3.forward * 0.1f; //TODO _nodalCamera.nearClipPlane;
            Vector3 toFarClip = Vector3.forward * 1000.0f;//TODO  _nodalCamera.farClipPlane;

            float ang = Mathf.Tan(Mathf.Deg2Rad * (FovX / 2f));

            float oppNear = ang * dofNearM;
            float oppFar = ang * dofFarM;
            float oppFocus = ang * dofFocusM;
            float oppNearClip = ang * 0.1f;//TODO  _nodalCamera.nearClipPlane;
            float oppFarClip = ang * 1000.0f;//TODO _nodalCamera.farClipPlane;


            Vector3 toNearR = Vector3.right * oppNear;
            Vector3 toFarR = Vector3.right * oppFar;
            Vector3 toFocusR = Vector3.right * oppFocus;
            Vector3 toNearClipR = Vector3.right * oppNearClip;
            Vector3 toFarClipR = Vector3.right * oppFarClip;

            ang = Mathf.Tan(Mathf.Deg2Rad* (Fov / 2f));

            oppNear =   ang* dofNearM;
            oppFar =    ang* dofFarM;
            oppFocus = ang* dofFocusM;
            oppNearClip = ang* 0.1f;//TODO  _nodalCamera.nearClipPlane;
            oppFarClip = ang* 1000.0f;//TODO  _nodalCamera.farClipPlane;

            Vector3 toNearT = Vector3.up * oppNear;
            Vector3 toFarT = Vector3.up * oppFar;
            Vector3 toFocusT = Vector3.up * oppFocus;
            Vector3 toNearClipT = Vector3.up * oppNearClip;
            Vector3 toFarClipT = Vector3.up * oppFarClip;

            // Calculate all the points (L = Left, R = Right, T = top, B = bottom)
            Vector3 nearLB = toNear - toNearR - toNearT;
            Vector3 nearLT = toNear - toNearR + toNearT;
            Vector3 nearRB = toNear + toNearR - toNearT;
            Vector3 nearRT = toNear + toNearR + toNearT;
            Vector3 focusLB = toFocus - toFocusR - toFocusT;
            Vector3 focusLT = toFocus - toFocusR + toFocusT;
            Vector3 focusRB = toFocus + toFocusR - toFocusT;
            Vector3 focusRT = toFocus + toFocusR + toFocusT;
            Vector3 farLB = toFar - toFarR - toFarT;
            Vector3 farLT = toFar - toFarR + toFarT;
            Vector3 farRB = toFar + toFarR - toFarT;
            Vector3 farRT = toFar + toFarR + toFarT;
            Vector3 nearCLB = toNearClip - toNearClipR - toNearClipT;
            Vector3 nearCLT = toNearClip - toNearClipR + toNearClipT;
            Vector3 nearCRB = toNearClip + toNearClipR - toNearClipT;
            Vector3 nearCRT = toNearClip + toNearClipR + toNearClipT;
            Vector3 farCLB = toFarClip - toFarClipR - toFarClipT;
            Vector3 farCLT = toFarClip - toFarClipR + toFarClipT;
            Vector3 farCRB = toFarClip + toFarClipR - toFarClipT;
            Vector3 farCRT = toFarClip + toFarClipR + toFarClipT;

            Gizmos.color = Color.white;

            // far clip rectangle
            Gizmos.DrawLine(farCLB, farCRB);
            Gizmos.DrawLine(farCLT, farCRT);
            Gizmos.DrawLine(farCLB, farCLT);
            Gizmos.DrawLine(farCRB, farCRT);

            // camera frustum
            Gizmos.DrawLine(nearCLB, farCLB);
            Gizmos.DrawLine(nearCRB, farCRB);
            Gizmos.DrawLine(nearCLT, farCLT);
            Gizmos.DrawLine(nearCRT, farCRT);

            // near rectangle
            Gizmos.color = Color.cyan;
            Gizmos.DrawLine(nearLB, nearRB);
            Gizmos.DrawLine(nearLB, nearLT);
            Gizmos.DrawLine(nearLT, nearRT);
            Gizmos.DrawLine(nearRB, nearRT);

            if (DofFarLimit >= 0)
            {
                // far rectangle
                Gizmos.DrawLine(farLB, farRB);
                Gizmos.DrawLine(farLT, farRT);
                Gizmos.DrawLine(farLB, farLT);
                Gizmos.DrawLine(farRB, farRT);

                // dof frustum
                Gizmos.DrawLine(nearLB, farLB);
                Gizmos.DrawLine(nearRB, farRB);
                Gizmos.DrawLine(nearLT, farLT);
                Gizmos.DrawLine(nearRT, farRT);
            }

            // focus rectangle
            Gizmos.color = Color.yellow;
            Gizmos.DrawLine(focusLB, focusLT);
            Gizmos.DrawLine(focusLB, focusRB);
            Gizmos.DrawLine(focusRB, focusRT);
            Gizmos.DrawLine(focusLT, focusRT);

            Gizmos.DrawLine(Vector3.zero, toFocus);
        }
    }
}


