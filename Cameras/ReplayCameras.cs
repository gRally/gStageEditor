using UnityEngine;
using System.Collections.Generic;
using UnityEngine.SceneManagement;
using System;

//[ExecuteInEditMode]
public class ReplayCameras : MonoBehaviour
{
	private GameObject cameras;
	private LayoutPath layout = null;
	public bool OnSimulation = false;
	public float Distance = 0.0f;
    public int currentCam = 0;

    [Header("Camera Actual:")]
    public string CamActualName = "";
    public float ActualFocalLength;

    [Header("Camera Next:")]
	public string CamNextName = "";
    public float NextFocalLength;

    private Camera camActual = null;
    [HideInInspector]
    public ReplayCamera ReplayCamActual;
	private Camera camNext = null;
    [HideInInspector]
    public ReplayCamera ReplayCamNext;

    [HideInInspector]
    public float LastActualFocalLength = -1;
    [HideInInspector]
    public float LastNextFocalLength = -1;

    SortedDictionary<float, GameObject> camList = new SortedDictionary<float, GameObject> ();
	
	// Use this for initialization
	void Start ()
	{
		currentCam = 0;
		Distance = 0.0f;
		OnSimulation = false;
		Sort (true);
		layout = transform.GetComponent<LayoutPath>();	
	}

	void Update ()
	{
		if (OnSimulation)
		{
			layout.GetPositionOnPath(Distance);

			int i = 0;
			foreach (var item in camList)
			{
				if (i == currentCam)
				{
					Camera.main.transform.position = item.Value.transform.position;	
					Camera.main.transform.LookAt(layout.PosOnPath);
				}

				if (i == currentCam + 1)
				{
					if (Distance > item.Value.GetComponent<ReplayCamera>().StartDistance)
					{
						currentCam ++;
					};
					break;
				}
				i++;
			}
            //Distance += 0.25f;
		}
	}

	public void NextCamera()
	{
		currentCam ++;

		int i = 0;
		foreach (var item in camList)
		{
			if (i == currentCam)
			{
				item.Value.GetComponent<ReplayCamera>().StartDistance = Distance;
				break;
			}
			i++;
		}
		UpdateSimulation ();
	}

    public void UpdateFromDistance()
    {
        int i = 0;
        int lastCam = -1;
        foreach (var item in camList)
        {
            var dist = item.Value.GetComponent<ReplayCamera>().StartDistance;
            if (dist != -1.0f && dist < Distance)
            {
                lastCam = i;
            }
            i++;
        }

        currentCam = lastCam;
        UpdateSimulation(true);
    }

    public void LastCamera()
    {
        int i = 0;
        float lastDist = 0.0f;
        foreach (var item in camList)
        {
            var dist = item.Value.GetComponent<ReplayCamera>().StartDistance;
            if (dist == -1.0f)
            {
                currentCam = i - 1;
                Distance = lastDist + 1.0f;
                break;
            }
            lastDist = dist;
            i++;
        }
        UpdateSimulation(true);
    }

    public void UpdateSimulation(bool forceUpdate = false)
    {
        if (OnSimulation || forceUpdate)
        {
            if (layout == null)
            {
                layout = transform.GetComponent<LayoutPath>();
            }
            if (camActual == null)
            {
                foreach (var cam in Camera.allCameras)
                {
                    if (cam.name == "ReplayActual")
                    {
                        camActual = cam;
                    }
                    else if (cam.name == "ReplayNext")
                    {
                        camNext = cam;
                    }
                }
            }

            layout.GetPositionOnPath(Distance);

            //GameObject.Find("CarSimulator").hideFlags = HideFlags.HideInInspector;
            GameObject.Find("CarSimulator").transform.position = layout.PosOnPath;
            
            if (camList.Count == 0)
            {
                Sort(true);
            }

            int i = 0;
            foreach (var item in camList)
            {
                if (i == currentCam)
                {
                    ReplayCamActual = item.Value.GetComponent<ReplayCamera>();
                    camActual.transform.position = item.Value.transform.position;
                    camActual.fieldOfView = ReplayCamActual.Fov;
                    CamActualName = item.Value.name;
                    //ActualFocalLength = ReplayCamActual.FocalLength;
                }
                if (i == currentCam + 1)
                {
                    ReplayCamNext = item.Value.GetComponent<ReplayCamera>();
                    camNext.transform.position = item.Value.transform.position;
                    camNext.fieldOfView = ReplayCamNext.Fov;
                    CamNextName = item.Value.name;
                    //NextFocalLength = ReplayCamNext.FocalLength;
                }
                i++;
            }

            if (!ReplayCamActual.IsFixed)
            {
                camActual.transform.LookAt(layout.PosOnPath);
            }
            else
            {
                camActual.transform.localRotation = ReplayCamActual.transform.localRotation;
            }
            if (!ReplayCamNext.IsFixed)
            {
                camNext.transform.LookAt(layout.PosOnPath);
            }
            else
            {
                camNext.transform.localRotation = ReplayCamNext.transform.localRotation;
            }

            if (Distance < 0.0f)
            {
                Distance = 0.0f;
            }

            if (Distance > layout.Length)
            {
                Distance = layout.Length;
            }

            // check the camera changin'
            if (Distance > ReplayCamNext.StartDistance && ReplayCamNext.StartDistance != -1)
            {
                currentCam++;
                if (camList.Count <= currentCam)
                {
                    currentCam = camList.Count - 1;
                }
            }
        }
    }

