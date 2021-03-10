using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
#if UNITY_EDITOR
using UnityEditor;
#endif
using System.IO;

[System.Serializable]
public class PhysMaterialItem
{
    public Material material;
    public string pathMaterial;
    public string pathPhysMaterial;
    public Texture2D physMaterial = null;
    public Texture2D renderMaterial = null;
    public int Version = 1;
    public float Opacity = 0.65f;
    public List<bool> EditX = new List<bool>() { false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false };
    public List<bool> EditY = new List<bool>() { false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false };

    public void GetTexturePath(bool loadFromScene)
    {
#if UNITY_EDITOR
        pathMaterial = Path.GetDirectoryName(AssetDatabase.GetAssetPath(material));
        if (physMaterial != null)
        {
            // exists!
            pathPhysMaterial = AssetDatabase.GetAssetPath(physMaterial);
        }
        else
        {
            // new!
            //if (loadFromScene)
            {
                var newPath = GetPathUpLevel(pathMaterial, 2);
                newPath = Path.Combine(newPath, "PhysTextures");
                if (!Directory.Exists(newPath))
                {
                    Directory.CreateDirectory(newPath);
                }
                pathPhysMaterial = Path.Combine(newPath, $"ph_{material.name}.png");
            }
            /*
            else
            {
                var mainPath = pathMaterial;
                mainPath = Path.GetDirectoryName(mainPath);
                mainPath = mainPath.Replace("Textures", "PhysTextures");
                pathPhysMaterial = $"{mainPath}/ph_{material.name}.png";
                if (!Directory.Exists(mainPath))
                {
                    Directory.CreateDirectory(mainPath);
                }
            }
            */
            if (File.Exists(pathPhysMaterial))
            {
                physMaterial = AssetDatabase.LoadAssetAtPath<Texture2D>(pathPhysMaterial);
                if (Version == 1)
                {
                    material.SetTexture("_PhysMap", physMaterial);
                }
                else if (Version == 2)
                {
                    material.SetTexture("_PhysicalTexture", physMaterial);
                }
            }
        }
#endif
    }

    string GetPathUpLevel(string path, int levelUp)
    {
        var splitResult = path.Split(new[] { '/', '\\' }, System.StringSplitOptions.RemoveEmptyEntries);
        var newFilePath = Path.Combine(splitResult.Take(splitResult.Length - levelUp).ToArray());
        return newFilePath;
    }
}

[System.Serializable]
public class PhysMaterialItemList : ScriptableObject
{
    public List<PhysMaterialItem> physMaterialList;
    //public List<PhysMaterialItem> filteredMaterialList;
    //string lastFilterPath = "******************";
    public void Sort()
    {
        physMaterialList = physMaterialList.OrderBy(o => o.pathMaterial).ToList();
        // FilterPath("");
    }
    /*
    public void FilterPath(string filterPath)
    {
        if (lastFilterPath != filterPath)
        {
            filteredMaterialList = physMaterialList.Where(x => x.pathMaterial.ToLower().Contains(filterPath.ToLower())).OrderBy(o => o.pathMaterial).ToList();
            lastFilterPath = filterPath;
        }
    }*/
}