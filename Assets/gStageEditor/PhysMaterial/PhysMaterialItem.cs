using UnityEngine;
using System.Collections;
using System.Collections.Generic;

[System.Serializable]
public class PhysMaterialItem
{
    public string itemName = "New Item";
    public Texture2D physMaterial = null;
    public Texture2D renderMaterial = null;
    public float Opacity = 0.65f;
    public List<bool> EditX = new List<bool>() { false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false};
    public List<bool> EditY = new List<bool>() { false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false };
}

[System.Serializable]
public class PhysMaterialItemList : ScriptableObject
{
    public List<PhysMaterialItem> physMaterialList;
}