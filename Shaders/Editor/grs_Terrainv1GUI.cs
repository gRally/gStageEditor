using UnityEngine;
using UnityEditor;
using Object = UnityEngine.Object;
using System;

internal class grs_Terrainv1GUI : ShaderGUI
{
    private static class Styles
    {
        public static GUIContent albedo = new GUIContent("Albedo", "Albedo (RGB) Specular Map (A)");
        public static GUIContent groove = new GUIContent("Groove", "Groove (RGB)");
        public static GUIContent specular = new GUIContent("Specular", "Specular color and Smoothness");
        public static GUIContent normal = new GUIContent("Normal", "Normal Map");
        public static GUIContent phys = new GUIContent("PhysMap", "Phys Map");
    }

    MaterialProperty albedoMap = null;
    MaterialProperty fakeNormal = null;
    MaterialProperty smoothScale = null;
    MaterialProperty specColor = null;
    MaterialProperty useReflectMap = null;
    MaterialProperty useWet = null;
    MaterialProperty wetInfluence = null;
    MaterialProperty wetDarkening = null;

    // R
    MaterialProperty useR_Color = null;
    MaterialProperty albedoMapR = null;
    MaterialProperty fakeNormalR = null;
    MaterialProperty smoothScaleR = null;
    MaterialProperty specColorR = null;
    MaterialProperty useReflectMapR = null;

    // G
    MaterialProperty useG_Color = null;
    MaterialProperty albedoMapG = null;
    MaterialProperty fakeNormalG = null;
    MaterialProperty smoothScaleG = null;
    MaterialProperty specColorG = null;
    MaterialProperty useReflectMapG = null;

    // B
    MaterialProperty useB_Color = null;
    MaterialProperty albedoMapB = null;
    MaterialProperty fakeNormalB = null;
    MaterialProperty smoothScaleB = null;
    MaterialProperty specColorB = null;
    MaterialProperty useReflectMapB = null;

    const int kSecondLevelIndentOffset = 2;
    const float kVerticalSpacing = 2f;

