﻿using UnityEngine;
using System.Collections;
using UnityEditor;
using UnityEngine.SceneManagement;
using System.Collections.Generic;
using System.IO;
using System;
using System.Globalization;
using UnityEditor.SceneManagement;
using UnityEngine.Rendering;
using Object = UnityEngine.Object;
using System.IO.Compression;

public class ExportStages
{
    static string assetPath = "Assets/Stage.data.asset";
    static Dictionary<string, int> PhysMatNames;
    static Dictionary<string, float> PhysMatDisplacement;

    [MenuItem("gRally/Export Stage", false, 99)]
    static void ExportStage()
    {
        PhysMatNames = null;
        PhysMatDisplacement = null;

        EditorUserBuildSettings.SwitchActiveBuildTarget(BuildTargetGroup.Standalone, BuildTarget.StandaloneWindows);

        StageData stage = (StageData)AssetDatabase.LoadAssetAtPath(assetPath, typeof(StageData));

        string path = EditorUtility.OpenFolderPanel("Save Stage", stage.exportPath, "");

        if (!string.IsNullOrEmpty(path))
        {
            stage.exportPath = path;

            // 1: save scenes
            for (int i = 0; i < SceneManager.sceneCount; i++)
            {
                EditorSceneManager.SaveScene(SceneManager.GetSceneAt(i));
            }

            // 2: clear old files
            foreach (var item in Directory.GetFiles(path))
            {
                var fileName = Path.GetFileName(item).ToLower();
                if (fileName.EndsWith(".manifest") ||
                    fileName == "stage.grpack" ||
                    (fileName.StartsWith("layout") && fileName.EndsWith(".grpack"))||
                    fileName == Path.GetFileName(path).ToLower() ||
                    fileName == "stage.xml")
                {
                    File.Delete(item);
                }
            }

            EditorUtility.SetDirty(stage);
            AssetDatabase.SaveAssets();

            /* TODO: removed, no VertexPainter attached
            // 3: apply vertex data
            foreach (var item in Object.FindObjectsOfType<JBooth.VertexPainterPro.VertexInstanceStream>())
            {
                item.Apply();
            }
            */
            // 4: store xml data
            // write data stages
            gUtility.CXml stageXml = new gUtility.CXml(path + @"/stage.xml", true);

            writeSurfaceSettings(ref stageXml, ref stage);
            writeStageSettings(ref stageXml, ref stage);
            writeLayoutSettings(ref stageXml);
            writeMaterialSettings(ref stageXml, ref stage);

            stageXml.Commit();

            // dump collision
            if (PhysMatNames != null)
            {
                CreateCollision(path);
            }

            AssetDatabase.SaveAssets();

            // 5: rollback the textures edited:
            // not at the moment... rollbackEditTextures();
            // 6: build stage!
            BuildPipeline.BuildAssetBundles(path, BuildAssetBundleOptions.ForceRebuildAssetBundle, BuildTarget.StandaloneWindows64);
            EditorUtility.DisplayDialog("Create Stage", "Stage created in\r\n" + path, "Ok!!");
        }
        else
        {
            EditorUtility.DisplayDialog("Create Stage", "no path selected!!", "Ok.. I'll try again");
        }
    }

    static void writeSurfaceSettings(ref gUtility.CXml xml, ref StageData stage)
    {
        for (int i = 0; i < stage.surfaceList.Count; i++)
        {
            var s = stage.surfaceList[i];
            var SURF = string.Format("SurfaceLibrary/Surface#{0}", i + 1);
            xml.Settings[SURF].WriteString("type", s.Type.ToString());
            xml.Settings[SURF].WriteString("name", s.Name);
            xml.Settings[SURF].WriteString("color", c3(s.PhysColor));

            var PHYS = string.Format("SurfaceLibrary/Surface#{0}/Phys", i + 1);
            xml.Settings[PHYS].WriteFloat("usableGrip", s.UsableGrip);
            xml.Settings[PHYS].WriteFloat("rolling", s.Rolling);
            xml.Settings[PHYS].WriteFloat("drag", s.Drag);
            xml.Settings[PHYS].WriteInt("octaves", s.Octaves);
            xml.Settings[PHYS].WriteFloat("persistance", s.Persistance);
            xml.Settings[PHYS].WriteFloat("lacunarity", s.Lacunarity);
            xml.Settings[PHYS].WriteFloat("scale", s.Scale);
            xml.Settings[PHYS].WriteFloat("scaleBump", s.ScaleBump);

            var TRAILS = string.Format("SurfaceLibrary/Surface#{0}/Trails", i + 1);
            xml.Settings[TRAILS].WriteString("trailColor", c4(s.TrailColor));
            xml.Settings[TRAILS].WriteFloat("trailBump", s.TrailBump);

            var SMOKE = string.Format("SurfaceLibrary/Surface#{0}/Smoke", i + 1);
            xml.Settings[SMOKE].WriteVector2("lifeTime", v2(s.LifeTime));
            xml.Settings[SMOKE].WriteVector2("size", v2(s.Size));
            xml.Settings[SMOKE].WriteFloat("gravity", s.Gravity);
            xml.Settings[SMOKE].WriteString("gradient", gradient(s.GradientColor));
        }
    }

