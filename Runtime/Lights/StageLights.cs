using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class StageLightSet
{
    public List<Material> material;
    public Color emissionColorOn;
    public Color emissionColorOff;
    public float emissionOn;
    public float emissionOff;

    public StageLightSet()
    {
        emissionColorOn = Color.white;
        emissionColorOff = Color.black;

        emissionOn = 1.0f;
        emissionOff = 0.0f;
    }

    public void On()
    {
        foreach (var item in material)
        {
            item.SetColor("_EmissionColor", emissionColorOn * emissionOn);
            item.EnableKeyword("_EMISSION");
        }
    }

    public void Off()
    {
        foreach (var item in material)
        {
            item.SetColor("_EmissionColor", emissionColorOff * emissionOff);
            if (emissionOff > 0.0f)
            {
                item.EnableKeyword("_EMISSION");
            }
            else
            {
                item.DisableKeyword("_EMISSION");
            }
        }
    }

    public void Update(bool on)
    {
        if (on)
        {
            On();
        }
        else
        {
            Off();
        }
    }
}

public class StageLights : MonoBehaviour
{
    public StageLightSet[] LightsMaterial;

    // Use this for initialization
    void Start ()
    {
    }

    // Update is called once per frame
    void Update ()
    {

    }
}
