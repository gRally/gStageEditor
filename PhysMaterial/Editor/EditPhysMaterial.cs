using UnityEngine;
using UnityEditor;
using System.IO;
using System.Collections.Generic;
using UnityEngine.SceneManagement;

// https://unity3d.com/learn/tutorials/modules/beginner/live-training-archive/scriptable-objects

public class EditPhysMaterial : EditorWindow
{
    public PhysMaterialItemList matList;
    private List<Surface> surfList;
    private string[] surfNames;
    private int surfID;
    private int viewIndex = 1;
    string assetPath = "Assets/Stage.data.asset";

    [MenuItem("gRally/Edit Physics Materials", false, 51)]
    static void Init()
    {
        EditorWindow.GetWindow(typeof(EditPhysMaterial));
    }

    void OnEnable()
    {
        if (matList == null)
        {
            matList = ScriptableObject.CreateInstance<PhysMaterialItemList>();
            matList.physMaterialList = new List<PhysMaterialItem>();
        }

        var arrend = (Renderer[])Resources.FindObjectsOfTypeAll(typeof(Renderer));
        foreach (Renderer rend in arrend)
        {
            foreach (Material mat in rend.sharedMaterials)
            {
                try
                {
                    if (mat.shader.name.Contains("gRally/Phys"))
                    {
                        // found it!
                        bool found = false;
                        for (int i = 0; i < matList.physMaterialList.Count; i++)
                        {
                            if (matList.physMaterialList[i].itemName == mat.name)
                            {
                                found = true;
                            }
                        }
                        if (!found)
                        {
                            PhysMaterialItem item = new PhysMaterialItem();
                            item.itemName = mat.name;
                            item.physMaterial = mat.GetTexture("_PhysMap") as Texture2D;
                            item.renderMaterial = mat.GetTexture("_MainTex") as Texture2D;
                            matList.physMaterialList.Add(item);
                        }
                    }
                }
                catch
                {

                }
            }
        }

        // read the surfaces
        StageData stage = (StageData)AssetDatabase.LoadAssetAtPath(assetPath, typeof(StageData));
        surfList = stage.surfaceList;
        surfNames = new string[surfList.Count];
        for (int i = 0; i < surfList.Count; i++)
        {
            surfNames[i] = surfList[i].Name;
        }
        surfID = 0;

        if (matList.physMaterialList[viewIndex - 1].physMaterial == null)
        {
            CreateEmpty();
        }
        else
        {
            CreateFromTex();
        }
    }