    static void writeStageSettings(ref gUtility.CXml xml, ref StageData stage)
    {
        xml.Settings["Stage/Geo"].WriteFloat("latitude", stage.latitude);
        xml.Settings["Stage/Geo"].WriteFloat("longitude", stage.longitude);
        xml.Settings["Stage/Geo"].WriteFloat("north", stage.north);
    }

    static void writeLayoutSettings(ref gUtility.CXml xml, int maxLayouts = 50)
    {
        for (int i = 0; i < maxLayouts; i++)
        {
            var scene = SceneManager.GetSceneByName("layout" + i.ToString());
            if (scene.name == null)
            {
                break;
            }

            foreach (var item in scene.GetRootGameObjects())
            {
                var info = item.GetComponentInChildren<LayoutInfo>();
                var startFinish = item.GetComponentInChildren<StartFinish>();
                var path = item.GetComponentInChildren<LayoutPath>();
                if (info != null)
                {
                    xml.Settings[string.Format("Layouts/Layout{0}", i)].WriteString("name", info.Name);
                    xml.Settings[string.Format("Layouts/Layout{0}", i)].WriteString("description", info.Description);
                    xml.Settings[string.Format("Layouts/Layout{0}", i)].WriteBool("saveTimes", info.SaveTimes);
                    xml.Settings[string.Format("Layouts/Layout{0}", i)].WriteString("nation", info.GetCountryCode(true));
                    xml.Settings[string.Format("Layouts/Layout{0}", i)].WriteString("surfaces", info.GetSurfaces());
                    xml.Settings[string.Format("Layouts/Layout{0}", i)].WriteString("tags", info.Tags);
                    //break;
                }
                if (startFinish != null)
                {
                    float realLength = startFinish.RealLength;
                    // calc points:
                    int allPoints = path.GetPointsCount();
                    // I want a point each 5 meters
                    float minDist = realLength / Convert.ToSingle(allPoints);

                    int eachPoint = 1;
                    if (minDist < 5.0f)
                    {
                        // less than 5 meters, use less points
                        int newPoints = Convert.ToInt32(Mathf.Ceil(realLength / 5.0f));
                        eachPoint = Convert.ToInt32(Mathf.Floor(allPoints / newPoints));
                    }

                    xml.Settings[string.Format("Layouts/Layout{0}", i)].WriteFloat("length", realLength);
                    if (path != null)
                    {
                        string pointExport = "";
                        for (int pt = 0; pt < path.GetPointsCount(); pt += eachPoint)
                        {
                            var point = path.GetPoint(pt);
                            pointExport += string.Format(CultureInfo.InvariantCulture, "{0} {1} {2} ", point.x, point.y, point.z);
                        }
                        pointExport = pointExport.Trim();
                        xml.Settings[string.Format("Layouts/Layout{0}", i)].WriteString("points", pointExport);
                    }
                }
            }
        }
    }

