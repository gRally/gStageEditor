using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class gRoadSigns : MonoBehaviour
{
    //public Material mat;
    public int SignId;
    private int fSignId;
    public string shaderPropertyName;

    // Use this for initialization
    void Start()
    {
        MaterialPropertyBlock propertyBlock = new MaterialPropertyBlock();
        propertyBlock.SetFloat(shaderPropertyName, SignId);
        GetComponent<MeshRenderer>().SetPropertyBlock(propertyBlock);
    }

#if UNITY_EDITOR
    // Update is called once per frame
    void Update()
    {
        if (fSignId != SignId)
        {
            MaterialPropertyBlock propertyBlock = new MaterialPropertyBlock();
            propertyBlock.SetFloat(shaderPropertyName, SignId);
            GetComponent<MeshRenderer>().SetPropertyBlock(propertyBlock);
            //mat.SetFloat("_gRoadSigns_index_squared", SignId);
            fSignId = SignId;
        }
    }
#endif
}
