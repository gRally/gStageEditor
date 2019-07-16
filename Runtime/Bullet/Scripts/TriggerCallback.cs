using UnityEngine;
using System.Collections;
using BulletSharp;
using BulletUnity;

public class TriggerCallback : BGhostObject
{
    public GameObject ReferenceObject;

    public override void BOnTriggerEnter(CollisionObject other, AlignedManifoldArray details)
    {
        Debug.LogError("Enter with "); // + other.UserObject + " fixedFrame " + BPhysicsWorld.Get().frameCount);
    }

    public override void BOnTriggerStay(CollisionObject other, AlignedManifoldArray details)
    {
        Debug.LogError("Stay with "); // + other.UserObject + " fixedFrame " + BPhysicsWorld.Get().frameCount);
    }

    public override void BOnTriggerExit(CollisionObject other)
    {
        Debug.LogError("Exit with "); // + other.UserObject + " fixedFrame " + BPhysicsWorld.Get().frameCount);
    }
}
