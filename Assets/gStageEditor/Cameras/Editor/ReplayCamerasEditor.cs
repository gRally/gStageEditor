using UnityEngine;
using System.Collections;
using UnityEditor;

[CustomEditor(typeof(ReplayCameras))]
public class ReplayCamerasEditor : Editor
{
	private ReplayCameras replayCameras;
	//private Transform handleTransform;
	//private Quaternion handleRotation;
	//private int selectedIndex = -1;
	private const float handleSize = 0.06f;
	private const float pickSize = 0.08f;
    private int lastCameraID = -1;

	private void OnSceneGUI ()
	{
		//return;
		replayCameras = target as ReplayCameras;
		//handleTransform = replayCameras.transform;
		//handleRotation = Tools.pivotRotation == PivotRotation.Local ? handleTransform.rotation : Quaternion.identity;

		if (GUI.changed)
		{
			EditorUtility.SetDirty(replayCameras); 
		}
	}


	public override void OnInspectorGUI()
	{
		DrawDefaultInspector ();
        serializedObject.Update();

        replayCameras = (ReplayCameras)serializedObject.targetObject;
        if (replayCameras != null)
		{
			replayCameras.UpdateSimulation ();
            GUI.backgroundColor = new Color32(0, 255, 0, 255);
            if (GUILayout.Button("Add camera"))
			{
                var sceneView = SceneView.currentDrawingSceneView;
                if (sceneView == null)
                {
                    sceneView = SceneView.lastActiveSceneView;
                }

                replayCameras.AddCamera(sceneView.camera.gameObject.transform.position, sceneView.camera.gameObject.transform.rotation);
			}

            GUI.backgroundColor = Color.white;
            if (GUILayout.Button("Sort cameras"))
            {
                replayCameras.Sort(true);	
            }
            if (GUILayout.Button("Sort cameras (no rename)"))
            {
                replayCameras.Sort(false);
            }

            GUI.backgroundColor = new Color32(255, 255, 10, 255);
            string btnStart = "Start Simulation";
            if (replayCameras.OnSimulation)
            {
                btnStart = "Stop Simulation";
                GUI.backgroundColor = new Color32(245, 53, 70, 255);
            }
            if (GUILayout.Button(btnStart))
			{
				replayCameras.StartSimulation();
                if (replayCameras.OnSimulation)
                {
                    var camViewer = (CameraViewer)EditorWindow.GetWindow(typeof(CameraViewer), false, "Camera Viewer");
                    camViewer.ShowFromReplayCameras(replayCameras);
                }
            }
            GUI.backgroundColor = new Color32(133, 253, 110, 255);
            if (GUILayout.Button("Change Camera!"))
			{
				replayCameras.NextCamera();	
			}

            GUILayout.Space(10);
            GUI.backgroundColor = new Color32(119, 170, 255, 255);
            if (GUILayout.Button("Update from distance"))
            {
                replayCameras.UpdateFromDistance();
            }

            GUI.backgroundColor = new Color32(255, 204, 119, 255);
            if (GUILayout.Button("Last Camera"))
            {
                replayCameras.LastCamera();
            }

            if (replayCameras.OnSimulation)
            {
                if (lastCameraID == replayCameras.currentCam)
                {
                    if (replayCameras.LastActualFocalLength != replayCameras.ActualFocalLength)
                    {
                        // changed focal length
                        replayCameras.ReplayCamActual.FocalLength = replayCameras.ActualFocalLength;
                        replayCameras.LastActualFocalLength = replayCameras.ActualFocalLength;
                    }
                    if (replayCameras.LastNextFocalLength != replayCameras.NextFocalLength)
                    {
                        // changed focal length
                        replayCameras.ReplayCamNext.FocalLength = replayCameras.NextFocalLength;
                        replayCameras.LastNextFocalLength = replayCameras.NextFocalLength;
                    }
                }
                else
                {
                    lastCameraID = replayCameras.currentCam;
                    // read the focal len
                    replayCameras.ActualFocalLength = replayCameras.ReplayCamActual.FocalLength;
                    replayCameras.LastActualFocalLength = replayCameras.ActualFocalLength;
                    replayCameras.NextFocalLength = replayCameras.ReplayCamNext.FocalLength;
                    replayCameras.LastNextFocalLength = replayCameras.NextFocalLength;
                }
            }
        }
        serializedObject.ApplyModifiedProperties();
    }
}
