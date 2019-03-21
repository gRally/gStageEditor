using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HideObject : MonoBehaviour
{
    public List<HideVisible> hideVisible;
}

[System.Serializable]
public class HideVisible
{
    public float beginVisible;
    public float endVisible;
}
