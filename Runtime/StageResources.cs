using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StageResources : MonoBehaviour
{
    /// <summary>
    /// create a mesh reading a prefab
    /// </summary>
    /// <param name="parent"></param>
    /// <param name="resourceName">resource name: if different from Default, try to use this, otherwise search Default</param>
    /// <param name="prefabName"></param>
    /// <param name="position"></param>
    /// <param name="orientation"></param>
    /// <param name="meshName"></param>
    public GameObject CreateMeshFromPrefab(Transform parent, string resourceName, string prefabName, Vector3 position, Quaternion orientation, HEIGHT_DETECTION heightDetection, string meshName = null)
    {
        if (heightDetection != HEIGHT_DETECTION.PLACE_AS_IS)
        {
            position = position + Vector3.up * 100f;
        }

        var currentPath = $"{resourceName}/{prefabName}";
        var go_instance = Resources.Load<GameObject>(currentPath);

        if (resourceName != "Default" && go_instance == null)
        {
            currentPath = $"Default/{prefabName}";
            go_instance = Resources.Load<GameObject>(currentPath);
        }

        var inst = Instantiate(Resources.Load<GameObject>(currentPath));
        inst.transform.position = position;
        inst.transform.rotation = orientation;
        inst.transform.SetParent(parent);
        inst.name = meshName == null ? prefabName : meshName;

        switch (heightDetection)
        {
            case HEIGHT_DETECTION.LOWER_POINT_AT_GROUND:
                LowerOnGround(inst);
                break;
            case HEIGHT_DETECTION.PIVOT_AT_GROUND:
                PivotOnGround(inst);
                break;
        }
        return inst;
    }

    protected Material GetMaterial(string resourceName, string materialName)
    {
        var currentPath = $"{resourceName}/{materialName}";
        var mat = Resources.Load<Material>(currentPath);
        if (resourceName != "Default" && mat == null)
        {
            currentPath = $"Default/{materialName}";
            mat = Resources.Load<Material>(currentPath);
        }
        return mat;
    }

    /*
    protected Vector3 GetPivotOffset(GameObject obj)
    {
        var bulletRigidBody = obj.GetComponent<BulletUnity.BRigidBody>();
        if (bulletRigidBody == null)
        {
            return Vector3.zero;
        }
        else
        {
            var objectSize = Vector3.Scale(transform.localScale, obj.GetComponent<Mesh>().bounds.size);
            return new Vector3(0f, objectSize.y * 0.5f, 0f);
        }
    }
    */

    protected void LowerOnGround(GameObject obj)
    {
        var mesh = obj.GetComponent<MeshFilter>().sharedMesh;
        var matrix = obj.transform.localToWorldMatrix;

        RaycastHit hit;

        var point = matrix.MultiplyPoint(mesh.bounds.min);
        var raHit = Physics.Raycast(point, Vector3.down, out hit);
        if (raHit)
        {
            obj.transform.position = obj.transform.position - new Vector3(0.0f, hit.distance, 0.0f);
        }
    }

    protected void PivotOnGround(GameObject obj)
    {
        RaycastHit hit;
        var raHit = Physics.Raycast(obj.transform.position, Vector3.down, out hit);
        if (raHit)
        {
            obj.transform.position = obj.transform.position - new Vector3(0.0f, hit.distance, 0.0f);
        }
    }
}

public enum HEIGHT_DETECTION
{
    LOWER_POINT_AT_GROUND,
    PIVOT_AT_GROUND,
    PLACE_AS_IS
}