using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class StartFinish : MonoBehaviour
{
    [Header("Start")]
	public float StartDistance = 100.0f;
    public float StartCarRelative = -100.0f;
	public float StartCo0Relative = -25.0f;
	public float StartCo1Relative = -50.0f;
	public float StartEndRelative = 25.0f;

    [Header("Splits")]
    public float Split1Distance = 200.0f;
    public float Split2Distance = 500.0f;
    public float Split3Distance = 800.0f;

    [Header("Finish")]
    public float FinishDistance = 1000.0f;
	public float FinishCo0Relative = -100.0f;
	public float FinishStopRelative = 200.0f;
	public float FinishEndRelative = 25.0f;

    float oldStartCarRelative = 0.0f;
    float oldStartDistance = 0.0f;
	float oldStartCo0Relative = 0.0f;
	float oldStartCo1Relative = 0.0f;
	float oldStartEndRelative = 0.0f;

    float oldSplit1Distance = 0.0f;
    float oldSplit2Distance = 0.0f;
    float oldSplit3Distance = 0.0f;

    float oldFinishDistance = 0.0f;
	float oldFinishCo0Relative = 0.0f;
	float oldFinishStopRelative = 0.0f;
	float oldFinishEndRelative = 0.0f; 

    [ShowOnly, Header("Data Calculated")]
    public float RealLength;

	LayoutPath layout = null;
    [Header("Signals")]
    public float SignalDistanceFromCenter = 2.5f;
    
    //[ShowOnly, Tooltip("Points 3d"), Header("Spline Points")]
    [HideInInspector]
	public List<Vector3> Points = new List<Vector3>();

	public bool UpdatePoints()
	{
		if (somethingIsChanged())
		{
			try 
			{
				if (layout == null)
				{
					layout = transform.GetComponent<LayoutPath>();					
				}
				
				Points.Clear();
                layout.GetPositionOnPath(StartDistance + StartCarRelative);
                Points.Add(layout.PosOnPath);

                layout.GetPositionOnPath(StartDistance + StartCo1Relative + StartCo0Relative);
				Points.Add(layout.PosOnPath);
				layout.GetPositionOnPath(StartDistance + StartCo1Relative);
				Points.Add(layout.PosOnPath);
				layout.GetPositionOnPath(StartDistance);
				Points.Add(layout.PosOnPath);
				layout.GetPositionOnPath(StartDistance + StartEndRelative);
				Points.Add(layout.PosOnPath);

                layout.GetPositionOnPath(Split1Distance);
                Points.Add(layout.PosOnPath);
                layout.GetPositionOnPath(Split2Distance);
                Points.Add(layout.PosOnPath);
                layout.GetPositionOnPath(Split3Distance);
                Points.Add(layout.PosOnPath);
                
                layout.GetPositionOnPath(FinishDistance + FinishCo0Relative);
				Points.Add(layout.PosOnPath);
				layout.GetPositionOnPath(FinishDistance);
				Points.Add(layout.PosOnPath);
				layout.GetPositionOnPath(FinishDistance + FinishStopRelative);
				Points.Add(layout.PosOnPath);
				layout.GetPositionOnPath(FinishDistance + FinishStopRelative + FinishEndRelative);
				Points.Add(layout.PosOnPath);				
			} 
			catch (System.Exception ex)
			{
				Debug.LogError(ex.ToString());
				return false;
			}
		}
		return true;
	}

    public void CalculateSplits()
    {
        var realDist = FinishDistance - StartDistance;
        var distSplits = realDist / 4.0f;
        Split1Distance = StartDistance + (distSplits * 1.0f);
        Split2Distance = StartDistance + (distSplits * 2.0f);
        Split3Distance = StartDistance + (distSplits * 3.0f);
    }

	public void PlaceSignals()
	{
		if (layout == null)
		{
			return;
		}

        addCollider();

		// Start -----------
		// Co0
		layout.GetPositionOnPath(StartDistance + StartCo1Relative + StartCo0Relative);
		Vector3 pos = layout.PosOnPath;

		Vector3 p0 = layout.GetPointPrec();
		Vector3 p1 = layout.GetPointNext();

		Vector3 dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
		createSign ("SIGN_START_00", pos + (dot * SignalDistanceFromCenter), p0, p1);
		createSign ("SIGN_START_00", pos - (dot * SignalDistanceFromCenter), p0, p1);

		// Co1
		layout.GetPositionOnPath(StartDistance + StartCo1Relative);
		pos = layout.PosOnPath;
		
		p0 = layout.GetPointPrec();
		p1 = layout.GetPointNext();
		
		dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
		createSign ("SIGN_START_01", pos + (dot * SignalDistanceFromCenter), p0, p1);
		createSign ("SIGN_START_01", pos - (dot * SignalDistanceFromCenter), p0, p1);

		// start
		layout.GetPositionOnPath(StartDistance);
		pos = layout.PosOnPath;
		
		p0 = layout.GetPointPrec();
		p1 = layout.GetPointNext();
		
		dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
		createSign ("SIGN_START_02", pos + (dot * SignalDistanceFromCenter), p0, p1);
		createSign ("SIGN_START_02", pos - (dot * SignalDistanceFromCenter), p0, p1);

		// end
		layout.GetPositionOnPath(StartDistance + StartEndRelative);
		pos = layout.PosOnPath;
		
		p0 = layout.GetPointPrec();
		p1 = layout.GetPointNext();
		
		dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
		createSign ("SIGN_FREE", pos + (dot * SignalDistanceFromCenter), p0, p1);
		createSign ("SIGN_FREE", pos - (dot * SignalDistanceFromCenter), p0, p1);

        // split 1
        layout.GetPositionOnPath(Split1Distance);
        pos = layout.PosOnPath;

        p0 = layout.GetPointPrec();
        p1 = layout.GetPointNext();

        dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
        createSign("SIGN_SPLIT_01", pos + (dot * SignalDistanceFromCenter), p0, p1);
        createSign("SIGN_SPLIT_01", pos - (dot * SignalDistanceFromCenter), p0, p1);

        // split 2
        layout.GetPositionOnPath(Split2Distance);
        pos = layout.PosOnPath;

        p0 = layout.GetPointPrec();
        p1 = layout.GetPointNext();

        dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
        createSign("SIGN_SPLIT_02", pos + (dot * SignalDistanceFromCenter), p0, p1);
        createSign("SIGN_SPLIT_02", pos - (dot * SignalDistanceFromCenter), p0, p1);

        // split 3
        layout.GetPositionOnPath(Split3Distance);
        pos = layout.PosOnPath;

        p0 = layout.GetPointPrec();
        p1 = layout.GetPointNext();

        dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
        createSign("SIGN_SPLIT_03", pos + (dot * SignalDistanceFromCenter), p0, p1);
        createSign("SIGN_SPLIT_03", pos - (dot * SignalDistanceFromCenter), p0, p1);

        // finish
        // Co0
        layout.GetPositionOnPath(FinishDistance + FinishCo0Relative);
		pos = layout.PosOnPath;
		
		p0 = layout.GetPointPrec();
		p1 = layout.GetPointNext();
		
		dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
		createSign ("SIGN_END_00", pos + (dot * SignalDistanceFromCenter), p0, p1);
		createSign ("SIGN_END_00", pos - (dot * SignalDistanceFromCenter), p0, p1);

		// finish
		layout.GetPositionOnPath(FinishDistance);
		pos = layout.PosOnPath;
		
		p0 = layout.GetPointPrec();
		p1 = layout.GetPointNext();
		
		dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
		createSign ("SIGN_END_01", pos + (dot * SignalDistanceFromCenter), p0, p1);
		createSign ("SIGN_END_01", pos - (dot * SignalDistanceFromCenter), p0, p1);

		// stop
		layout.GetPositionOnPath(FinishDistance + FinishStopRelative);
		pos = layout.PosOnPath;
		
		p0 = layout.GetPointPrec();
		p1 = layout.GetPointNext();
		
		dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
		createSign ("SIGN_END_02", pos + (dot * SignalDistanceFromCenter), p0, p1);
		createSign ("SIGN_END_02", pos - (dot * SignalDistanceFromCenter), p0, p1);

		// end
		layout.GetPositionOnPath(FinishDistance + FinishStopRelative + FinishEndRelative);
		pos = layout.PosOnPath;
		
		p0 = layout.GetPointPrec();
		p1 = layout.GetPointNext();
		
		dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
		createSign ("SIGN_FREE", pos + (dot * SignalDistanceFromCenter), p0, p1);
		createSign ("SIGN_FREE", pos - (dot * SignalDistanceFromCenter), p0, p1);

        removeCollider();
	}

    /// <summary>
    /// clean the signs
    /// </summary>
    public void CleanSigns()
    {
        for (int i = 0; i < transform.childCount; i++)
        {
            var element = transform.GetChild(i);
            if (element.name.ToLower().StartsWith("sign_start") ||
                element.name.ToLower().StartsWith("sign_split") ||
                element.name.ToLower().StartsWith("sign_end") ||
                element.name.ToLower().StartsWith("sign_free"))
            {
                DestroyImmediate(element.gameObject);
            }
        }
        for (int i = 0; i < transform.childCount; i++)
        {
            var element = transform.GetChild(i);
            if (element.name.ToLower().StartsWith("sign_start") ||
                element.name.ToLower().StartsWith("sign_split") ||
                element.name.ToLower().StartsWith("sign_end") ||
                element.name.ToLower().StartsWith("sign_free"))
            {
                CleanSigns();
                break;
            }
        }

    }

    private void createSign(string signName, Vector3 pos, Vector3 p0, Vector3 p1, float raise = 5.00f)
	{
#if UNITY_EDITOR
        pos.y = pos.y + raise;
        string path = "Assets/gStageEditor/Resources/" + signName + ".prefab";
        GameObject anchor_point = UnityEditor.AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;
        GameObject prefab_instance = Instantiate(anchor_point) as GameObject;
        prefab_instance.transform.position = pos;
        prefab_instance.transform.rotation = Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0);
        prefab_instance.transform.SetParent(transform);
        prefab_instance.name = signName;

        applyDistance(prefab_instance);
#endif
    }

	bool somethingIsChanged()
	{
		bool isChanged = StartCarRelative != oldStartCarRelative ||
            StartDistance != oldStartDistance ||
			StartCo0Relative != oldStartCo0Relative ||
			StartCo1Relative != oldStartCo1Relative ||
			StartEndRelative != oldStartEndRelative ||

            Split1Distance != oldSplit1Distance ||
            Split2Distance != oldSplit2Distance ||
            Split3Distance != oldSplit3Distance ||

            FinishDistance != oldFinishDistance ||
			FinishCo0Relative != oldFinishCo0Relative ||
			FinishStopRelative != oldFinishStopRelative ||
			FinishEndRelative != oldFinishEndRelative;

		oldStartDistance = StartDistance;
		oldStartCo0Relative = StartCo0Relative;
		oldStartCo1Relative = StartCo1Relative;
		oldStartEndRelative = StartEndRelative;

        oldSplit1Distance = Split1Distance;
        oldSplit2Distance = Split2Distance;
        oldSplit3Distance = Split3Distance;

        oldFinishDistance = FinishDistance;
		oldFinishCo0Relative = FinishCo0Relative;
		oldFinishStopRelative = FinishStopRelative;
		oldFinishEndRelative = FinishEndRelative;

		return isChanged;
	}

    void applyDistance(GameObject obj, float offset = 0.08f) // 0.06 on plane is ok
    {
        var mesh = obj.GetComponent<MeshFilter>().sharedMesh;
        var matrix = obj.transform.localToWorldMatrix;

        RaycastHit hit;

        var point = matrix.MultiplyPoint(mesh.bounds.min);
        var raHit = Physics.Raycast(point, Vector3.down, out hit);
        if (raHit)
        {
            obj.transform.position = obj.transform.position - new Vector3(0.0f, hit.distance - offset, 0.0f);
        }
    }

    void addCollider()
    {
        int layerIndex = LayerMask.NameToLayer("COLLISION");
        var collisions = Resources.FindObjectsOfTypeAll(typeof(GameObject));
        foreach (GameObject col in collisions)
        {
            if (col.layer == layerIndex)
            {
                col.AddComponent<MeshCollider>();
            }
        }
    }

    void removeCollider()
    {
        int layerIndex = LayerMask.NameToLayer("COLLISION");
        var collisions = Resources.FindObjectsOfTypeAll(typeof(GameObject));
        foreach (GameObject col in collisions)
        {
            if (col.layer == layerIndex)
            {
                DestroyImmediate(col.GetComponent<MeshCollider>());
            }
        }
    }
}
