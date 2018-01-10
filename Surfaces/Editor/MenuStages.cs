using System.Collections;
using UnityEditor;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor.SceneManagement;
using System.IO;
using UnityEngine.SceneManagement;

public class MenuStages
{
    static string assetPath = "Assets/Stage.data.asset";

    [MenuItem("gRally/1. Create Layers", false, 1)]
    public static void CreateLayers()
    {
        if (File.Exists("ProjectSettings/TagManager.asset"))
        {
            File.Move("ProjectSettings/TagManager.asset", "ProjectSettings/TagManager.asset.bak");
        }
        File.Copy("Assets/gStageEditor/Resources/TagManager.asset.txt", "ProjectSettings/TagManager.asset");
        Debug.Log("Layers file created successfully.");
        Debug.Log("Remember to save the Project to validate the changes.");
    }

    [MenuItem("gRally/2. Create default stage data", false, 2)]
    public static void GenerateStageData()
    {
        StageData asset = ScriptableObject.CreateInstance<StageData>();
        AssetDatabase.CreateAsset(asset, assetPath);
        asset.surfaceList = new List<Surface>();
        asset.latitude = 44.4963904f;
        asset.longitude = 7.5847333f;
        asset.north = 78.0f;
        init(ref asset);

        EditorUtility.SetDirty(asset);
        AssetDatabase.SaveAssets();
        Debug.Log(string.Format("Stage data in {0} is created successfully.", assetPath));
    }

    [MenuItem("gRally/3. Create main, stage and layout0 scenes", false, 3)]
    public static void CreateMainScene()
    {
        if (!Directory.Exists("Assets/Scenes"))
        {
            Directory.CreateDirectory("Assets/Scenes");
        }

        if (!File.Exists("Assets/Scenes/main.unity"))
        {
            var main = EditorSceneManager.NewScene(NewSceneSetup.DefaultGameObjects, NewSceneMode.Single);
            EditorSceneManager.SaveScene(main, "Assets/Scenes/main.unity");
            EditorSceneManager.SetActiveScene(main);

            var path = "Assets/gStageEditor/Resources/CarSimulator.prefab";
            var carSim = UnityEditor.AssetDatabase.LoadAssetAtPath<GameObject>(path);
            PrefabUtility.InstantiatePrefab(carSim);
            /*
            var go = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            go.name = "CarSimulator";
            go.transform.localScale = new Vector3(2.0f, 2.0f, 2.0f);

            foreach (var item in Resources.FindObjectsOfTypeAll<Material>())
            {
                if (item.name == "CarSimulator")
                {
                    go.GetComponent<Renderer>().sharedMaterial = item;
                }
            }
            */
            var camActual = new GameObject();
            camActual.AddComponent<Camera>();
            camActual.name = "ReplayActual";
            var camNext = new GameObject();
            camNext.AddComponent<Camera>();
            camNext.name = "ReplayNext";
            var debugPhys = new GameObject();
            debugPhys.AddComponent<DebugPhysMaterials>();
            debugPhys.name = "DebugPhys";
        }

        if (!File.Exists("Assets/Scenes/stage.unity"))
        {
            var stage = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Additive);
            EditorSceneManager.SaveScene(stage, "Assets/Scenes/stage.unity");
            var stageAsset = AssetImporter.GetAtPath("Assets/Scenes/stage.unity");
            stageAsset.assetBundleName = "stage.grpack";
            stageAsset.SaveAndReimport();
        }

        if (!File.Exists("Assets/Scenes/layout0.unity"))
        {
            var layout = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Additive);
            EditorSceneManager.SaveScene(layout, "Assets/Scenes/layout0.unity");

            EditorSceneManager.SetActiveScene(layout);
            var go = new GameObject("layout0");
            go.AddComponent<LayoutInfo>();
            go.AddComponent<LayoutPath>();
            go.AddComponent<StartFinish>();
            go.AddComponent<ReplayCameras>();

