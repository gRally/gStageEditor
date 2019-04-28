using UnityEngine;
using System.Collections;
using System.Collections.Generic;

[System.Serializable]
public class StageData : ScriptableObject
{
    [Header("gStageEditor data")]
    public string exportPath = "";
    [Space(10)]
    [Header("Stage coordinates")]
    public float latitude;
    public float longitude;
    public float north;
    [Space(10)]
    [Header("Surface library")]
    public List<Surface> surfaceList;
}