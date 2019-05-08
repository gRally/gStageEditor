using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class RotateChild : MonoBehaviour
{
    public Transform childToRotate;
    [Range(-180, 180)]
    public float degrees;

    // Start is called before the first frame update
    void Start()
    {
        childToRotate.localRotation = Quaternion.Euler(0f, -degrees + 90f, 0f);
    }

#if UNITY_EDITOR
    // Update is called once per frame
    void Update()
    {
       childToRotate.localRotation = Quaternion.Euler(0f, -degrees +90f, 0f);
    }
#endif
}
