using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class GR_Semaphore : MonoBehaviour
{
    public Light RedLight;
    public Light YellowLight;
    public Light GreenLight;
    public Material Semaphore;

    [Range(0,6)]
    public int DebugCountDown = 6;

    private int fDebugCountDown = 6;
    // Use this for initialization

    // Update is called once per frame
    void Update ()
    {
        if (DebugCountDown != fDebugCountDown)
        {
            if (DebugCountDown == 0)
            {
                // green
                if (RedLight != null) RedLight.intensity = 0.0f;
                if (YellowLight != null) YellowLight.intensity = 0.0f;
                if (GreenLight != null) GreenLight.intensity = 2.0f;
                if (Semaphore != null) Semaphore.SetFloat("_startFrame", 3.0f);
            }
            else if (DebugCountDown == 1)
            {
                // yellow
                if (RedLight != null) RedLight.intensity = 0.0f;
                if (YellowLight != null) YellowLight.intensity = 2.0f;
                if (GreenLight != null) GreenLight.intensity = 0.0f;
                if (Semaphore != null) Semaphore.SetFloat("_startFrame", 2.0f);
            }
            else if (DebugCountDown < 6)
            {
                // red
                if (RedLight != null) RedLight.intensity = 2.0f;
                if (YellowLight != null) YellowLight.intensity = 0.0f;
                if (GreenLight != null) GreenLight.intensity = 0.0f;
                if (Semaphore != null) Semaphore.SetFloat("_startFrame", 1.0f);
            }
            else
            {
                if (RedLight != null) RedLight.intensity = 0.0f;
                if (YellowLight != null) YellowLight.intensity = 0.0f;
                if (GreenLight != null) GreenLight.intensity = 0.0f;
                if (Semaphore != null) Semaphore.SetFloat("_startFrame", 0.0f);
            }
            fDebugCountDown = DebugCountDown;
        }
    }
}
