/// gRally StageResources script


using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StageResources : MonoBehaviour
{
    /// <summary>
    /// place a loaded object
    /// </summary>
    /// <param name="parent"></param>
    /// <param name="prefab"></param>
    /// <param name="position"></param>
    /// <param name="orientation"></param>
    /// <param name="heightDetection"></param>
    /// <param name="meshName"></param>
    /// <param name="tagColliderToExclude"></param>
    /// <returns></returns>
    public GameObject CreateMeshFromObject(Transform parent, Object prefab, Vector3 position, Quaternion orientation, HEIGHT_DETECTION heightDetection, string meshName, string tagColliderToExclude = null)
    {
        if (heightDetection != HEIGHT_DETECTION.PLACE_AS_IS)
        {
            position = position + Vector3.up * 1000f;
        }

        if (!string.IsNullOrEmpty(tagColliderToExclude))
        {
            // check before
            RaycastHit hit;
            var raHit = Physics.Raycast(position + new Vector3(0f, 100f, 0f), Vector3.down, out hit);
            if (raHit)
            {
                if (hit.transform.tag == tagColliderToExclude)
                {
                    return null;
                }
            }
        }

        var inst = Instantiate(prefab as GameObject);
        inst.transform.position = position;
        inst.transform.rotation = orientation;
        inst.transform.SetParent(parent);
        inst.name = meshName;

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

    /// <summary>
    /// create a mesh reading a prefab
    /// </summary>
    /// <param name="isStatic"></param>
    /// <param name="parent"></param>
    /// <param name="resourceName">resource name: if different from Default, try to use this, otherwise search Default</param>
    /// <param name="prefabName"></param>
    /// <param name="position"></param>
    /// <param name="orientation"></param>
    /// <param name="meshName"></param>
    /// <param name="tagColliderToExclude"></param>
    public GameObject CreateMeshFromPrefab(bool isStatic, Transform parent, string resourceName, string prefabName, Vector3 position, Quaternion orientation, HEIGHT_DETECTION heightDetection, string meshName, string tagColliderToExclude = null)
    {
        if (heightDetection != HEIGHT_DETECTION.PLACE_AS_IS)
        {
            position = position + Vector3.up * 100f;
        }

        if (!string.IsNullOrEmpty(tagColliderToExclude))
        {
            // check before
            if (NeedToBeExcluded(position, tagColliderToExclude))
            {
                return null;
            }
        }

        var currentPath = $"{resourceName}/{prefabName}";
        var go_instance = Resources.Load<GameObject>(currentPath);

        if (resourceName != "Default" && go_instance == null)
        {
            currentPath = $"Default/{prefabName}";
            go_instance = Resources.Load<GameObject>(currentPath);
        }

        var inst = Instantiate(go_instance); //Resources.Load<GameObject>(currentPath));
        inst.transform.position = position;
        inst.transform.rotation = orientation;
        inst.transform.SetParent(parent);
        inst.name = meshName == null ? prefabName : meshName;
        inst.isStatic = isStatic;

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

    public bool NeedToBeExcluded(Vector3 position, string tagColliderToExclude)
    {
        var raHit = Physics.RaycastAll(position + new Vector3(0f, 100f, 0f), Vector3.down);
        if (raHit != null)
        {
            foreach (var hit in raHit)
            {
                if (hit.transform.tag == tagColliderToExclude)
                {
                    return true;
                }
            }
        }
        return false;
    }

    public GameObject CreateMeshFromGameObject(bool isStatic, Transform parent, GameObject gameObject, Vector3 position, Quaternion orientation, HEIGHT_DETECTION heightDetection, string meshName, string tagColliderToExclude = null)
    {
        if (heightDetection != HEIGHT_DETECTION.PLACE_AS_IS)
        {
            position = position + Vector3.up * 100f;
        }

        if (!string.IsNullOrEmpty(tagColliderToExclude))
        {
            // check before
            var raHit = Physics.RaycastAll(position + new Vector3(0f, 100f, 0f), Vector3.down);
            if (raHit != null)
            {
                foreach (var hit in raHit)
                {
                    if (hit.transform.tag == tagColliderToExclude)
                    {
                        return null;
                    }
                }
            }
        }

        var inst = Instantiate(gameObject); //Resources.Load<GameObject>(currentPath));
        inst.transform.position = position;
        inst.transform.rotation = orientation;
        inst.transform.SetParent(parent);
        inst.name = meshName == null ? gameObject.name : meshName;
        inst.isStatic = isStatic;

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

    public bool MeshIsPlaceable(Vector3 position, string tagColliderToExclude = null)
    {
        if (!string.IsNullOrEmpty(tagColliderToExclude))
        {
            // check before
            RaycastHit hit;
            var raHit = Physics.Raycast(position + new Vector3(0f, 200f, 0f), Vector3.down, out hit);
            if (raHit)
            {
                if (hit.transform.tag == tagColliderToExclude)
                {
                    return false;
                }
                return true;
            }
        }
        return false;
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
        Vector3 point;

        var matrix = obj.transform.localToWorldMatrix;

        var lod = obj.GetComponent<LODGroup>();
        Mesh mesh;
        if (lod != null)
        {
            var lod0 = lod.GetLODs()[0];
            mesh = lod0.renderers[0].gameObject.GetComponent<MeshFilter>().sharedMesh;
        }
        else
        {
            var mf = obj.GetComponent<MeshFilter>();
            if (mf == null)
            {
                var mfs = obj.GetComponentsInChildren<MeshFilter>();
                foreach (var item in mfs)
                {
                    if (!item.name.ToLower().EndsWith("col"))
                    {
                        mf = item;
                        matrix = mf.transform.localToWorldMatrix;
                    }
                }
            }
            mesh = mf.sharedMesh;
        }
        point = matrix.MultiplyPoint(mesh.bounds.min);
        /* single.. gives some issues
        bool raHit = false;
        RaycastHit hit;
        raHit = Physics.Raycast(point, Vector3.down, out hit);
        if (raHit)
        {
            obj.transform.position = obj.transform.position - new Vector3(0.0f, hit.distance, 0.0f);
        }*/
        foreach (var hit in Physics.RaycastAll(point, Vector3.down))
        {
            if (hit.collider.gameObject.layer == 21 || hit.collider.gameObject.layer == 31 || hit.collider.gameObject.layer == 23)
            {
                obj.transform.position = obj.transform.position - new Vector3(0.0f, hit.distance, 0.0f);
                break;
            }
        }
    }

    protected void PivotOnGround(GameObject obj)
    {
        /* single... gives some issues
        RaycastHit hit;
        var raHit = Physics.Raycast(obj.transform.position, Vector3.down, out hit);
        if (raHit)
        {
            obj.transform.position = obj.transform.position - new Vector3(0.0f, hit.distance, 0.0f);
        }
        */
        foreach (var hit in Physics.RaycastAll(obj.transform.position, Vector3.down))
        {
            if (hit.collider.gameObject.layer == 21 || hit.collider.gameObject.layer == 31 || hit.collider.gameObject.layer == 23)
            {
                obj.transform.position = obj.transform.position - new Vector3(0.0f, hit.distance, 0.0f);
                break;
            }
        }

    }
}

public enum HEIGHT_DETECTION
{
    LOWER_POINT_AT_GROUND,
    PIVOT_AT_GROUND,
    PLACE_AS_IS
}