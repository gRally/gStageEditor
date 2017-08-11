using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class testLerp : MonoBehaviour
{

    public Material material1;
    public Material material2;

	public float duration = 2.0F;
    public Renderer rend;
	public GameObject objectToRender;

	// Use this for initialization
	void Start ()
	{
		rend = objectToRender.GetComponent<Renderer>();
		rend.material = material1;
	}
	
	// Update is called once per frame
	void Update ()
	{
		float lerp = Mathf.PingPong(Time.time, duration) / duration;
		rend.material.Lerp(material1, material2, lerp);
	}
}
