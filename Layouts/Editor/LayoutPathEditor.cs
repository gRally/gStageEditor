using UnityEngine;
using System.Collections;
using UnityEditor;

[CustomEditor(typeof(LayoutPath))]
public class LayoutPathEditor : Editor
{
	private LayoutPath layoutPath;
	private Transform handleTransform;
	private Quaternion handleRotation;
	private int selectedIndex = -1;
	private const float handleSize = 0.06f;
	private const float pickSize = 0.08f;

	private bool showPoints = false;

	private void OnSceneGUI ()
	{
		layoutPath = target as LayoutPath;

		handleTransform = layoutPath.transform;
		handleRotation = Tools.pivotRotation == PivotRotation.Local ? handleTransform.rotation : Quaternion.identity;

		for (int i = 0; i < layoutPath.GetPointsCount(); ++i)
		{
			Vector3 p0 = ShowPoint(i);

			if (i < layoutPath.GetPointsCount() -1)
			{
				Vector3 p1 = ShowPoint(i + 1);	
				Handles.color = Color.green;
				Handles.DrawLine(p0, p1);
			}
		}


		if (layoutPath.CreateManualPath) //&& /*Input.GetMouseButton(1) &&*/ Input.GetKey(KeyCode.LeftControl))
		{
			if (Event.current.keyCode == KeyCode.LeftControl && Event.current.type == EventType.keyUp)
			{
				Vector2 guiPosition = Event.current.mousePosition;
				Ray ray = HandleUtility.GUIPointToWorldRay(guiPosition);
				RaycastHit hit;
				if (Physics.Raycast(ray, out hit))
				{
					var MC = hit.collider as MeshCollider;
					if (MC != null)
					{
						var mesh = MC.sharedMesh;
						var index = hit.triangleIndex * 3;
						
						var hit1 = mesh.vertices[mesh.triangles[index    ]];
						var hit2 = mesh.vertices[mesh.triangles[index + 1]];
						var hit3 = mesh.vertices[mesh.triangles[index + 2]];

						var m1 = (hit.point - hit1).sqrMagnitude;
						var m2 = (hit.point - hit2).sqrMagnitude;
						var m3 = (hit.point - hit3).sqrMagnitude;

						if	(m1 < m2)
						{
							if (m1 < m3)
							{
								// 1
								layoutPath.AddPoint(hit1);
								return;
							}
							else
							{
								// 3
								layoutPath.AddPoint(hit3);
								return;
							}
						}
						else if (m2 < m3)
						{
							// 2
							layoutPath.AddPoint(hit2);
							return;
						}
						else 
						{
							// 3
							layoutPath.AddPoint(hit3);
							return;
						}
					}
					
					//Debug.Log(hit.point);
				}
			}
		}

		if (GUI.changed)
		{
			EditorUtility.SetDirty(layoutPath); 
		}
	}

	private Vector3 ShowPoint (int index)
	{
		Vector3 point = handleTransform.TransformPoint(layoutPath.GetPoint(index));

		if (showPoints)
		{
			float size = HandleUtility.GetHandleSize(point);
			if (index == 0)
			{
				size *= 2f;
			}
			Handles.color = Color.yellow;
			if (Handles.Button(point, handleRotation, size * handleSize, size * pickSize, Handles.DotCap))
			{
				selectedIndex = index;
				Repaint();
			}
			if (selectedIndex == index)
			{
				//Debug.Log("index pressed: " + index.ToString());
				EditorGUI.BeginChangeCheck();
				point = Handles.DoPositionHandle(point, handleRotation);
				if (EditorGUI.EndChangeCheck())
				{
					Undo.RecordObject(layoutPath, "Move Point");
					EditorUtility.SetDirty(layoutPath);
					layoutPath.UpdatePoint(index, handleTransform.InverseTransformPoint(point));
				}
			}			
		}
		return point;
	}
	
	public override void OnInspectorGUI()
	{
		DrawDefaultInspector();
		
		layoutPath = target as LayoutPath;

        GUILayout.Space(10);
        showPoints = GUILayout.Toggle (showPoints, "Show points");

        GUILayout.Space(10);
        GUILayout.Label("Import from Max spline generated", EditorStyles.boldLabel);
        GUI.backgroundColor = new Color32(157, 220, 207, 255);
		if(GUILayout.Button("Import XML"))
		{
			var path = EditorUtility.OpenFilePanel("Select the XML that contains the spline path points",
				"",
				"xml");
			if (path.Length != 0)
			{
				layoutPath.BuildObject(path);
			}
		}

        GUILayout.Space(10);
        GUI.backgroundColor = new Color(0.0f, 0.8f, 0.5176f);
        GUILayout.Label("Import from Sentieri waypoints", EditorStyles.boldLabel);
        if (GUILayout.Button("Create path")) layoutPath.GenerateFromWaypoints();

        GUILayout.Space(10);
        GUILayout.Label("Utility", EditorStyles.boldLabel);
        /* ??
        GUI.backgroundColor = Color.white;
        //GUILayout.Label("Import from Max spline generated", EditorStyles.boldLabel);
        if (GUILayout.Button("Export XML"))
        {
            var path = EditorUtility.SaveFilePanel("Select the folder to store the XML",
                "", "path.xml", "xml");
            if (path.Length != 0)
            {
                layoutPath.ExportXml(path);
            }
        }*/
        if (selectedIndex >= 0)
        {
            GUI.backgroundColor = Color.red;
            if (GUILayout.Button("Remove selected point"))
            {
                layoutPath.RemoveAt(selectedIndex);	
            }
        }

        GUI.backgroundColor = new Color32(220, 157, 170, 255);
        if (GUILayout.Button("Invert points"))
        {
            layoutPath.Invert();
        }

        GUI.backgroundColor = new Color(1.0f, 0.647f, 0.0f);
        if (GUILayout.Button("Clear"))
        {
            layoutPath.Clear();	
        }
	}
}
