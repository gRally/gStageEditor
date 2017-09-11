using UnityEngine;
using System.Collections;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine.SceneManagement;

[CustomEditor(typeof(LayoutInfo))]
public class LayoutInfoEditor : Editor
{
    private LayoutInfo _script { get { return target as LayoutInfo; }}
	 
    public override void OnInspectorGUI()
    {
	    var defaulGUIColor = GUI.color;
		EditorGUI.BeginChangeCheck();


		GUILayout.Label("Name:", EditorStyles.boldLabel);
        _script.Name = EditorGUILayout.TextField(_script.Name);
        //GUILayout.EndHorizontal();

        GUILayout.Label("Description", EditorStyles.boldLabel);
        EditorStyles.textField.wordWrap = true;
        _script.Description = EditorGUILayout.TextArea(_script.Description, GUILayout.MinHeight(100), GUILayout.MaxHeight(200), 
            GUILayout.MaxWidth(450));

        //GUILayout.BeginHorizontal();
        GUILayout.Label("Nation:", EditorStyles.boldLabel);
        _script.countryIndex = EditorGUILayout.Popup(_script.countryIndex, _script.GetCountries());
        //GUILayout.EndHorizontal();

        //GUILayout.BeginHorizontal();
        GUILayout.Label("Surfaces:", EditorStyles.boldLabel);
        //t.Surfaces = EditorGUILayout.TextField(t.Surfaces);
        GUILayout.BeginHorizontal();
	    {
		    GUI.color = _script.Tarmac ? Color.yellow : defaulGUIColor;
		    if (GUILayout.Button("Tarmac")) _script.Tarmac = !_script.Tarmac;

		    GUI.color = _script.Gravel ? Color.yellow : defaulGUIColor;
		    if (GUILayout.Button("Gravel")) _script.Gravel = !_script.Gravel;

		    GUI.color = _script.Dirt ? Color.yellow : defaulGUIColor;
		    if (GUILayout.Button("Dirt")) _script.Dirt = !_script.Dirt;

		    GUI.color = _script.Ice ? Color.yellow : defaulGUIColor;
		    if (GUILayout.Button("Ice")) _script.Ice = !_script.Ice;

		    GUI.color = _script.Snow ? Color.yellow : defaulGUIColor;
		    if (GUILayout.Button("Snow")) _script.Snow = !_script.Snow;
			GUI.color = defaulGUIColor;
		}
        GUILayout.EndHorizontal();
		//GUILayout.EndHorizontal();
	
		//GUILayout.BeginHorizontal();
		GUILayout.Label("Tags:", EditorStyles.boldLabel);
        _script.Tags = EditorGUILayout.TextField(_script.Tags);
        //GUILayout.EndHorizontal();

        GUILayout.BeginHorizontal();
        //GUILayout.Label("Save Times:", EditorStyles.boldLabel);
        _script.SaveTimes = EditorGUILayout.Toggle("Save Times:",_script.SaveTimes);
        GUILayout.EndHorizontal();

	 
        if (EditorGUI.EndChangeCheck())
        {
#if !(UNITY_5_0 || UNITY_5_1 || UNITY_5_2)
            EditorSceneManager.MarkSceneDirty(_script.gameObject.scene);
			EditorSceneManager.MarkSceneDirty(SceneManager.GetActiveScene());
#endif
			
            EditorUtility.SetDirty(_script); 
        }
        //serializedObject.ApplyModifiedProperties();
    }
}
