using UnityEngine;
using System.Collections;
using UnityEditor;
using UnityEditor.SceneManagement;

[CustomEditor(typeof(StartFinish))]
public class StartFinishEditor : Editor
{
	private StartFinish startFinish;
	private Transform handleTransform;
	private Quaternion handleRotation;

	private const float handleSize = 0.06f;
	private const float pickSize = 0.08f;

	private void OnSceneGUI ()
	{
		startFinish = target as StartFinish;
		
		handleTransform = startFinish.transform;
		handleRotation = Tools.pivotRotation == PivotRotation.Local ? handleTransform.rotation : Quaternion.identity;

		showPoints ();

		if (GUI.changed)
		{
			EditorUtility.SetDirty(startFinish); 
		}
	}

	private void showPoints()
	{
		if (!startFinish.UpdatePoints())
		{
			return;
		}
		if (startFinish.Points.Count == 0)
		{
			return;
		}

        Vector3 pointC = startFinish.Points[0];//handleTransform.TransformPoint(startFinish.Points [0]);

        Vector3 point0 = startFinish.Points[1];//handleTransform.TransformPoint(startFinish.Points [0]);
		Vector3 point1 = startFinish.Points[2];//handleTransform.TransformPoint(startFinish.Points [1]);
		Vector3 point2 = startFinish.Points[3];//handleTransform.TransformPoint(startFinish.Points [2]);
		Vector3 point3 = startFinish.Points[4];//handleTransform.TransformPoint(startFinish.Points [3]);

        Vector3 point4 = startFinish.Points[5];
        Vector3 point5 = startFinish.Points[6];
        Vector3 point6 = startFinish.Points[7];

        Vector3 point7 = startFinish.Points[8];//handleTransform.TransformPoint(startFinish.Points [4]);
		Vector3 point8 = startFinish.Points[9];//handleTransform.TransformPoint(startFinish.Points [5]);
		Vector3 point9 = startFinish.Points[10];//handleTransform.TransformPoint(startFinish.Points [6]);
		Vector3 point10 = startFinish.Points[11];//handleTransform.TransformPoint(startFinish.Points [7]);


        float size = HandleUtility.GetHandleSize(pointC);
        Handles.color = Color.white;
        Handles.Button(pointC, handleRotation, size * handleSize * 3.0f, size * pickSize, Handles.DotCap);

        size = HandleUtility.GetHandleSize (point0);
		Handles.color = Color.yellow;
		Handles.Button (point0, handleRotation, size * handleSize, size * pickSize, Handles.DotCap);
		
		Handles.color = Color.red;
		size = HandleUtility.GetHandleSize (point1);
		Handles.Button (point1, handleRotation, size * handleSize, size * pickSize, Handles.DotCap);
		
		Handles.color = Color.red;
		size = HandleUtility.GetHandleSize (point2);
		Handles.Button (point2, handleRotation, size * handleSize * 2.0f, size * pickSize * 2.0f, Handles.DotCap);
		
		Handles.color = new Color (0.835f, 0.671f, 0.482f);
		size = HandleUtility.GetHandleSize (point3);
		Handles.Button (point3, handleRotation, size * handleSize, size * pickSize, Handles.DotCap);


        Handles.color = Color.blue;
        size = HandleUtility.GetHandleSize(point4);
        Handles.Button(point4, handleRotation, size * handleSize, size * pickSize, Handles.DotCap);

        Handles.color = Color.blue;
        size = HandleUtility.GetHandleSize(point5);
        Handles.Button(point5, handleRotation, size * handleSize, size * pickSize, Handles.DotCap);

        Handles.color = Color.blue;
        size = HandleUtility.GetHandleSize(point6);
        Handles.Button(point6, handleRotation, size * handleSize, size * pickSize, Handles.DotCap);


        Handles.color = Color.yellow;
		size = HandleUtility.GetHandleSize (point7);
		Handles.Button (point7, handleRotation, size * handleSize, size * pickSize, Handles.DotCap);

		Handles.color = Color.red;
		size = HandleUtility.GetHandleSize (point8);
		Handles.Button (point8, handleRotation, size * handleSize * 2.0f, size * pickSize * 2.0f, Handles.DotCap);
		
		Handles.color = Color.red;
        size = HandleUtility.GetHandleSize(point9);
        Handles.Button (point9, handleRotation, size * handleSize, size * pickSize, Handles.DotCap);
		
		Handles.color = new Color (0.835f, 0.671f, 0.482f);
		size = HandleUtility.GetHandleSize (point10);
		Handles.Button (point10, handleRotation, size * handleSize, size * pickSize, Handles.DotCap);
	}

	public override void OnInspectorGUI()
	{
		GUILayout.Label ("Edit the start / finish points");
		DrawDefaultInspector ();
		startFinish = target as StartFinish;
		startFinish.RealLength = startFinish.FinishDistance - startFinish.StartDistance;
        if (GUILayout.Button("Calculate splits"))
        {
            startFinish.CalculateSplits();
            EditorUtility.SetDirty(startFinish);
            makeDirtyScenes();
        }

        GUILayout.Space(5);
        GUI.backgroundColor = new Color(0.0f, 0.8f, 0.5176f);
        if (GUILayout.Button("Place signals"))
		{
			startFinish.PlaceSignals();
            EditorUtility.SetDirty(startFinish);
            makeDirtyScenes();
        }

        GUILayout.Space(5);
        GUI.backgroundColor = new Color(1.0f, 0.647f, 0.0f);
        if (GUILayout.Button("Clear signals"))
        {
            startFinish.CleanSigns();
            EditorUtility.SetDirty(startFinish);
            makeDirtyScenes();
        }
    }

    private void makeDirtyScenes()
    {
        for (int i = 0; i < EditorSceneManager.sceneCount; i++)
        {
            EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetSceneAt(i));
        }
    }
}