    static List<string> matExported;
    static void writeMaterialSettings(ref gUtility.CXml xml, ref StageData stage)
    {
        int idMat = 0;
        matExported = new List<string>();
        PhysMatNames = new Dictionary<string, int>();
        PhysMatDisplacement = new Dictionary<string, float>();
        var renderers = (Renderer[])Resources.FindObjectsOfTypeAll(typeof(Renderer));
        foreach (Renderer renderer in renderers)
        {
            foreach (Material mat in renderer.sharedMaterials)
            {
                if (mat != null)
                {
                    if (mat.shader.name.Contains("gRally/Phys"))
                    {
                        Texture tex = null;
                        Texture texWet = null;
                        Texture texPuddles = null;
                        float puddlesSize = 1.0f;
                        int shaderVer = 0;
                        if (mat.shader.name.EndsWith("1"))
                        {
                            shaderVer = 1;
                            tex = mat.GetTexture("_PhysMap");
                            texWet = mat.GetTexture("_MainTex");
                            xml.Settings[string.Format("Materials/Material#{0}", idMat + 1)].WriteFloat("maxDisplacement", 0.0f);

                            if (!PhysMatNames.ContainsKey(mat.name))
                            {
                                PhysMatNames.Add(mat.name, idMat);
                                PhysMatDisplacement.Add(mat.name, 0.0f);
                            }
                        }
                        else if (mat.shader.name.EndsWith("2"))
                        {
                            shaderVer = 2;
                            tex = mat.GetTexture("_PhysicalTexture");
                            texWet = mat.GetTexture("_RSpecGTransparencyBAOAWetMap");
                            texPuddles = mat.GetTexture("_PuddlesTexture");
                            puddlesSize = mat.GetFloat("_PuddlesSize");
                            xml.Settings[string.Format("Materials/Material#{0}", idMat + 1)].WriteFloat("maxDisplacement", mat.GetFloat("_MaxDisplacementmeters"));

                            if (!PhysMatNames.ContainsKey(mat.name))
                            {
                                PhysMatNames.Add(mat.name, idMat);
                                PhysMatDisplacement.Add(mat.name, mat.GetFloat("_MaxDisplacementmeters"));
                            }
                        }
                        else if (mat.shader.name.EndsWith("3"))
                        {
                            shaderVer = 3;
                            tex = mat.GetTexture("_PhysicalTexture");
                            texWet = mat.GetTexture("_RSpecGTransparencyBAOAWetMap");
                            texPuddles = mat.GetTexture("_PuddlesTexture");
                            puddlesSize = mat.GetFloat("_PuddlesSize");
                            xml.Settings[string.Format("Materials/Material#{0}", idMat + 1)].WriteFloat("maxDisplacement", mat.GetFloat("_MaxDisplacementmeters"));

                            if (!PhysMatNames.ContainsKey(mat.name))
                            {
                                PhysMatNames.Add(mat.name, idMat);
                                PhysMatDisplacement.Add(mat.name, mat.GetFloat("_MaxDisplacementmeters"));
                            }
                        }
                        if (tex != null)
                        {
                            if (!matExported.Contains(mat.name))
                            {
                                getPhysicsData(idMat, tex as Texture2D, mat.name, ref xml, ref stage);
                                getWetData(idMat, texWet as Texture2D, 16, mat.name, ref xml);
                                if (texPuddles != null)
                                {
                                    getPuddlesData(idMat, texPuddles as Texture2D, 32, mat.name, puddlesSize, ref xml);
                                }
                                idMat++;
                                matExported.Add(mat.name);
                            }
                        }
                    }
                }
            }
        }
    }

    static void getWetData(int idMat, Texture2D tex, int wetSize, string materialName, ref gUtility.CXml xml)
    {
        if (tex == null)
        {
            return;
        }
        string path = AssetDatabase.GetAssetPath(tex);
        TextureImporter A = (TextureImporter)AssetImporter.GetAtPath(path);
        if (A == null)
        {
            return;
        }
        A.isReadable = true;
        AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);

        float[,] colors = new float[wetSize, wetSize];

        // save the new texture
        var debugTex = new Texture2D(tex.width, tex.height, tex.format, tex.mipmapCount > 0, true);
        Graphics.CopyTexture(tex, debugTex);
        debugTex.Apply();
        debugTex = scaleTexture(debugTex, wetSize, wetSize);

        for (int y = 0; y < wetSize; y++)
        {
            for (int x = 0; x < wetSize; x++)
            {
                var color = debugTex.GetPixel(x, y);
                var wet = color.a;
                /*
                if (shaderVersion == 2)
                {
                    wet = 1.0f + wet * -1.0f;
                }
                */
                debugTex.SetPixel(x, y, new Color(wet, wet, wet, 1.0f));
                colors[x, y] = wet;
            }
        }
        debugTex.Apply();

