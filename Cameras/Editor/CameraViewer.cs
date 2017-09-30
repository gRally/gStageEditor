// Simple script that lets you render the main camera in an editor Window.
	
using UnityEngine;
using UnityEditor;
	
public class CameraViewer : EditorWindow
{
	Camera camera;
	Camera cameraNext;
	RenderTexture renderTexture;
	RenderTexture renderTextureNext;
	Rect fPosition;
    ReplayCameras replayCameras;

	[MenuItem("gRally/Camera viewer", false, 50)]
	static void Init()
	{
		EditorWindow editorWindow = GetWindow(typeof(CameraViewer));
		editorWindow.autoRepaintOnSceneChange = true;

		editorWindow.Show();
	}

    public void ShowFromReplayCameras(ReplayCameras value)
    {
        replayCameras = value;
        autoRepaintOnSceneChange = true;
        Show();
    }

	public void Awake ()
	{
		foreach (var item in Camera.allCameras)
		{
			if (item.name == "ReplayActual")
			{
				camera = item;	
			}	
			if (item.name == "ReplayNext")
			{
				cameraNext = item;
			}
		}
        renderTexture = new RenderTexture((int)position.width, (int)(position.height / 2.0f), 16, RenderTextureFormat.ARGB32 );
		renderTextureNext = new RenderTexture((int)position.width, (int)(position.height / 2.0f), 16, RenderTextureFormat.ARGB32 );
		fPosition = position;
	}
	
	public void Update()
	{
		if(camera != null) {
			camera.targetTexture = renderTexture;
			camera.Render();
			camera.targetTexture = null;	
		}
		if(cameraNext != null) {
			cameraNext.targetTexture = renderTextureNext;
			cameraNext.Render();
			cameraNext.targetTexture = null;	
		}
		if ((int)fPosition.width != (int)position.width || (int)fPosition.height != (int)position.height)
        {
			renderTexture = new RenderTexture ((int)position.width, (int)(position.height / 2.0f), 16, RenderTextureFormat.ARGB32);
			renderTextureNext = new RenderTexture ((int)position.width, (int)(position.height / 2.0f), 16, RenderTextureFormat.ARGB32);
		}
		fPosition = position;
	}

	void OnGUI()
	{
        GUILayout.BeginArea(new Rect(0.0f, 5.0f, position.width, 20.0f));
        EditorGUILayout.LabelField("Actual camera: " + replayCameras.CamActualName);
        GUILayout.EndArea();
        GUI.DrawTexture(new Rect(0.0f, 20.0f, position.width, position.width * 9.0f / 16.0f), renderTexture);

        GUILayout.BeginArea(new Rect(0.0f, Mathf.Floor(position.width * 9.0f / 16.0f + 25.0f), position.width, 20.0f));
        EditorGUILayout.LabelField("Next camera: " + replayCameras.CamNextName);
        GUILayout.EndArea();
        GUI.DrawTexture(new Rect(0.0f, position.width * 9.0f / 16.0f + 40.0f, position.width, position.width * 9.0f / 16.0f), renderTextureNext);
    }
}