            var layoutAsset = AssetImporter.GetAtPath("Assets/Scenes/layout0.unity");
            layoutAsset.assetBundleName = "layout0.grpack";
            layoutAsset.SaveAndReimport();
            EditorSceneManager.MarkAllScenesDirty();
        }

        SceneManager.SetActiveScene(SceneManager.GetSceneByName("main"));
    }

    [MenuItem("gRally/4. Create new layout", false, 4)]
    public static void CreateNewLayout()
    {
        if (!Directory.Exists("Assets/Scenes"))
        {
            EditorUtility.DisplayDialog("No basic scenes!", "Seems that the basic scenes are not created..\r\nPlease create!", "Ok!!");
            return;
        }
        int maxLayouts = 50;
        int newLayoutID = 0;
        for (newLayoutID = 0; newLayoutID < maxLayouts; newLayoutID++)
        {
            var scene = SceneManager.GetSceneByName("layout" + newLayoutID.ToString());
            if (scene.name == null)
            {
                break;
            }
        }

        string newLayoutName = "layout" + newLayoutID.ToString();
        string newLayoutPath = string.Format("Assets/Scenes/{0}.unity", newLayoutName);
        if (!File.Exists(newLayoutPath))
        {
            var layout = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Additive);
            EditorSceneManager.SaveScene(layout, newLayoutPath);

            EditorSceneManager.SetActiveScene(layout);
            var go = new GameObject(newLayoutName);
            go.AddComponent<LayoutInfo>();
            go.AddComponent<LayoutPath>();
            go.AddComponent<StartFinish>();
            go.AddComponent<ReplayCameras>();

            var layoutAsset = AssetImporter.GetAtPath(newLayoutPath);
            layoutAsset.assetBundleName = newLayoutName + ".grpack";
            layoutAsset.SaveAndReimport();
            EditorSceneManager.MarkSceneDirty(layout);
        }
        else
        {
            EditorUtility.DisplayDialog("Error scenes", "Seems that the layout " + newLayoutName + "doesn't exists\r\nbut the file exist!", "Ok!!");
        }
    }

    static void init(ref StageData stage)
    {
        stage.surfaceList.Clear();

        // TARMAC
        Surface newItem = new Surface();
        newItem.Type = Surface.SURFACE_TYPE.TARMAC;
        newItem.PhysColor = new Color32(0, 0, 0, 255);
        newItem.Name = "Tarmac max grip";
        newItem.UsableGrip = 1.0f;
        newItem.Rolling = 1.0f;
        newItem.Drag = 0.0f;
        newItem.Bump = new Vector2(0.0f, 2.0f);
        newItem.TrailColor = new Color32(125, 125, 125, 255);
        newItem.TrailBump = -1.0f;
        newItem.Gravity = -0.02f;
        newItem.GradientColor = new Gradient();
        var gck = new GradientColorKey[2];
        gck[0].color = new Color32(152, 152, 152, 255);
        gck[0].time = 0.0f;
        gck[1].color = new Color32(225, 225, 225, 255);
        gck[1].time = 1.0f;
        var gak = new GradientAlphaKey[3];
        gak[0].alpha = 0.6f;
        gak[0].time = 0.0f;
        gak[1].alpha = 0.48f;
        gak[1].time = 0.574f;
        gak[2].alpha = 0.0f;
        gak[2].time = 1.0f;
        newItem.GradientColor.mode = GradientMode.Blend;
        newItem.GradientColor.SetKeys(gck, gak);
        newItem.Size = new Vector2(0.0f, 0.8f);
        newItem.LifeTime = new Vector2(0.0f, 1.2f);
        stage.surfaceList.Add(newItem);

        newItem = new Surface();
        newItem.Type = Surface.SURFACE_TYPE.TARMAC;
        newItem.PhysColor = new Color32(48, 48, 48, 255);
        newItem.Name = "Tarmac med grip";
        newItem.UsableGrip = 0.5f;
        newItem.Rolling = 1.0f;
        newItem.Drag = 0.0f;
        newItem.Bump = new Vector2(0.0f, 2.0f);
        newItem.TrailColor = new Color32(125, 125, 125, 255);
        newItem.TrailBump = -1.0f;
        newItem.Gravity = -0.02f;
        newItem.GradientColor = new Gradient();
        gck = new GradientColorKey[2];
        gck[0].color = new Color32(152, 152, 152, 255);
        gck[0].time = 0.0f;
        gck[1].color = new Color32(225, 225, 225, 255);
        gck[1].time = 1.0f;
        gak = new GradientAlphaKey[3];
        gak[0].alpha = 0.6f;
        gak[0].time = 0.0f;
        gak[1].alpha = 0.48f;
        gak[1].time = 0.574f;
        gak[2].alpha = 0.0f;
        gak[2].time = 1.0f;
        newItem.GradientColor.mode = GradientMode.Blend;
        newItem.GradientColor.SetKeys(gck, gak);
        newItem.Size = new Vector2(0.0f, 0.8f);
        newItem.LifeTime = new Vector2(0.0f, 1.2f);
        stage.surfaceList.Add(newItem);

        newItem = new Surface();
        newItem.Type = Surface.SURFACE_TYPE.TARMAC;
        newItem.PhysColor = new Color32(96, 96, 96, 255);
        newItem.Name = "Tarmac min grip";
        newItem.UsableGrip = 0.0f;
        newItem.Rolling = 1.0f;
        newItem.Drag = 0.0f;
        newItem.Bump = new Vector2(0.0f, 2.0f);
        newItem.TrailColor = new Color32(125, 125, 125, 255);
        newItem.TrailBump = -1.0f;
        newItem.Gravity = -0.02f;
        newItem.GradientColor = new Gradient();
        gck = new GradientColorKey[2];
        gck[0].color = new Color32(152, 152, 152, 255);
        gck[0].time = 0.0f;
        gck[1].color = new Color32(225, 225, 225, 255);
        gck[1].time = 1.0f;
        gak = new GradientAlphaKey[3];
        gak[0].alpha = 0.6f;
        gak[0].time = 0.0f;
        gak[1].alpha = 0.48f;
        gak[1].time = 0.574f;
        gak[2].alpha = 0.0f;
        gak[2].time = 1.0f;
        newItem.GradientColor.mode = GradientMode.Blend;
        newItem.GradientColor.SetKeys(gck, gak);
        newItem.Size = new Vector2(0.0f, 0.8f);
        newItem.LifeTime = new Vector2(0.0f, 1.2f);
        stage.surfaceList.Add(newItem);

        // gravel
        newItem = new Surface();
        newItem.Type = Surface.SURFACE_TYPE.GRAVEL;
        newItem.PhysColor = new Color32(212, 160, 23, 255);
        newItem.Name = "Gravel max grip";
        newItem.UsableGrip = 1.0f;
        newItem.Rolling = 5.0f;
        newItem.Drag = 2.0f;
        newItem.Bump = new Vector2(0.0f, 10.0f);
        newItem.TrailColor = new Color32(154, 105, 37, 159);
        newItem.TrailBump = -1.0f;
        newItem.Gravity = 0.0f;
        newItem.GradientColor = new Gradient();
        gck = new GradientColorKey[2];
        gck[0].color = new Color32(234, 229, 223, 255);
        gck[0].time = 0.0F;
        gck[1].color = new Color32(239, 239, 239, 255);
        gck[1].time = 1.0F;
        gak = new GradientAlphaKey[3];
        gak[0].alpha = 0.55F;
        gak[0].time = 0.0F;
        gak[1].alpha = 0.5F;
        gak[1].time = 0.574F;
        gak[2].alpha = 0.0F;
        gak[2].time = 1.0F;
        newItem.GradientColor.mode = GradientMode.Blend;
        newItem.GradientColor.SetKeys(gck, gak);
        newItem.Size = new Vector2(0.60f, 4.0f);
        newItem.LifeTime = new Vector2(0.05f, 5.0f);
        stage.surfaceList.Add(newItem);

        newItem = new Surface();
        newItem.Type = Surface.SURFACE_TYPE.GRAVEL;
        newItem.PhysColor = new Color32(255, 208, 071, 255);
        newItem.Name = "Gravel med grip";
        newItem.UsableGrip = 0.5f;
        newItem.Rolling = 5.0f;
        newItem.Drag = 2.0f;
        newItem.Bump = new Vector2(0.0f, 10.0f);
        newItem.TrailColor = new Color32(154, 105, 37, 159);
        newItem.TrailBump = -1.0f;
        newItem.Gravity = 0.0f;
        newItem.GradientColor = new Gradient();
        gck = new GradientColorKey[2];
        gck[0].color = new Color32(234, 229, 223, 255);
        gck[0].time = 0.0F;
        gck[1].color = new Color32(239, 239, 239, 255);
        gck[1].time = 1.0F;
        gak = new GradientAlphaKey[3];
        gak[0].alpha = 0.55F;
        gak[0].time = 0.0F;
        gak[1].alpha = 0.5F;
        gak[1].time = 0.574F;
        gak[2].alpha = 0.0F;
        gak[2].time = 1.0F;
        newItem.GradientColor.mode = GradientMode.Blend;
        newItem.GradientColor.SetKeys(gck, gak);
        newItem.Size = new Vector2(0.60f, 4.0f);
        newItem.LifeTime = new Vector2(0.05f, 5.0f);
        stage.surfaceList.Add(newItem);

        newItem = new Surface();
        newItem.Type = Surface.SURFACE_TYPE.GRAVEL;
        newItem.PhysColor = new Color32(255, 255, 119, 255);
        newItem.Name = "Gravel min grip";
        newItem.UsableGrip = 0.0f;
        newItem.Rolling = 5.0f;
        newItem.Drag = 2.0f;
        newItem.Bump = new Vector2(0.0f, 10.0f);
        newItem.TrailColor = new Color32(154, 105, 37, 159);
        newItem.TrailBump = -1.0f;
        newItem.Gravity = 0.0f;
        newItem.GradientColor = new Gradient();
        gck = new GradientColorKey[2];
        gck[0].color = new Color32(234, 229, 223, 255);
        gck[0].time = 0.0F;
        gck[1].color = new Color32(239, 239, 239, 255);
        gck[1].time = 1.0F;
        gak = new GradientAlphaKey[3];
        gak[0].alpha = 0.55F;
        gak[0].time = 0.0F;
        gak[1].alpha = 0.5F;
        gak[1].time = 0.574F;
        gak[2].alpha = 0.0F;
        gak[2].time = 1.0F;
        newItem.GradientColor.mode = GradientMode.Blend;
        newItem.GradientColor.SetKeys(gck, gak);
        newItem.Size = new Vector2(0.60f, 4.0f);
        newItem.LifeTime = new Vector2(0.05f, 5.0f);
        stage.surfaceList.Add(newItem);

        // mud
        newItem = new Surface();
        newItem.Type = Surface.SURFACE_TYPE.DIRT;
        newItem.PhysColor = new Color32(111, 078, 055, 255);
        newItem.Name = "Dirt max grip";
        newItem.UsableGrip = 1.0f;
        newItem.Rolling = 5.0f;
        newItem.Drag = 2.5f;
        newItem.Bump = new Vector2(0.0f, 12.0f);
        newItem.TrailColor = new Color32(154, 105, 37, 159);
        newItem.TrailBump = -2.0f;
        newItem.Gravity = 0.0f;
        newItem.GradientColor = new Gradient();
        gck = new GradientColorKey[2];
        gck[0].color = new Color32(118, 62, 62, 255);
        gck[0].time = 0.0F;
        gck[1].color = new Color32(118, 62, 62, 255);
        gck[1].time = 1.0F;
        gak = new GradientAlphaKey[3];
        gak[0].alpha = 0.4F;
        gak[0].time = 0.0F;
        gak[1].alpha = 0.35F;
        gak[1].time = 0.574F;
        gak[2].alpha = 0.0F;
        gak[2].time = 1.0F;
        newItem.GradientColor.mode = GradientMode.Blend;
        newItem.GradientColor.SetKeys(gck, gak);
        newItem.Size = new Vector2(0.30f, 0.5f);
        newItem.LifeTime = new Vector2(0.05f, 2.0f);
        stage.surfaceList.Add(newItem);

        newItem = new Surface();
        newItem.Type = Surface.SURFACE_TYPE.DIRT;
        newItem.PhysColor = new Color32(159, 126, 103, 255);
        newItem.Name = "Dirt med grip";
        newItem.UsableGrip = 0.5f;
        newItem.Rolling = 5.0f;
        newItem.Drag = 2.5f;
        newItem.Bump = new Vector2(0.0f, 12.0f);
        newItem.TrailColor = new Color32(154, 105, 37, 159);
        newItem.TrailBump = -2.0f;
        newItem.Gravity = 0.0f;
        newItem.GradientColor = new Gradient();
        gck = new GradientColorKey[2];
        gck[0].color = new Color32(118, 62, 62, 255);
        gck[0].time = 0.0F;
        gck[1].color = new Color32(118, 62, 62, 255);
        gck[1].time = 1.0F;
        gak = new GradientAlphaKey[3];
        gak[0].alpha = 0.4F;
        gak[0].time = 0.0F;
        gak[1].alpha = 0.35F;
        gak[1].time = 0.574F;
        gak[2].alpha = 0.0F;
        gak[2].time = 1.0F;
        newItem.GradientColor.mode = GradientMode.Blend;
        newItem.GradientColor.SetKeys(gck, gak);
        newItem.Size = new Vector2(0.30f, 0.5f);
        newItem.LifeTime = new Vector2(0.05f, 2.0f);
        stage.surfaceList.Add(newItem);

        newItem = new Surface();
        newItem.Type = Surface.SURFACE_TYPE.DIRT;
        newItem.PhysColor = new Color32(207, 174, 151, 255);
        newItem.Name = "Dirt min grip";
        newItem.UsableGrip = 0.0f;
        newItem.Rolling = 5.0f;
        newItem.Drag = 2.5f;
        newItem.Bump = new Vector2(0.0f, 12.0f);
        newItem.TrailColor = new Color32(154, 105, 37, 159);
        newItem.TrailBump = -2.0f;
        newItem.Gravity = 0.0f;
        newItem.GradientColor = new Gradient();
        gck = new GradientColorKey[2];
        gck[0].color = new Color32(118, 62, 62, 255);
        gck[0].time = 0.0F;
        gck[1].color = new Color32(118, 62, 62, 255);
        gck[1].time = 1.0F;
        gak = new GradientAlphaKey[3];
        gak[0].alpha = 0.4F;
        gak[0].time = 0.0F;
        gak[1].alpha = 0.35F;
        gak[1].time = 0.574F;
        gak[2].alpha = 0.0F;
        gak[2].time = 1.0F;
        newItem.GradientColor.mode = GradientMode.Blend;
        newItem.GradientColor.SetKeys(gck, gak);
        newItem.Size = new Vector2(0.30f, 0.5f);
        newItem.LifeTime = new Vector2(0.05f, 2.0f);
        stage.surfaceList.Add(newItem);

        // grass
        newItem = new Surface();
        newItem.Type = Surface.SURFACE_TYPE.GRASS;
        newItem.PhysColor = new Color32(000, 159, 000, 255);
        newItem.Name = "Grass max grip";
        newItem.UsableGrip = 1.0f;
        newItem.Rolling = 5.0f;
        newItem.Drag = 20.0f;
        newItem.Bump = new Vector2(0.0f, 10.0f);
        newItem.TrailColor = new Color32(30, 66, 30, 165);
        newItem.TrailBump = -2.0f;
        newItem.Gravity = 0.0f;
        newItem.GradientColor = new Gradient();
        gck = new GradientColorKey[2];
        gck[0].color = new Color32(26, 90, 26, 255);
        gck[0].time = 0.0F;
        gck[1].color = new Color32(0, 255, 0, 255);
        gck[1].time = 1.0F;
        gak = new GradientAlphaKey[3];
        gak[0].alpha = 1.0F;
        gak[0].time = 0.0F;
        gak[1].alpha = 1.0F;
        gak[1].time = 0.574F;
        gak[2].alpha = 0.0F;
        gak[2].time = 1.0F;
        newItem.GradientColor.mode = GradientMode.Blend;
        newItem.GradientColor.SetKeys(gck, gak);
        newItem.Size = new Vector2(0.0f, 0.0f);
        newItem.LifeTime = new Vector2(0.0f, 0.0f);
        stage.surfaceList.Add(newItem);

        newItem = new Surface();
        newItem.Type = Surface.SURFACE_TYPE.GRASS;
        newItem.PhysColor = new Color32(000, 207, 000, 255);
        newItem.Name = "Grass med grip";
        newItem.UsableGrip = 0.5f;
        newItem.Rolling = 5.0f;
        newItem.Drag = 20.0f;
        newItem.Bump = new Vector2(0.0f, 10.0f);
        newItem.TrailColor = new Color32(30, 66, 30, 165);
        newItem.TrailBump = -2.0f;
        newItem.Gravity = 0.0f;
        newItem.GradientColor = new Gradient();
        gck = new GradientColorKey[2];
        gck[0].color = new Color32(26, 90, 26, 255);
        gck[0].time = 0.0F;
        gck[1].color = new Color32(0, 255, 0, 255);
        gck[1].time = 1.0F;
        gak = new GradientAlphaKey[3];
        gak[0].alpha = 1.0F;
        gak[0].time = 0.0F;
        gak[1].alpha = 1.0F;
        gak[1].time = 0.574F;
        gak[2].alpha = 0.0F;
        gak[2].time = 1.0F;
        newItem.GradientColor.mode = GradientMode.Blend;
        newItem.GradientColor.SetKeys(gck, gak);
        newItem.Size = new Vector2(0.0f, 0.0f);
        newItem.LifeTime = new Vector2(0.0f, 0.0f);
        stage.surfaceList.Add(newItem);

        newItem = new Surface();
        newItem.Type = Surface.SURFACE_TYPE.GRASS;
        newItem.PhysColor = new Color32(000, 255, 000, 255);
        newItem.Name = "Grass min grip";
        newItem.UsableGrip = 0.0f;
        newItem.Rolling = 5.0f;
        newItem.Drag = 20.0f;
        newItem.Bump = new Vector2(0.0f, 10.0f);
        newItem.TrailColor = new Color32(30, 66, 30, 165);
        newItem.TrailBump = -2.0f;
        newItem.Gravity = 0.0f;
        newItem.GradientColor = new Gradient();
        gck = new GradientColorKey[2];
        gck[0].color = new Color32(26, 90, 26, 255);
        gck[0].time = 0.0F;
        gck[1].color = new Color32(0, 255, 0, 255);
        gck[1].time = 1.0F;
        gak = new GradientAlphaKey[3];
        gak[0].alpha = 1.0F;
        gak[0].time = 0.0F;
        gak[1].alpha = 1.0F;
        gak[1].time = 0.574F;
        gak[2].alpha = 0.0F;
        gak[2].time = 1.0F;
        newItem.GradientColor.mode = GradientMode.Blend;
        newItem.GradientColor.SetKeys(gck, gak);
        newItem.Size = new Vector2(0.0f, 0.0f);
        newItem.LifeTime = new Vector2(0.0f, 0.0f);
        stage.surfaceList.Add(newItem);

        // snow
        newItem = new Surface();
        newItem.Type = Surface.SURFACE_TYPE.SNOW;
        newItem.PhysColor = new Color32(023, 095, 103, 255);
        newItem.Name = "Snow max grip";
        newItem.UsableGrip = 1.0f;
        newItem.Rolling = 5.0f;
        newItem.Drag = 2.0f;
        newItem.Bump = new Vector2(0.0f, 10.0f);
        newItem.TrailColor = new Color32(223, 223, 248, 255);
        newItem.TrailBump = -2.0f;
        newItem.Gravity = 0.0f;
        newItem.GradientColor = new Gradient();
        gck = new GradientColorKey[2];
        gck[0].color = new Color32(235, 255, 255, 255);
        gck[0].time = 0.0F;
        gck[1].color = new Color32(239, 239, 239, 255);
        gck[1].time = 1.0F;
        gak = new GradientAlphaKey[3];
        gak[0].alpha = 0.55F;
        gak[0].time = 0.0F;
        gak[1].alpha = 0.5F;
        gak[1].time = 0.574F;
        gak[2].alpha = 0.0F;
        gak[2].time = 1.0F;
        newItem.GradientColor.mode = GradientMode.Blend;
        newItem.GradientColor.SetKeys(gck, gak);
        newItem.Size = new Vector2(0.60f, 4.0f);
        newItem.LifeTime = new Vector2(0.05f, 5.0f);
        stage.surfaceList.Add(newItem);

        newItem = new Surface();
        newItem.Type = Surface.SURFACE_TYPE.SNOW;
        newItem.PhysColor = new Color32(071, 143, 151, 255);
        newItem.Name = "Snow med grip";
        newItem.UsableGrip = 0.5f;
        newItem.Rolling = 5.0f;
        newItem.Drag = 2.0f;
        newItem.Bump = new Vector2(0.0f, 10.0f);
        newItem.TrailColor = new Color32(223, 223, 248, 255);
        newItem.TrailBump = -2.0f;
        newItem.Gravity = 0.0f;
        newItem.GradientColor = new Gradient();
        gck = new GradientColorKey[2];
        gck[0].color = new Color32(235, 255, 255, 255);
        gck[0].time = 0.0F;
        gck[1].color = new Color32(239, 239, 239, 255);
        gck[1].time = 1.0F;
        gak = new GradientAlphaKey[3];
        gak[0].alpha = 0.55F;
        gak[0].time = 0.0F;
        gak[1].alpha = 0.5F;
        gak[1].time = 0.574F;
        gak[2].alpha = 0.0F;
        gak[2].time = 1.0F;
        newItem.GradientColor.mode = GradientMode.Blend;
        newItem.GradientColor.SetKeys(gck, gak);
        newItem.Size = new Vector2(0.60f, 4.0f);
        newItem.LifeTime = new Vector2(0.05f, 5.0f);
        stage.surfaceList.Add(newItem);

        newItem = new Surface();
        newItem.Type = Surface.SURFACE_TYPE.SNOW;
        newItem.PhysColor = new Color32(119, 191, 199, 255);
        newItem.Name = "Snow min grip";
        newItem.UsableGrip = 0.0f;
        newItem.Rolling = 5.0f;
        newItem.Drag = 2.0f;
        newItem.Bump = new Vector2(0.0f, 10.0f);
        newItem.TrailColor = new Color32(223, 223, 248, 255);
        newItem.TrailBump = -2.0f;
        newItem.Gravity = 0.0f;
        newItem.GradientColor = new Gradient();
        gck = new GradientColorKey[2];
        gck[0].color = new Color32(235, 255, 255, 255);
        gck[0].time = 0.0F;
        gck[1].color = new Color32(239, 239, 239, 255);
        gck[1].time = 1.0F;
        gak = new GradientAlphaKey[3];
        gak[0].alpha = 0.55F;
        gak[0].time = 0.0F;
        gak[1].alpha = 0.5F;
        gak[1].time = 0.574F;
        gak[2].alpha = 0.0F;
        gak[2].time = 1.0F;
        newItem.GradientColor.mode = GradientMode.Blend;
        newItem.GradientColor.SetKeys(gck, gak);
        newItem.Size = new Vector2(0.60f, 4.0f);
        newItem.LifeTime = new Vector2(0.05f, 5.0f);
        stage.surfaceList.Add(newItem);

        // ice
        newItem = new Surface();
        newItem.Type = Surface.SURFACE_TYPE.ICE;
        newItem.PhysColor = new Color32(023, 095, 103, 255);
        newItem.Name = "Ice max grip";
        newItem.UsableGrip = 1.0f;
        newItem.Rolling = 1.0f;
        newItem.Drag = 0.2f;
        newItem.Bump = new Vector2(0.0f, 4.0f);
        newItem.TrailColor = new Color32(223, 223, 248, 255);
        newItem.TrailBump = -1.0f;
        newItem.Gravity = 0.0f;
        newItem.GradientColor = new Gradient();
        gck = new GradientColorKey[2];
        gck[0].color = new Color32(197, 255, 255, 255);
        gck[0].time = 0.0F;
        gck[1].color = new Color32(197, 255, 255, 255);
        gck[1].time = 1.0F;
        gak = new GradientAlphaKey[3];
        gak[0].alpha = 0.4F;
        gak[0].time = 0.0F;
        gak[1].alpha = 0.35F;
        gak[1].time = 0.574F;
        gak[2].alpha = 0.0F;
        gak[2].time = 1.0F;
        newItem.GradientColor.mode = GradientMode.Blend;
        newItem.GradientColor.SetKeys(gck, gak);
        newItem.Size = new Vector2(0.30f, 0.5f);
        newItem.LifeTime = new Vector2(0.05f, 2.0f);
        stage.surfaceList.Add(newItem);

        newItem = new Surface();
        newItem.Type = Surface.SURFACE_TYPE.ICE;
        newItem.PhysColor = new Color32(071, 143, 151, 255);
        newItem.Name = "Ice med grip";
        newItem.UsableGrip = 0.5f;
        newItem.Rolling = 1.0f;
        newItem.Drag = 0.2f;
        newItem.Bump = new Vector2(0.0f, 4.0f);
        newItem.TrailColor = new Color32(223, 223, 248, 255);
        newItem.TrailBump = -1.0f;
        newItem.Gravity = 0.0f;
        newItem.GradientColor = new Gradient();
        gck = new GradientColorKey[2];
        gck[0].color = new Color32(197, 255, 255, 255);
        gck[0].time = 0.0F;
        gck[1].color = new Color32(197, 255, 255, 255);
        gck[1].time = 1.0F;
        gak = new GradientAlphaKey[3];
        gak[0].alpha = 0.4F;
        gak[0].time = 0.0F;
        gak[1].alpha = 0.35F;
        gak[1].time = 0.574F;
        gak[2].alpha = 0.0F;
        gak[2].time = 1.0F;
        newItem.GradientColor.mode = GradientMode.Blend;
        newItem.GradientColor.SetKeys(gck, gak);
        newItem.Size = new Vector2(0.30f, 0.5f);
        newItem.LifeTime = new Vector2(0.05f, 2.0f);
        stage.surfaceList.Add(newItem);

        newItem = new Surface();
        newItem.Type = Surface.SURFACE_TYPE.ICE;
        newItem.PhysColor = new Color32(119, 191, 199, 255);
        newItem.Name = "Ice min grip";
        newItem.UsableGrip = 0.0f;
        newItem.Rolling = 1.0f;
        newItem.Drag = 0.2f;
        newItem.Bump = new Vector2(0.0f, 4.0f);
        newItem.TrailColor = new Color32(223, 223, 248, 255);
        newItem.TrailBump = -1.0f;
        newItem.Gravity = 0.0f;
        newItem.GradientColor = new Gradient();
        gck = new GradientColorKey[2];
        gck[0].color = new Color32(197, 255, 255, 255);
        gck[0].time = 0.0F;
        gck[1].color = new Color32(197, 255, 255, 255);
        gck[1].time = 1.0F;
        gak = new GradientAlphaKey[3];
        gak[0].alpha = 0.4F;
        gak[0].time = 0.0F;
        gak[1].alpha = 0.35F;
        gak[1].time = 0.574F;
        gak[2].alpha = 0.0F;
        gak[2].time = 1.0F;
        newItem.GradientColor.mode = GradientMode.Blend;
        newItem.GradientColor.SetKeys(gck, gak);
        newItem.Size = new Vector2(0.30f, 0.5f);
        newItem.LifeTime = new Vector2(0.05f, 2.0f);
        stage.surfaceList.Add(newItem);
    }
}
