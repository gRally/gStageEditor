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
        DIRT,
        SNOW,
        ICE
    }

    public string Name;
    public SURFACE_TYPE Type;
    public Color PhysColor;

    [Header("Physics"), Range(0.0f, 1.0f)]
    public float UsableGrip;
    public float Rolling;
    public float Drag;
    public int Octaves;
    // ff
    public float Persistance;
    public float Lacunarity;
    public float ScaleBump;
    public float Scale;

    [Header("Trails:")]
    public Color TrailColor;
    public float TrailBump;

    [Header("Smoke:")]
    public Gradient GradientColor;
    [Tooltip("min and max lifetime")]
    public Vector2 LifeTime;
    [Tooltip("min and max size")]
    public Vector2 Size;
    public float Gravity;
}