    public void FindProperties(MaterialProperty[] props)
    {
        albedoMap = FindProperty("_MainTex", props);
        specColor = FindProperty("_SpecColor", props);
        smoothScale = FindProperty("_Smoothness", props);
        useReflectMap = FindProperty("_UseReflectMap", props);
        fakeNormal = FindProperty("_FakeNormal", props);
        useWet = FindProperty("_UseWet", props);
        wetInfluence = FindProperty("_WetInfluence", props);
        wetDarkening = FindProperty("_WetDarkening", props);

        // R
        useR_Color = FindProperty("_UseR_Color", props);
        albedoMapR = FindProperty("_MainTexR", props);
        fakeNormalR = FindProperty("_FakeNormalR", props);
        specColorR = FindProperty("_SpecColorR", props);
        smoothScaleR = FindProperty("_SmoothnessR", props);
        useReflectMapR = FindProperty("_UseReflectMapR", props);

        // G
        useG_Color = FindProperty("_UseG_Color", props);
        albedoMapG = FindProperty("_MainTexG", props);
        fakeNormalG = FindProperty("_FakeNormalG", props);
        specColorG = FindProperty("_SpecColorG", props);
        smoothScaleG = FindProperty("_SmoothnessG", props);
        useReflectMapG = FindProperty("_UseReflectMapG", props);

        // B
        useB_Color = FindProperty("_UseB_Color", props);
        albedoMapB = FindProperty("_MainTexB", props);
        fakeNormalB = FindProperty("_FakeNormalB", props);
        specColorB = FindProperty("_SpecColorB", props);
        smoothScaleB = FindProperty("_SmoothnessB", props);
        useReflectMapB = FindProperty("_UseReflectMapB", props);
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        // antoripa rules
        var currentColor = GUI.backgroundColor;

        // NU Color guicontentColor = GUI.contentColor;
        Color guibackgroundColor = GUI.backgroundColor;
        Color BoxColor = GUI.backgroundColor;
        Color HelpCol = new Color(0.890f * 0.7f, 0.318f * 0.7f, 0.125f * 0.7f, 1.0f);
        Color WeatherBG = HelpCol;
        Color WeatherBGbright = GUI.backgroundColor;

        if (!EditorGUIUtility.isProSkin)
        {
            WeatherBG = new Color(0.890f, 0.318f, 0.125f, 1.0f);//new Color(0.52f, 0.63f, 0.8f, 1.0f);
            WeatherBG = Color.Lerp(guibackgroundColor, WeatherBG, 0.7f);
        }

        GUIStyle m_box = GUI.skin.box;
        m_box.normal.background = Texture2D.whiteTexture;
        GUI.skin.box = m_box;
        BoxColor = new Color(0.83f, 0.83f, 0.83f, 1.0f);
        WeatherBGbright = Color.Lerp(BoxColor, WeatherBG, 0.45f);

        GUIStyle HelpLabel = new GUIStyle(EditorStyles.miniLabel);
        HelpLabel.normal.textColor = HelpCol;
        HelpLabel.onNormal.textColor = HelpCol;

        FindProperties(props); // MaterialProperties can be animated so we do not cache them but fetch them every event to ensure animated values are updated correctly

        // Use default labelWidth
        EditorGUIUtility.labelWidth = 0f;

        // Detect any changes to the material
        EditorGUI.BeginChangeCheck();
        {
            // Texture
            GUI.backgroundColor = WeatherBG;
            EditorGUILayout.BeginVertical("Box");
            GUI.backgroundColor = guibackgroundColor;
            GUILayout.Label("Base Maps", EditorStyles.boldLabel);
            GUILayout.Space(4);
            GUI.backgroundColor = WeatherBGbright; //BoxColor;
            EditorGUILayout.BeginVertical("Box");
            GUI.backgroundColor = guibackgroundColor;

            materialEditor.ShaderProperty(useR_Color, "Enable R color channel");
            materialEditor.ShaderProperty(useG_Color, "Enable G color channel");
            materialEditor.ShaderProperty(useB_Color, "Enable B color channel");
            GUILayout.Space(4);

            GUILayout.Label("Albedo [RGB] and specular/wet map [A].", HelpLabel);
            GUILayout.Space(4);

            materialEditor.TexturePropertySingleLine(Styles.albedo, albedoMap);
            materialEditor.TextureScaleOffsetProperty(albedoMap);
            GUILayout.Space(4);
            GUILayout.Label("The reflectivity map can be stored in the A channel\nof the normal map: otherwise use color.", HelpLabel);
            materialEditor.ShaderProperty(useReflectMap, "Use Reflectivity Map");
            if (useReflectMap.floatValue == 0.0f)
            {
                materialEditor.ShaderProperty(specColor, "Reflectivity color");
            }
            materialEditor.ShaderProperty(smoothScale, "Smoothness Mult");
            //materialEditor.c .TexturePropertySingleLine(Styles.specular, specColor, smoothScale);
            GUILayout.Space(4);
            materialEditor.TexturePropertySingleLine(Styles.normal, fakeNormal);
            materialEditor.TextureScaleOffsetProperty(fakeNormal);

            EditorGUILayout.EndVertical();
            EditorGUILayout.EndVertical();

            GUILayout.Space(4);
            if (useR_Color.floatValue == 1.0f)
            {
                GUI.backgroundColor = WeatherBG;
                EditorGUILayout.BeginVertical("Box");
                GUI.backgroundColor = guibackgroundColor;
                GUILayout.Label("R color channel", EditorStyles.boldLabel);
                GUILayout.Space(4);
                GUI.backgroundColor = WeatherBGbright; //BoxColor;
                EditorGUILayout.BeginVertical("Box");
                GUI.backgroundColor = guibackgroundColor;
                GUILayout.Label("These settings are used to map from the R vertex color channel.", HelpLabel);
                GUILayout.Space(4);
                GUILayout.Label("Albedo [RGB] and specular/wet map [A].", HelpLabel);
                GUILayout.Space(4);
                materialEditor.TexturePropertySingleLine(Styles.albedo, albedoMapR);
                materialEditor.TextureScaleOffsetProperty(albedoMapR);
                GUILayout.Space(4);
                GUILayout.Label("The reflectivity map can be stored in the A channel\nof the normal map: otherwise use color.", HelpLabel);
                materialEditor.ShaderProperty(useReflectMapR, "Use Reflectivity Map");
                if (useReflectMapR.floatValue == 0.0f)
                {
                    materialEditor.ShaderProperty(specColorR, "Reflectivity color");
                }
                materialEditor.ShaderProperty(smoothScaleR, "Smoothness Mult");
                GUILayout.Space(4);
                materialEditor.TexturePropertySingleLine(Styles.normal, fakeNormalR);
                materialEditor.TextureScaleOffsetProperty(fakeNormalR);
                EditorGUILayout.EndVertical();
                EditorGUILayout.EndVertical();
            }

            GUILayout.Space(4);
            if (useG_Color.floatValue == 1.0f)
            {
                GUI.backgroundColor = WeatherBG;
                EditorGUILayout.BeginVertical("Box");
                GUI.backgroundColor = guibackgroundColor;
                GUILayout.Label("G color channel", EditorStyles.boldLabel);
                GUILayout.Space(4);
                GUI.backgroundColor = WeatherBGbright; //BoxColor;
                EditorGUILayout.BeginVertical("Box");
                GUI.backgroundColor = guibackgroundColor;
                GUILayout.Label("These settings are used to map from the G vertex color channel.", HelpLabel);
                GUILayout.Space(4);
                GUILayout.Label("Albedo [RGB] and specular/wet map [A].", HelpLabel);
                GUILayout.Space(4);
                materialEditor.TexturePropertySingleLine(Styles.albedo, albedoMapG);
                materialEditor.TextureScaleOffsetProperty(albedoMapG);
                GUILayout.Space(4);
                GUILayout.Label("The reflectivity map can be stored in the A channel\nof the normal map: otherwise use color.", HelpLabel);
                materialEditor.ShaderProperty(useReflectMapG, "Use Reflectivity Map");
                if (useReflectMapG.floatValue == 0.0f)
                {
                    materialEditor.ShaderProperty(specColorG, "Reflectivity color");
                }
                materialEditor.ShaderProperty(smoothScaleG, "Smoothness Mult");
                GUILayout.Space(4);
                materialEditor.TexturePropertySingleLine(Styles.normal, fakeNormalG);
                materialEditor.TextureScaleOffsetProperty(fakeNormalG);
                EditorGUILayout.EndVertical();
                EditorGUILayout.EndVertical();
            }
            
            GUILayout.Space(4);
            if (useB_Color.floatValue == 1.0f)
            {
                GUI.backgroundColor = WeatherBG;
                EditorGUILayout.BeginVertical("Box");
                GUI.backgroundColor = guibackgroundColor;
                GUILayout.Label("B color channel", EditorStyles.boldLabel);
                GUILayout.Space(4);
                GUI.backgroundColor = WeatherBGbright; //BoxColor;
                EditorGUILayout.BeginVertical("Box");
                GUI.backgroundColor = guibackgroundColor;
                GUILayout.Label("These settings are used to map from the B vertex color channel.", HelpLabel);
                GUILayout.Space(4);
                GUILayout.Label("Albedo [RGB] and specular/wet map [A].", HelpLabel);
                GUILayout.Space(4);
                materialEditor.TexturePropertySingleLine(Styles.albedo, albedoMapB);
                materialEditor.TextureScaleOffsetProperty(albedoMapB);
                GUILayout.Space(4);
                GUILayout.Label("The reflectivity map can be stored in the A channel\nof the normal map: otherwise use color.", HelpLabel);
                materialEditor.ShaderProperty(useReflectMapB, "Use Reflectivity Map");
                if (useReflectMapB.floatValue == 0.0f)
                {
                    materialEditor.ShaderProperty(specColorB, "Reflectivity color");
                }
                materialEditor.ShaderProperty(smoothScaleB, "Smoothness Mult");
                GUILayout.Space(4);
                materialEditor.TexturePropertySingleLine(Styles.normal, fakeNormalB);
                materialEditor.TextureScaleOffsetProperty(fakeNormalB);
                EditorGUILayout.EndVertical();
                EditorGUILayout.EndVertical();
            }

            GUI.backgroundColor = WeatherBG;
            EditorGUILayout.BeginVertical("Box");
            GUI.backgroundColor = guibackgroundColor;
            GUILayout.Label("gRally Physics", EditorStyles.boldLabel);
            GUILayout.Space(4);
            GUI.backgroundColor = WeatherBGbright; //BoxColor;
            EditorGUILayout.BeginVertical("Box");
            GUI.backgroundColor = guibackgroundColor;

            materialEditor.ShaderProperty(useWet, "Enable Wet");
            if (useWet.floatValue == 1.0f)
            {
                GUILayout.Label("The wet influence is a multiplier to allow a more/less wet\nspecular influence of the material.", HelpLabel);
                materialEditor.ShaderProperty(wetInfluence, "Wet Influence");
                GUILayout.Label("Multiplier to darken the material if is wet.", HelpLabel);
                materialEditor.ShaderProperty(wetDarkening, "Wet Darkening");
            }

            EditorGUILayout.EndVertical();
            EditorGUILayout.EndVertical();
        }

        // antoripa rules
        GUI.backgroundColor = currentColor;
    }
}