    public void StartSimulation()
    {
        SceneManager.SetActiveScene(SceneManager.GetSceneByName("main"));
        OnSimulation = !OnSimulation;
        foreach (var cam in Camera.allCameras)
        {
            if (cam.name == "ReplayActual")
            {
                camActual = cam;
            }
            else if (cam.name == "ReplayNext")
            {
                camNext = cam;
            }
        }

        if (camActual == null)
        {
            camActual = Instantiate(Camera.main, new Vector3(0, 0, 0), Quaternion.FromToRotation(new Vector3(0, 0, 0), new Vector3(0, 0, 1)));
            camActual.GetComponent<AudioListener>().enabled = false;
            camActual.name = "ReplayActual";
        }
        if (camNext == null)
        {
            camNext = Instantiate(Camera.main, new Vector3(0, 0, 0), Quaternion.FromToRotation(new Vector3(0, 0, 0), new Vector3(0, 0, 1)));
            camNext.GetComponent<AudioListener>().enabled = false;
            camNext.name = "ReplayNext";
        }

        if (OnSimulation)
        {
            //((Camera)GameObject.Find("FirstPersonCharacter").GetComponent(typeof(Camera))).enabled = false;
            camNext.depth = 1;
            camActual.depth = 1;
            camNext.enabled = true;
            camActual.enabled = true;
        }
        else
        {
            //((Camera)GameObject.Find("FirstPersonCharacter").GetComponent(typeof(Camera))).enabled = true;
            camNext.depth = -1;
            camActual.depth = -1;
            camNext.enabled = false;
            camActual.enabled = false;
        }
        currentCam = 0;
        Distance = 0.0f;
    }

    public void Sort(bool rename)
    {
        if (layout == null)
        {
            layout = transform.GetComponent<LayoutPath>();					
        }

        if (cameras == null)
        {
            // try to find a gameobject
            foreach (Transform t in transform.gameObject.transform)
            {
                if (t.name == "LayoutCameras")
                {
                    cameras = t.gameObject;
                    break;
                }
            }
            if (cameras == null)
            {
                cameras = new GameObject("LayoutCameras");
                cameras.transform.SetParent(transform);
            }
        }

        camList.Clear();
        int iCam = 0;
        foreach (Transform item in cameras.transform)
        {
            if (rename)
            {
                layout.GetPositionOnPath(item.position);
                Debug.Log(string.Format("Cam {0}, perc {1}", item.name, layout.Perc));
                camList.Add(layout.Perc * 10.0f, item.gameObject);
            }
            else
            {
                camList.Add(Convert.ToSingle(iCam), item.gameObject);
            }
            iCam++;
        }

        if (rename)
        {
            int i = 0;
            foreach (var item in camList)
            {
                item.Value.name = string.Format("{0:000}_cam", item.Key);
                item.Value.transform.SetSiblingIndex(i++);
            }
        }
    }

	public void AddCamera(Vector3 position, Quaternion rotation)
	{
		if (cameras == null)
		{
			// try to find a gameobject
			foreach (Transform t in transform.gameObject.transform)
			{
				if (t.name == "LayoutCameras")
				{
					cameras = t.gameObject;
					break;
				}
			}
			if (cameras == null)
			{
				cameras = new GameObject("LayoutCameras");
				cameras.transform.SetParent (transform);
			}
		}

		GameObject go = new GameObject("Camera");
		var rc = go.AddComponent<ReplayCamera>();
        rc.StartDistance = -1.0f;
		go.transform.position = position;
		go.transform.rotation = rotation;
		go.transform.parent = cameras.transform;
	}
}

