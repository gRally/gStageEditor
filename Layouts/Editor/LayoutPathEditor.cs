using UnityEngine;
using System.Collections;
using UnityEditor;
using System.Collections.Generic;

[CustomEditor(typeof(LayoutPath))]
public class LayoutPathEditor : Editor
{
    private LayoutPath layoutPath;
    private Transform handleTransform;
    private Quaternion handleRotation;
    private int selectedIndex = -1;
    private const float handleSize = 0.06f;
    private const float pickSize = 0.08f;

    Texture nodeTexture;
    static GUIStyle handleStyle = new GUIStyle();
    List<int> alignedPoints = new List<int>();

    void OnEnable()
    {
        nodeTexture = Resources.Load<Texture>("Handle");
        if (nodeTexture == null) nodeTexture = EditorGUIUtility.whiteTexture;
        handleStyle.alignment = TextAnchor.MiddleCenter;
        handleStyle.fixedWidth = 25;
        handleStyle.fixedHeight = 25;
    }

    void OnSceneGUI()
    {
        layoutPath = target as LayoutPath;
        Vector3[] localPoints = layoutPath.points.ToArray();
        Vector3[] worldPoints = new Vector3[layoutPath.points.Count];
        for (int i = 0; i < worldPoints.Length; i++)
        {
            worldPoints[i] = layoutPath.transform.TransformPoint(localPoints[i]);
        }

        DrawPolyLine(worldPoints);

        if (!layoutPath.EditLine)
        {
            return;
        }

        DrawNodes(worldPoints);

        if (Event.current.shift)
        {
            var newPoint = FindPoint();

            if (newPoint == Vector3.zero)
            {
                return;
            }

            float handleSize = HandleUtility.GetHandleSize(newPoint);
            var nodeIndex = FindNearestNodeToMouse(worldPoints);
            if (nodeIndex < worldPoints.Length - 1)
            {
                if (Handles.Button(newPoint, Quaternion.identity, handleSize * 0.1f, handleSize, HandleFuncNearest))
                {
                    Undo.RecordObject(layoutPath, "Insert Node");
                    layoutPath.points.Insert(nodeIndex + 1, newPoint);
                    Event.current.Use();
                    layoutPath.calcLength();
                }
            }
            else
            {
                if (Handles.Button(newPoint, Quaternion.identity, handleSize * 0.1f, handleSize, HandleFunc))
                {
                    Undo.RecordObject(layoutPath, "Insert Node");
                    layoutPath.points.Add(newPoint);
                    Event.current.Use();
                    layoutPath.calcLength();
                }
            }
        }

        if (Event.current.control)
        {
            //Deleting Points
            int indexToDelete = FindNearestNodeToMouse(worldPoints);
            Handles.color = Color.red;
            float handleSize = HandleUtility.GetHandleSize(worldPoints[0]);
            if (Handles.Button(worldPoints[indexToDelete], Quaternion.identity, handleSize * 0.09f, handleSize, DeleteHandleFunc))
            {
                Undo.RecordObject(layoutPath, "Remove Node");
                layoutPath.points.RemoveAt(indexToDelete);
                indexToDelete = -1;
                Event.current.Use();
                layoutPath.calcLength();
            }

            Handles.color = Color.white;
        }

        if (GUI.changed)
        {
            EditorUtility.SetDirty(layoutPath);
        }
    }

    private void DrawPolyLine(Vector3[] nodes)
    {
        if (Event.current.shift) Handles.color = Color.green;
        else if (Event.current.control)
            Handles.color = Color.red;
        else
            Handles.color = Color.magenta;
        for (int i = 0; i < nodes.Length - 1; i++)
        {
            if (alignedPoints.Contains(i) && alignedPoints.Contains(i + 1))
            {
                Color currentColor = Handles.color;
                Handles.color = Color.green;
                Handles.DrawLine(nodes[i], nodes[i + 1]);
                Handles.color = currentColor;
            }
            else
                Handles.DrawLine(nodes[i], nodes[i + 1]);
        }

        Handles.color = Color.white;
    }

    private void DrawNodes(Vector3[] worldPoints)
    {
        for (int i = 0; i < layoutPath.points.Count; i++)
        {
            Vector3 pos = layoutPath.transform.TransformPoint(layoutPath.points[i]);
            float handleSize = HandleUtility.GetHandleSize(pos);
            Vector3 newPos = Handles.FreeMoveHandle(pos, Quaternion.identity, handleSize * 0.09f, Vector3.one, HandleFunc);
            if (newPos != pos)
            {
                newPos = FindPoint();
                //CheckAlignment(worldPoints, handleSize * 0.1f, i, ref newPos);
                Undo.RecordObject(layoutPath, "Move Node");
                layoutPath.points[i] = layoutPath.transform.InverseTransformPoint(newPos);
                layoutPath.calcLength();
            }
        }
    }

