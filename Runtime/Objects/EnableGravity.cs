/// gRally EnableGravity script
/// It activate Gravity after a physic collision

using System.Collections.Generic;
using System.Collections;
using UnityEngine;

public class EnableGravity : MonoBehaviour
{
    Rigidbody rb;
    Collider col;
    public bool isGravited = false;

    void Start()
    {
        rb = GetComponent<Rigidbody>();
        col = GetComponent<Collider>();
        rb.useGravity = false;
        col.isTrigger = true;
    }

    void OnTriggerEnter(Collider other)
    {
        if (isGravited) return;

        if (other.tag == "Player")
        {
            Gravity();
        }
    }

    public void Gravity()
    {
        isGravited = true;
        StartCoroutine(GravityEnumerator());
    }

    IEnumerator GravityEnumerator()
    {
        col.isTrigger = false;
        yield return 0;
        yield return 1;
        yield return 2;
        rb.useGravity = true;
        yield return 3;
    }
}
