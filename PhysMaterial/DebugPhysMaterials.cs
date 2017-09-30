using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class DebugPhysMaterials : MonoBehaviour
{
    [Range(0.0f, 2.0f)]
    public float Wet;
    private float _wet;

    [Range(0.0f, 1.0f)]
    public float Groove;
    private float _groove;

    [Range(0.0f, 1.0f)]
    public float PhysDebug;
    private float _physDebug;

	void Update ()
    {
        if (_wet != Wet)
        {
            Shader.SetGlobalFloat("_GR_WetSurf", Wet);
            _wet = Wet;
        }

        if (_groove != Groove)
        {
            Shader.SetGlobalFloat("_GR_Groove", Groove);
            _groove = Groove;
        }

        if (_physDebug != PhysDebug)
        {
            Shader.SetGlobalFloat("_GR_PhysDebug", PhysDebug);
            _physDebug = PhysDebug;
        }
    }
}
