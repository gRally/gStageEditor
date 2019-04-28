using UnityEngine;
using System.Collections;

public class LayoutTick : MonoBehaviour
{
	private float actualDistance;

	// Use this for initialization
	void Start ()
	{
        Debug.Log("LayoutTick Start");  
	}
	
	// Update is called once per frame
	void Update ()
	{
        Debug.Log("LayoutTick Update");  
		if (actualDistance > 100.0f && actualDistance < 110.0f)
		{
			Debug.Log("Distance between 100 and 110");	
		}
	}

	/// <summary>
	/// Updates the distance.
	/// </summary>
	/// <param name="newDistance">New distance.</param>
	public void UpdateDistance(float newDistance)
	{
		actualDistance = newDistance;
	}
}
