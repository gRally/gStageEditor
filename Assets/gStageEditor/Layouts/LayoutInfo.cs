using UnityEngine;
using System.Collections;

[System.Serializable]
public class LayoutInfo : MonoBehaviour
{
    public string Name;
    [TextArea(5, 50)]
    public string Description;
    [Space(10)]
    public string Nation;
    public string Surfaces;
    public string Tags;
    public bool SaveTimes = true;
}