        var texName = string.Format("Assets/PhysTextures/wet_{0}.png", materialName);
        if (!Directory.Exists("Assets/PhysTextures"))
        {
            Directory.CreateDirectory("Assets/PhysTextures");
        }

        try
        {
            if (File.Exists(texName))
            {
                File.Delete(texName);
            }
        }
        catch (Exception ex)
        {
            Debug.LogWarning(ex.ToString());
        }
        byte[] bytes = debugTex.EncodeToPNG();
        File.WriteAllBytes(texName, bytes);

        string retWet = "";
        for (int y = 0; y < wetSize; y++)
        {
            for (int x = 0; x < wetSize; x++)
            {
                retWet += colors[x, y].ToString(CultureInfo.InvariantCulture) + " ";
            }
        }
        // retWet = retWet.Trim().Replace(",", ".");
        xml.Settings[string.Format("Materials/Material#{0}", idMat + 1)].WriteString("wet", retWet);
    }

    static void getPuddlesData(int idMat, Texture2D tex, int wetSize, string materialName, float puddleSize, ref gUtility.CXml xml)
    {
        if (tex == null)
        {
            return;
        }
        string path = AssetDatabase.GetAssetPath(tex);
        TextureImporter A = (TextureImporter)AssetImporter.GetAtPath(path);
        if (A == null)
        {
            return;
        }
        A.isReadable = true;
        AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);

        float[,] colors = new float[wetSize * 2, wetSize * 2];

        // save the new texture
        var debugTexR = new Texture2D(tex.width, tex.height, tex.format, tex.mipmapCount > 0, true);
        Graphics.CopyTexture(tex, debugTexR);
        debugTexR.Apply();
        debugTexR = scaleTexture(debugTexR, wetSize, wetSize);

        var debugTexG = new Texture2D(tex.width, tex.height, tex.format, tex.mipmapCount > 0, true);
        Graphics.CopyTexture(tex, debugTexG);
        debugTexG.Apply();
        debugTexG = scaleTexture(debugTexG, wetSize, wetSize);

        var debugTexB = new Texture2D(tex.width, tex.height, tex.format, tex.mipmapCount > 0, true);
        Graphics.CopyTexture(tex, debugTexB);
        debugTexB.Apply();
        debugTexB = scaleTexture(debugTexB, wetSize, wetSize);

        var debugTexA = new Texture2D(tex.width, tex.height, tex.format, tex.mipmapCount > 0, true);
        Graphics.CopyTexture(tex, debugTexA);
        debugTexA.Apply();
        debugTexA = scaleTexture(debugTexA, wetSize, wetSize);

        var debugTex = new Texture2D(wetSize * 2, wetSize * 2, TextureFormat.ARGB32, false);

        /*
         * |B|A|
         * -----
         * |R|G|
         */
        for (int y = 0; y < wetSize * 2; y++)
        {
            for (int x = 0; x < wetSize * 2; x++)
            {
                if (x < wetSize)
                {
                    if (y < wetSize)
                    {
                        // R
                        var color = debugTexR.GetPixel(x, y);
                        var wet = color.r;
                        debugTex.SetPixel(x, y, new Color(wet, wet, wet, 1.0f));
                        colors[x, y] = wet;
                    }
                    else
                    {
                        // B
                        var color = debugTexB.GetPixel(x, y - wetSize);
                        var wet = color.b;
                        debugTex.SetPixel(x, y, new Color(wet, wet, wet, 1.0f));
                        colors[x, y] = wet;
                    }
                }
                else
                {
                    if (y < wetSize)
                    {
                        // G
                        var color = debugTexG.GetPixel(x - wetSize, y);
                        var wet = color.g;
                        debugTex.SetPixel(x, y, new Color(wet, wet, wet, 1.0f));
                        colors[x, y] = wet;
                    }
                    else
                    {
                        // A
                        var color = debugTexA.GetPixel(x - wetSize, y - wetSize);
                        var wet = color.a;
                        debugTex.SetPixel(x, y, new Color(wet, wet, wet, 1.0f));
                        colors[x, y] = wet;
                    }
                }
            }
        }
        debugTex.Apply();

        if (!Directory.Exists("Assets/PhysTextures"))
        {
            Directory.CreateDirectory("Assets/PhysTextures");
        }
        var texName = string.Format("Assets/PhysTextures/puddles_{0}.png", materialName);
        if (File.Exists(texName)) File.Delete(texName);
        byte[] bytes = debugTex.EncodeToPNG();
        File.WriteAllBytes(texName, bytes);

        string retWet = "";
        for (int y = 0; y < wetSize; y++)
        {
            for (int x = 0; x < wetSize; x++)
            {
                retWet += colors[x, y].ToString(CultureInfo.InvariantCulture) + " ";
            }
        }
        // retWet = retWet.Trim().Replace(",", ".");
        xml.Settings[string.Format("Materials/Material#{0}", idMat + 1)].WriteFloat("puddlesSize", puddleSize);
        xml.Settings[string.Format("Materials/Material#{0}", idMat + 1)].WriteString("puddles", retWet);
    }

    static Texture2D scaleTexture(Texture2D source, int targetWidth, int targetHeight)
    {
        Texture2D result = new Texture2D(targetWidth, targetHeight);
        Color[] rpixels = result.GetPixels();
        float incX = ((float)1 / source.width) * ((float)source.width / targetWidth);
        float incY = ((float)1 / source.height) * ((float)source.height / targetHeight);
        for (int px = 0; px < rpixels.Length; px++)
        {
            rpixels[px] = source.GetPixelBilinear(incX * ((float)px % targetWidth), incY * Mathf.Floor((float)px / targetWidth));
        }
        result.SetPixels(rpixels);
        result.Apply();
        return result;
    }

    static void getPhysicsData(int idMat, Texture2D tex, string materialName, ref gUtility.CXml xml, ref StageData stage)
    {
        if (tex == null)
        {
            return;
        }
        string path = AssetDatabase.GetAssetPath(tex);
        TextureImporter A = (TextureImporter)AssetImporter.GetAtPath(path);
        if (A == null)
        {
            return;
        }
        A.sRGBTexture = true;
        A.isReadable = true;
        A.mipmapEnabled = false;
        A.filterMode = FilterMode.Point;
        AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);

        Color32[,] colors = new Color32[16, 16];

        int stepPx = tex.width / 16;
        int firstPx = stepPx / 2;

        for (int x = 0; x < 16; x++)
        {
            for (int y = 0; y < 16; y++)
            {
                colors[x, y] = tex.GetPixel(x * stepPx + firstPx, y * stepPx + firstPx);
            }
        }
        bool singleColor = true;
        bool singleColumns = true;

        // check if is everything the same
        var firstCol = colors[0, 0];
        for (int x = 0; x < 16; x++)
        {
            for (int y = 0; y < 16; y++)
            {
                if (!equal(colors[x, y], firstCol))
                {
                    singleColor = false;
                    break;
                }
            }
            if (!singleColor)
            {
                break;
            }
        }

        if (!singleColor)
        {
            // check if is by columns
            for (int x = 0; x < 16; x++)
            {
                firstCol = colors[x, 0];
                for (int y = 0; y < 16; y++)
                {
                    if (!equal(colors[x, y], firstCol))
                    {
                        singleColumns = false;
                        break;
                    }
                }
                if (!singleColumns)
                {
                    break;
                }
            }
        }

        if (singleColor)
        {
            xml.Settings[string.Format("Materials/Material#{0}", idMat + 1)].WriteString("name", materialName);
            xml.Settings[string.Format("Materials/Material#{0}", idMat + 1)].WriteString("surface", getStageID(ref stage, colors[0, 0]).ToString());
        }
        else if (singleColumns)
        {
            string retID = "";
            for (int x = 0; x < 16; x++)
            {
                retID += getStageID(ref stage, colors[x, 0]).ToString() + " ";
            }
            xml.Settings[string.Format("Materials/Material#{0}", idMat + 1)].WriteString("name", materialName);
            xml.Settings[string.Format("Materials/Material#{0}", idMat + 1)].WriteString("surface", retID.Trim());
        }
        else
        {
            string retID = "";
            for (int y = 0; y < 16; y++)
            {
                for (int x = 0; x < 16; x++)
                {
                    retID += getStageID(ref stage, colors[x, y]).ToString() + " ";
                }
            }
            xml.Settings[string.Format("Materials/Material#{0}", idMat + 1)].WriteString("name", materialName);
            xml.Settings[string.Format("Materials/Material#{0}", idMat + 1)].WriteString("surface", retID.Trim());
        }
    }

    static void rollbackEditTextures()
    {
        var renderers = (Renderer[])Resources.FindObjectsOfTypeAll(typeof(Renderer));
        foreach (Renderer renderer in renderers)
        {
            foreach (Material mat in renderer.sharedMaterials)
            {
                if (mat != null)
                {
                    if (mat.shader.name.Contains("gRally/Phys"))
                    {
                        var mainTex = mat.GetTexture("_MainTex");
                        string path = AssetDatabase.GetAssetPath(mainTex);
                        TextureImporter A = (TextureImporter)AssetImporter.GetAtPath(path);
                        if (A == null)
                        {
                            return;
                        }
                        A.isReadable = false;
                        AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);

                        var texPhys = mat.GetTexture("_PhysMap");
                        if (texPhys != null)
                        {
                            path = AssetDatabase.GetAssetPath(texPhys);
                            A = (TextureImporter)AssetImporter.GetAtPath(path);
                            if (A == null)
                            {
                                return;
                            }
                            A.isReadable = false;
                            AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);
                        }
                    }
                }
            }
        }
    }

    /// <summary>
    /// create baked collision
    /// </summary>
    /// <param name="exportPath"></param>
    /// <param name="maxLayouts"></param>
    static void CreateCollision(string exportPath, int maxLayouts = 50)
    {
        int layerIndex = LayerMask.NameToLayer("COLLISION");

        // main scene
        bool createMain = true;
        if (File.Exists(exportPath + @"\stage.col"))
        {
            createMain = EditorUtility.DisplayDialog("Collision exists", "a stage collision exists: regenerate?", "Yes", "No");
        }
        if (createMain)
        {
            var colMain = CreateSceneCollision(SceneManager.GetSceneByName("stage"));
            SaveCollision(colMain, exportPath + @"\stage.col");
        }

        // layouts
        for (int i = 0; i < maxLayouts; i++)
        {
            var scene = SceneManager.GetSceneByName("layout" + i.ToString());
            if (scene.name == null)
            {
                break;
            }

            bool createLayout = true;
            if (File.Exists(exportPath + string.Format(@"\layout{0}.col", i)))
            {
                createLayout = EditorUtility.DisplayDialog("Collision exists", string.Format("a layout {0} collision exists: regenerate?", i), "Yes", "No");
            }
            if (createLayout)
            {
                var colLayout = CreateSceneCollision(scene);
                SaveCollision(colLayout, exportPath + string.Format(@"\layout{0}.col", i));
            }
        }
    }

    /// <summary>
    /// save the collision to a file
    /// </summary>
    /// <param name="collision"></param>
    /// <param name="fileName"></param>
    static void SaveCollision(List<CollTriangle> collision, string fileName)
    {
        if (collision.Count > 0)
        {
            var byteStream = new List<byte>();
            foreach (var item in collision)
            {
                byteStream.AddRange(item.Bytes());
            }
            
            var data = byteStream.ToArray();
            MemoryStream output = new MemoryStream();
            using (DeflateStream dstream = new DeflateStream(output, CompressionMode.Compress))
            {
                dstream.Write(data, 0, data.Length);
            }
            
            File.WriteAllBytes(fileName, output.ToArray());
        }
    }

    /// <summary>
    /// create the collision from a scene
    /// </summary>
    /// <param name="scene"></param>
    /// <returns></returns>
    static List<CollTriangle> CreateSceneCollision(Scene scene)
    {
        var collision = new List<CollTriangle>();
        int layerIndex = LayerMask.NameToLayer("COLLISION");
        var C = new Color(0.0f, 0.0f, 0.0f, 0.0f);

        foreach (var item in scene.GetRootGameObjects())
        {
            var cols = item.GetComponentsInChildren<MeshFilter>();
            foreach (var col in cols)
            {
                if (col == null)
                {
                    continue;
                }
                if (col.gameObject.layer == layerIndex)
                {
                    if (Debug.isDebugBuild)
                    {
                        Debug.Log("parsing: " + col.name);
                    }
                    /*
                    MeshFilter filter = col.GetComponent<MeshFilter>();

                    if (filter == null)
                    {
                        continue;
                    }
                    */
                    var fStatic = col.gameObject.isStatic;
                    col.gameObject.isStatic = false;
                    Renderer rend = col.GetComponent<Renderer>();
                    var matrix = col.transform.localToWorldMatrix;
                    Mesh mesh = col.sharedMesh;

                    try
                    {
                        Vector3[] vert = mesh.vertices;
                        Vector3[] norm = mesh.normals;
                        Vector2[] uv = mesh.uv;
                        Color[] colors = mesh.colors;

                        if (mesh.vertices.Length == 0)
                        {
                            Debug.LogWarning("Empty mesh: " + col.name);
                            continue;
                        }

                        if (uv.Length < mesh.vertices.Length)
                        {
                            uv = new Vector2[mesh.vertices.Length];
                        }

                        for (int i = 0; i < mesh.subMeshCount; i++)
                        {
                            int[] triangles = mesh.GetTriangles(i);
                            if (triangles.Length == 0)
                            {
                                continue;
                            }

                            int matID = 0;
                            float disp = 0.0f;

                            if (rend.sharedMaterials.Length > matID)
                            {
                                PhysMatNames.TryGetValue(rend.sharedMaterials[i].name, out matID);
                                PhysMatDisplacement.TryGetValue(rend.sharedMaterials[i].name, out disp);
                                // #todo disp = sim.GetMaxDisplacement(rend.sharedMaterials[i].name) * GRConfig.Instance.Usage;
                            }

                            for (int t = 0; t < triangles.Length; t += 3)
                            {
                                Vector3 p1 = vert[triangles[t + 0]];
                                Vector3 p2 = vert[triangles[t + 1]];
                                Vector3 p3 = vert[triangles[t + 2]];

                                p1 = matrix.MultiplyPoint(p1);
                                p2 = matrix.MultiplyPoint(p2);
                                p3 = matrix.MultiplyPoint(p3);

                                Vector3 n1 = norm[triangles[t + 0]];
                                Vector3 n2 = norm[triangles[t + 1]];
                                Vector3 n3 = norm[triangles[t + 2]];

                                n1 = matrix * n1;
                                n2 = matrix * n2;
                                n3 = matrix * n3;

                                Vector2 uv1 = uv[triangles[t + 0]];
                                Vector2 uv2 = uv[triangles[t + 1]];
                                Vector2 uv3 = uv[triangles[t + 2]];

                                var c1 = C;
                                var c2 = C;
                                var c3 = C;
                                if (colors != null && colors.Length > 0)
                                {
                                    c1 = colors[triangles[t + 0]];
                                    c2 = colors[triangles[t + 1]];
                                    c3 = colors[triangles[t + 2]];
                                }
                                //p1.y = p1.y + disp * c1.b;
                                //p2.y = p2.y + disp * c2.b;
                                //p3.y = p3.y + disp * c3.b;

                                collision.Add(new CollTriangle()
                                {
                                    P1 = p1,
                                    P2 = p2,
                                    P3 = p3,
                                    N1 = n1,
                                    N2 = n2,
                                    N3 = n3,
                                    UV1 = uv1,
                                    UV2 = uv2,
                                    UV3 = uv3,
                                    C1 = c1,
                                    C2 = c2,
                                    C3 = c3,
                                    MAT = matID
                                });

                            }
                        }
                        //Destroy(col.gameObject);
                    }
                    catch (Exception ex)
                    {
                        Debug.LogError(ex.ToString());
                    }
                    col.gameObject.isStatic = fStatic;
                }
            }
        }

        return collision;
    }

    // utility
    static bool equal(Color32 c1, Color32 c2, int diff = 2)
    {
        var diffR = Mathf.Abs(c1.r - c2.r);
        var diffG = Mathf.Abs(c1.g - c2.g);
        var diffB = Mathf.Abs(c1.b - c2.b);
        var diffA = Mathf.Abs(c1.a - c2.a);

        bool ret = diffR < diff && diffG < diff && diffB < diff && diffA < diff;
        return ret;
    }

    static int getStageID(ref StageData stage, Color32 value)
    {
        for (int i = 0; i < stage.surfaceList.Count; i++)
        {
            if (equal(value, stage.surfaceList[i].PhysColor))
            {
                return i;
            }
        }
        return -1;
    }

    static string c3(Color32 color)
    {
        return string.Format("{0:000} {1:000} {2:000}", color.r, color.g, color.b);
    }

    static string c4(Color32 color)
    {
        return string.Format("{0:000} {1:000} {2:000} {3:000}", color.r, color.g, color.b, color.a);
    }

    static gUtility.Vector2 v2(Vector2 value)
    {
        return new gUtility.Vector2(value.x, value.y);
    }

    static string gradient(Gradient color)
    {
        var ret = string.Format("{0};", color.colorKeys.Length);
        foreach (var k in color.colorKeys)
        {
            ret += string.Format("{0}_{1};", c4(k.color), k.time.ToString(CultureInfo.InvariantCulture.NumberFormat));
        }
        ret = ret.Remove(ret.Length - 1);

        ret += string.Format("|{0};", color.alphaKeys.Length);
        foreach (var a in color.alphaKeys)
        {
            ret += string.Format("{0}_{1};", a.alpha.ToString(CultureInfo.InvariantCulture.NumberFormat), a.time.ToString(CultureInfo.InvariantCulture.NumberFormat));
        }
        ret = ret.Remove(ret.Length - 1);
        ret += string.Format("|{0}", Convert.ToInt32(color.mode));
        return ret;
    }
}

