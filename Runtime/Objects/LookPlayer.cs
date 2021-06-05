using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LookPlayer : MonoBehaviour
{
    public int updateEachFrames = 2;
    public Transform objectToRotate;
    public GameObject player;

    void Update()
    {
        if (player == null)
        {
            player = GameObject.FindWithTag("Player");
        }
        else
        {
            if (Time.frameCount % updateEachFrames != 0)
            {
                return;
            }
            objectToRotate.transform.rotation = Quaternion.LookRotation(player.transform.position - objectToRotate.transform.position);
        }
    }
}