    private Vector3 FindPoint()
    {
        Vector2 guiPosition = Event.current.mousePosition;
        Ray ray = HandleUtility.GUIPointToWorldRay(guiPosition);
        RaycastHit hit;
        if (Physics.Raycast(ray, out hit))
        {
            var MC = hit.collider as MeshCollider;
            if (MC != null)
            {
                var mesh = MC.sharedMesh;
                var index = hit.triangleIndex * 3;

                var hit1 = mesh.vertices[mesh.triangles[index]];
                var hit2 = mesh.vertices[mesh.triangles[index + 1]];
                var hit3 = mesh.vertices[mesh.triangles[index + 2]];

                var m1 = (hit.point - hit1).sqrMagnitude;
                var m2 = (hit.point - hit2).sqrMagnitude;
                var m3 = (hit.point - hit3).sqrMagnitude;

                if (m1 < m2)
                {
                    if (m1 < m3) return hit1;
                    else return hit3;
                }
                else if (m2 < m3)
                    return hit2;
                else
                    return hit3;
            }
        }

        return Vector3.zero;
    }

    private int FindNearestNodeToMouse(Vector3[] worldNodesPositions)
    {
        Vector3 mousePos = FindPoint();
        int index = -1;
        float minDistnce = float.MaxValue;
        for (int i = 0; i < worldNodesPositions.Length; i++)
        {
            float distance = Vector3.Distance(worldNodesPositions[i], mousePos);
            if (distance < minDistnce)
            {
                index = i;
                minDistnce = distance;
            }
        }

        return index;
    }

    void HandleFunc(int controlID, Vector3 position, Quaternion rotation, float size)
    {
        if (controlID == GUIUtility.hotControl)
            GUI.color = Color.red;
        else
            GUI.color = Color.green;
        Handles.Label(position, new GUIContent(nodeTexture), handleStyle);
        GUI.color = Color.white;
    }

    void HandleFuncNearest(int controlID, Vector3 position, Quaternion rotation, float size)
    {
        if (controlID == GUIUtility.hotControl)
            GUI.color = Color.red;
        else
            GUI.color = Color.yellow;
        Handles.Label(position, new GUIContent(nodeTexture), handleStyle);
        GUI.color = Color.white;
    }

    void DeleteHandleFunc(int controlID, Vector3 position, Quaternion rotation, float size)
    {
        GUI.color = Color.red;
        Handles.Label(position, new GUIContent(nodeTexture), handleStyle);
        GUI.color = Color.white;
    }

    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        layoutPath = target as LayoutPath;

        GUILayout.Space(10);
        GUILayout.Label("Import from Max spline generated", EditorStyles.boldLabel);
        GUI.backgroundColor = new Color32(157, 220, 207, 255);
        if (GUILayout.Button("Import XML"))
        {
            var path = EditorUtility.OpenFilePanel("Select the XML that contains the spline path points", "", "xml");
            if (path.Length != 0)
            {
                layoutPath.BuildObject(path);
            }
        }

        GUILayout.Space(10);
        GUI.backgroundColor = new Color(0.0f, 0.8f, 0.5176f);
        GUILayout.Label("Import from Sentieri waypoints", EditorStyles.boldLabel);
        if (GUILayout.Button("Create path")) layoutPath.GenerateFromWaypoints();
        if (GUILayout.Button("Export path")) layoutPath.ExportFromWaypoints();

        GUILayout.Space(10);
        GUI.backgroundColor = new Color32(248, 200, 81, 255);
        GUILayout.Label("Import from Moose Procedural Rally stages", EditorStyles.boldLabel);
        if (GUILayout.Button("Import spline.rsd"))
        {
            var path = EditorUtility.OpenFilePanel("Select the spline.rsd file", "", "rsd");
            if (path.Length != 0)
            {
                if (layoutPath.ImportMooseBin(path))
                {
                    EditorUtility.DisplayDialog("Moose Import", "Path imported!", "Ok!!");
                }
                else
                {
                    EditorUtility.DisplayDialog("Moose Import", "ERROR!, no points added\r\nCheck the file!", "Ok!!");
                }
            }
        }

        GUILayout.Space(10);
        GUILayout.Label("Utility", EditorStyles.boldLabel);
        GUI.backgroundColor = new Color32(115, 242, 252, 255);
        if (GUILayout.Button("Update Length")) layoutPath.calcLength();
        /* ??
        GUI.backgroundColor = Color.white;
        //GUILayout.Label("Import from Max spline generated", EditorStyles.boldLabel);
        if (GUILayout.Button("Export XML"))
        {
            var path = EditorUtility.SaveFilePanel("Select the folder to store the XML",
                "", "path.xml", "xml");
            if (path.Length != 0)
            {
                layoutPath.ExportXml(path);
            }
        }*/
        if (selectedIndex >= 0)
        {
            GUI.backgroundColor = Color.red;
            if (GUILayout.Button("Remove selected point"))
            {
                layoutPath.RemoveAt(selectedIndex);
            }
        }

        GUI.backgroundColor = new Color32(220, 157, 170, 255);
        if (GUILayout.Button("Invert points"))
        {
            layoutPath.Invert();
        }

        GUI.backgroundColor = new Color(1.0f, 0.647f, 0.0f);
        if (GUILayout.Button("Clear"))
        {
            layoutPath.Clear();
        }
    }
}