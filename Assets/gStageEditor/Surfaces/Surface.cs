using UnityEngine;
using System.Collections;
#if UNITY_EDITOR
using UnityEditor;
#endif

[System.Serializable]
public class Surface
{
    public enum SURFACE_TYPE
    {
        NONE,
        TARMAC,
        GRASS,
        GRAVEL,
        CONCRETE,
        SAND,
        COBBLES,
        DIRT,
        SNOW,
        ICE
    }

    public SURFACE_TYPE Type;
    public Color PhysColor;
    public string Name;
    public Vector2 Friction;
    public float Rolling;
    public float Drag;
    public Vector2 Bump;

    [Header("Trails:")]
    [Space(5)]
    public Color TrailColor;
    public float TrailBump;

    [Header("Smoke:")]
    [Space(5)]
    public Color SmokeStart;
    public Color SmokeStartVariation;
    public Color SmokeEnd;
    public Color SmokeEndVariation;
    public Vector2 LifeTime;
    public Vector2 Speed;
    public Vector2 SizeStart;
    public Vector2 SizeEnd;
}
