using UnityEngine;
using System.Collections;
using UnityEditor;
using System.Linq;

[CustomEditor(typeof(EnableGravity))]
public class EnableGravityEditor : Editor
{
    void OnSceneGUI()
    {
        var t = target as EnableGravity;
    }

    public override void OnInspectorGUI()
    {
        var t = serializedObject.targetObject as EnableGravity;

        DrawDefaultInspector();


        GUI.backgroundColor = Color.yellow;
        if (GUILayout.Button("Enable!"))
        {
            t.Gravity();
            EditorUtility.SetDirty(t);
        }
        GUI.backgroundColor = Color.white;
    }
}

