using UnityEngine;
using UnityEditor;
using Object = UnityEngine.Object;
using System;

internal class grs_PhysRoadv1GUI : ShaderGUI
{
    public enum TransparentMode
    {
        Opaque,
        UseVertexColor,
        UseTexture
    }

    private static class Styles
    {
        public static GUIContent albedo = new GUIContent("Albedo", "Albedo (RGB) Specular Map (A)");
        public static GUIContent transparent = new GUIContent("Transparent", "Transparent Map (A)");
        public static GUIContent groove = new GUIContent("Groove", "Groove (RGB)");
        public static GUIContent specular = new GUIContent("Specular", "Specular color and Smoothness");
        public static GUIContent normal = new GUIContent("Normal", "Normal Map");
        public static GUIContent phys = new GUIContent("PhysMap", "Phys Map");
        public static string transparentMode = "Transparent Mode";
        public static readonly string[] transparentNames = Enum.GetNames(typeof(TransparentMode));
    }

    MaterialProperty transparentMode = null;
    MaterialProperty albedoMap = null;
    MaterialProperty useGroove = null;
    MaterialProperty grooveMap = null;
    MaterialProperty physMap = null;
    MaterialProperty fakeNormal = null;
    MaterialProperty smoothScale = null;
    MaterialProperty specColor = null;
    MaterialProperty useWet = null;
    MaterialProperty wetInfluence = null;
    MaterialProperty wetDarkening = null;
    MaterialProperty useReflectMap = null;

    MaterialProperty transparentMap = null;

    MaterialProperty cutOff = null;

    const int kSecondLevelIndentOffset = 2;
    const float kVerticalSpacing = 2f;

    public void FindProperties(MaterialProperty[] props)
    {
        transparentMode = FindProperty("_TransparentMode", props);
        albedoMap = FindProperty("_MainTex", props);
        specColor = FindProperty("_SpecColor", props);
        smoothScale = FindProperty("_Smoothness", props);
        useGroove = FindProperty("_UseGroove", props);
        grooveMap = FindProperty("_GrooveTex", props);
        physMap = FindProperty("_PhysMap", props);
        useWet = FindProperty("_UseWet", props);
        wetInfluence = FindProperty("_WetInfluence", props);
        wetDarkening = FindProperty("_WetDarkening", props);
        useReflectMap = FindProperty("_UseReflectMap", props);
        fakeNormal = FindProperty("_FakeNormal", props);
        transparentMap = FindProperty("_TransparentTex", props);
        cutOff = FindProperty("_Cutoff", props);
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        // antoripa rules
        var currentColor = GUI.backgroundColor;
		// antoripa 04.12.2017 fix 
		GUIStyle m_box = GUI.skin.box;
		var skinBackground = m_box.normal.background;

		

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
            Material material = materialEditor.target as Material;

            // Texture header
            GUI.backgroundColor = WeatherBG;
            EditorGUILayout.BeginVertical("Box");
            GUI.backgroundColor = guibackgroundColor;
            GUILayout.Label("Base Maps", EditorStyles.boldLabel);
            GUILayout.Space(4);
            GUI.backgroundColor = WeatherBGbright; //BoxColor;
            EditorGUILayout.BeginVertical("Box");
            GUI.backgroundColor = guibackgroundColor;

			// albedo
			GUILayout.Label("Albedo [RGB] and smoothness map [A].\nSmoothness map is also used to control the reflection in wet conditions.", HelpLabel);
			GUILayout.Space(4);
			materialEditor.TexturePropertySingleLine(Styles.albedo, albedoMap);
			materialEditor.ShaderProperty(smoothScale, "Smoothness Mult");
			materialEditor.TextureScaleOffsetProperty(albedoMap);
			GUILayout.Space(4);

			// normal
			GUILayout.Label("Normal [RGB] and specular map [A].If you want to use\nthe specular map,switch ON the the button below,\notherwise leave it OFF and you can use the specular color.", HelpLabel);
			materialEditor.TexturePropertySingleLine(Styles.normal, fakeNormal);
			materialEditor.ShaderProperty(useReflectMap, "Use Specular Map");
			if (useReflectMap.floatValue == 0.0f)
			{
				materialEditor.ShaderProperty(specColor, "Specular color");
			}

			//materialEditor.c .TexturePropertySingleLine(Styles.specular, specColor, smoothScale);
			GUILayout.Space(4);
			materialEditor.TextureScaleOffsetProperty(fakeNormal);

            GUILayout.Space(4);
            TransparentModePopup();
            if (transparentMode.floatValue == 1.0f)
            {
                GUILayout.Label("The transparency must be controlled by vertex color [A]", HelpLabel);
                materialEditor.ShaderProperty(cutOff, "Alpha Cutoff");
                material.EnableKeyword("USE_TRANSPARENT_VERTEX");
                material.DisableKeyword("USE_TRANSPARENT_TEXTURE");
            }
            else if (transparentMode.floatValue == 2.0f)
            {
                GUILayout.Label("The transparency must be controlled by a texture [A]", HelpLabel);
                materialEditor.ShaderProperty(cutOff, "Alpha Cutoff");
                materialEditor.TexturePropertySingleLine(Styles.transparent, transparentMap);
                material.DisableKeyword("USE_TRANSPARENT_VERTEX");
                material.EnableKeyword("USE_TRANSPARENT_TEXTURE");
            }
            else
            {
                material.DisableKeyword("USE_TRANSPARENT_VERTEX");
                material.DisableKeyword("USE_TRANSPARENT_TEXTURE");
            }

            EditorGUILayout.EndVertical();
            EditorGUILayout.EndVertical();

            // end base maps box .............................................................
            GUILayout.Space(4);

            GUI.backgroundColor = WeatherBG;
            EditorGUILayout.BeginVertical("Box");
            GUI.backgroundColor = guibackgroundColor;
            GUILayout.Label("gRally Physics", EditorStyles.boldLabel);
            GUILayout.Space(4);
            GUI.backgroundColor = WeatherBGbright; //BoxColor;
            EditorGUILayout.BeginVertical("Box");
            GUI.backgroundColor = guibackgroundColor;

            materialEditor.ShaderProperty(useGroove, "Enable Groove");
            if (useGroove.floatValue == 1.0f)
            {
                GUILayout.Label("The groove is masked by B vertex color and\nis multiplied by this texture:", HelpLabel);
                materialEditor.TexturePropertySingleLine(Styles.groove, grooveMap);
            }

            EditorGUILayout.EndVertical();
            GUI.backgroundColor = WeatherBGbright;
            EditorGUILayout.BeginVertical("Box");
            GUI.backgroundColor = guibackgroundColor;

            GUILayout.Label("The physics map is managed using\ngRally->Edit Physics Materials\nand represents the physics material over the graphic material.", HelpLabel);
            materialEditor.TexturePropertySingleLine(Styles.phys, physMap);

            EditorGUILayout.EndVertical();
            GUI.backgroundColor = WeatherBGbright;
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
		// antoripa 04.12.2017 fix 
		m_box.normal.background = skinBackground;
		GUI.skin.box = m_box;
	}

    void TransparentModePopup()
    {
        EditorGUI.showMixedValue = transparentMode.hasMixedValue;
        var mode = (TransparentMode)transparentMode.floatValue;
        EditorGUI.BeginChangeCheck();
        mode = (TransparentMode)EditorGUILayout.Popup(Styles.transparentMode, (int)mode, Styles.transparentNames);
        if (EditorGUI.EndChangeCheck())
        {
            transparentMode.floatValue = (float)mode;
        }
        EditorGUI.showMixedValue = false;
    }
}