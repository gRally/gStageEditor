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
    public bool PlayAnimation;

    [Range(0,6)]
    public int DebugCountDown = 6;

    private int fDebugCountDown = 6;
    // Use this for initialization

    // Update is called once per frame
    void Update ()
    {
        if (PlayAnimation)
        {
            var anim = transform.gameObject.GetComponent<Animator>();
            if (anim != null)
            {
                anim.SetBool("startLight", true);
            }
        }
    }
}