public struct CollTriangle
{
    public Vector3 P1;
    public Vector3 P2;
    public Vector3 P3;

    public Vector3 N1;
    public Vector3 N2;
    public Vector3 N3;

    public Vector2 UV1;
    public Vector3 UV2;
    public Vector3 UV3;

    public Color C1;
    public Color C2;
    public Color C3;

    public int MAT;

    public int NumBytes()
    {
        var bytes = (3 * 3) + (3 * 3) + (2 * 3) + (4 * 3) + 1;
        return bytes;
    }

    public byte[] Bytes()
    {
        var byteStream = new List<byte>();

        // byteStream.AddRange(BitConverter.GetBytes(NumBytes()));
        byteStream.AddRange(BitConverter.GetBytes(P1.x));
        byteStream.AddRange(BitConverter.GetBytes(P1.z));
        byteStream.AddRange(BitConverter.GetBytes(P1.y));

        byteStream.AddRange(BitConverter.GetBytes(P2.x));
        byteStream.AddRange(BitConverter.GetBytes(P2.z));
        byteStream.AddRange(BitConverter.GetBytes(P2.y));

        byteStream.AddRange(BitConverter.GetBytes(P3.x));
        byteStream.AddRange(BitConverter.GetBytes(P3.z));
        byteStream.AddRange(BitConverter.GetBytes(P3.y));

        byteStream.AddRange(BitConverter.GetBytes(N1.x));
        byteStream.AddRange(BitConverter.GetBytes(N1.z));
        byteStream.AddRange(BitConverter.GetBytes(N1.y));

        byteStream.AddRange(BitConverter.GetBytes(N2.x));
        byteStream.AddRange(BitConverter.GetBytes(N2.z));
        byteStream.AddRange(BitConverter.GetBytes(N2.y));

        byteStream.AddRange(BitConverter.GetBytes(N3.x));
        byteStream.AddRange(BitConverter.GetBytes(N3.z));
        byteStream.AddRange(BitConverter.GetBytes(N3.y));

        byteStream.AddRange(BitConverter.GetBytes(UV1.x));
        byteStream.AddRange(BitConverter.GetBytes(UV1.y));

        byteStream.AddRange(BitConverter.GetBytes(UV2.x));
        byteStream.AddRange(BitConverter.GetBytes(UV2.y));

        byteStream.AddRange(BitConverter.GetBytes(UV3.x));
        byteStream.AddRange(BitConverter.GetBytes(UV3.y));

        byteStream.AddRange(BitConverter.GetBytes(C1.r));
        byteStream.AddRange(BitConverter.GetBytes(C1.g));
        byteStream.AddRange(BitConverter.GetBytes(C1.b));
        byteStream.AddRange(BitConverter.GetBytes(C1.a));

        byteStream.AddRange(BitConverter.GetBytes(C2.r));
        byteStream.AddRange(BitConverter.GetBytes(C2.g));
        byteStream.AddRange(BitConverter.GetBytes(C2.b));
        byteStream.AddRange(BitConverter.GetBytes(C2.a));

        byteStream.AddRange(BitConverter.GetBytes(C3.r));
        byteStream.AddRange(BitConverter.GetBytes(C3.g));
        byteStream.AddRange(BitConverter.GetBytes(C3.b));
        byteStream.AddRange(BitConverter.GetBytes(C3.a));

        byteStream.AddRange(BitConverter.GetBytes(MAT));

        return byteStream.ToArray();
    }
}