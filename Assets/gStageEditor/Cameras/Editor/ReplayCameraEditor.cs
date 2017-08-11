using UnityEngine;
using System.Collections;
using UnityEditor;

[CustomEditor(typeof(ReplayCamera))]
public class ReplayCameraEditor : Editor
{
    private ReplayCamera replayCamera;
    //private Transform handleTransform;
    //private Quaternion handleRotation;
    //private int selectedIndex = -1;
    private const float handleSize = 0.06f;
    private const float pickSize = 0.08f;

    private void OnSceneGUI()
    {

    }

    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();
        EditorGUILayout.Space();

        var replayCamera = target as ReplayCamera;
        if (replayCamera != null)
        {
            float dn = replayCamera.DofNearLimit * 0.3048f;
            float df = replayCamera.DofFarLimit * 0.3048f;
            EditorGUILayout.LabelField("Near Limit", string.Format("{0:0.00}m", dn));
            string farLimit = replayCamera.DofFarLimit >= 0 ? string.Format("{0:0.00}m",df) : "INF";
            EditorGUILayout.LabelField("Far Limit", farLimit);
            EditorGUILayout.LabelField("Fov", string.Format("{0:0.0}°", replayCamera.Fov));
        }
    }
}