    void OnGUI()
    {
        GUILayout.BeginHorizontal();
        GUILayout.Label("Physics Material Editor", EditorStyles.boldLabel);

        if (matList != null)
        {
            GUILayout.BeginHorizontal();

            GUILayout.Space(10);

            if (GUILayout.Button("Prev", GUILayout.ExpandWidth(false)))
            {
                if (viewIndex > 1)
                {
                    viewIndex--;
                    changeTex();
                }
            }
            GUILayout.Space(5);
            if (GUILayout.Button("Next", GUILayout.ExpandWidth(false)))
            {
                if (viewIndex < matList.physMaterialList.Count)
                {
                    viewIndex++;
                    changeTex();
                }
            }
            GUILayout.EndHorizontal();

            GUILayout.Space(60);
            if (matList.physMaterialList == null)
            {
                Debug.Log("wtf");
                return;
            }

            if (matList.physMaterialList.Count > 0)
            {
                GUILayout.BeginVertical();
                EditorGUILayout.LabelField(string.Format("{0} of {1} Material {2}", viewIndex, matList.physMaterialList.Count, matList.physMaterialList[viewIndex - 1].itemName));
                matList.physMaterialList[viewIndex - 1].Opacity = EditorGUILayout.Slider("Opacity", matList.physMaterialList[viewIndex - 1].Opacity, 0.0f, 1.0f);
                GUILayout.EndVertical();

                GUI.color = Color.white;
                GUI.DrawTexture(new Rect(50.0f, 60.0f, 512, 512), matList.physMaterialList[viewIndex - 1].renderMaterial, ScaleMode.StretchToFill, false);
                GUI.color = new Color(1.0f, 1.0f, 1.0f, matList.physMaterialList[viewIndex - 1].Opacity);
                GUI.DrawTexture(new Rect(50.0f, 60.0f, 512, 512), debugTex, ScaleMode.StretchToFill);
                GUI.color = Color.white;

                for (int i = 0; i < 16; i++)
                {
                    GUILayout.BeginArea(new Rect(10.0f, 68.0f + i * 32.0f, 80.0f, 32.0f));
                    matList.physMaterialList[viewIndex - 1].EditY[i] = GUILayout.Toggle(matList.physMaterialList[viewIndex -1].EditY[i], i.ToString());
                    GUILayout.EndArea();
                }

                for (int i = 0; i < 16; i++)
                {
                    GUILayout.BeginArea(new Rect(50.0f + i * 32.0f, 44.0f, 32.0f, 32.0f));
                    matList.physMaterialList[viewIndex - 1].EditX[i] = GUILayout.Toggle(matList.physMaterialList[viewIndex - 1].EditX[i], i.ToString());
                    GUILayout.EndArea();
                }

                GUILayout.BeginArea(new Rect(620, 60.0f, 200.0f, 500.0f));
                surfID = EditorGUILayout.Popup(surfID, surfNames);
                GUI.color = Color.green;
                if(GUILayout.Button("Paint"))
                {
                    PaintSelected();
                    EditorUtility.SetDirty(matList);
                }
                GUI.color = Color.white;

                GUILayout.Space(10);
                GUILayout.BeginHorizontal();
                if (GUILayout.Button("All X"))
                {
                    for (int i = 0; i < 16; i++)
                    {
                        matList.physMaterialList[viewIndex - 1].EditX[i] = true;
                    }
                }
                if (GUILayout.Button("None X"))
                {
                    for (int i = 0; i < 16; i++)
                    {
                        matList.physMaterialList[viewIndex - 1].EditX[i] = false;
                    }
                }
                GUILayout.EndHorizontal();

                GUILayout.BeginHorizontal();
                if (GUILayout.Button("All Y"))
                {
                    for (int i = 0; i < 16; i++)
                    {
                        matList.physMaterialList[viewIndex - 1].EditY[i] = true;
                    }
                }
                if (GUILayout.Button("None Y"))
                {
                    for (int i = 0; i < 16; i++)
                    {
                        matList.physMaterialList[viewIndex - 1].EditY[i] = false;
                    }
                }
                GUILayout.EndHorizontal();

                GUILayout.Space(10);
                GUI.color = Color.yellow;
                if (GUILayout.Button("Save"))
                {
                    var texName = string.Format("Assets/PhysTextures/ph_{0}.png", matList.physMaterialList[viewIndex - 1].itemName);
                    if (!Directory.Exists("Assets/PhysTextures"))
                    {
                        Directory.CreateDirectory("Assets/PhysTextures");
                    }

                    if (File.Exists(texName))
                    {
                        File.Delete(texName);
                    }
                    byte[] bytes = debugTex.EncodeToPNG();
                    File.WriteAllBytes(texName, bytes);

                    var arrend = (Renderer[])Resources.FindObjectsOfTypeAll(typeof(Renderer));
                    foreach (Renderer rend in arrend)
                    {
                        foreach (Material mat in rend.sharedMaterials)
                        {
                            if (mat != null)
                            {
                                if (mat.name == matList.physMaterialList[viewIndex - 1].itemName)
                                {
                                    var tex = AssetDatabase.LoadAssetAtPath<Texture>(texName);
                                    mat.SetTexture("_PhysMap", tex);
                                    AssetDatabase.Refresh();
                                }
                            }
                        }
                    }
                }
                GUILayout.EndArea();
            }
            else
            {
                GUILayout.Label("This Inventory List is Empty.");
            }
        }
        if (GUI.changed)
        {
            EditorUtility.SetDirty(matList);
        }
    }

    void changeTex()
    {
        if (matList.physMaterialList[viewIndex - 1].physMaterial == null)
        {
            CreateEmpty();
        }
        else
        {
            CreateFromTex();
        }
    }

    void CreateEmpty()
    {
        debugTex = new Texture2D(512, 512, TextureFormat.RGB24, false, true);
    }

    Texture2D debugTex;
    void CreateFromTex()
    {
        string path = AssetDatabase.GetAssetPath(matList.physMaterialList[viewIndex - 1].physMaterial);
        TextureImporter A = (TextureImporter)AssetImporter.GetAtPath(path);
        if (A == null)
        {
            return;
        }
        A.isReadable = true;
        A.linearTexture = true;
        A.mipmapEnabled = false;
        A.filterMode = FilterMode.Point;
        AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);
        
        debugTex = new Texture2D(512, 512, TextureFormat.RGB24, false);
        var pixls = matList.physMaterialList[viewIndex - 1].physMaterial.GetPixels();
        debugTex.SetPixels(pixls);
        debugTex.Apply();
    }

    void PaintSelected()
    {
        var col = surfList[surfID].PhysColor;
        for (int x = 0; x < 16; x++)
        {
            if (matList.physMaterialList[viewIndex - 1].EditX[x])
            {
                for (int y = 0; y < 16; y++)
                {
                    if (matList.physMaterialList[viewIndex - 1].EditY[15 - y])
                    {
                        // need to draw 32x32
                        int startX = x * 32;
                        int startY = y * 32;
                        for (int px = 0; px < 32; px++)
                        {
                            for (int py = 0; py < 32; py++)
                            {
                                debugTex.SetPixel(startX + px, startY + py, col);
                            }
                        }
                    }
                }
            }
        }
        debugTex.Apply();
    }
}