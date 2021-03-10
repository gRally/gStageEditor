using System;
using UnityEngine;
using System.Collections;
using BulletSharp;
using System.Linq;

namespace BulletUnity
{
    [AddComponentMenu("Physics Bullet/Shapes/Convex Hull")]
    public class BConvexHullShape : BCollisionShape
    {
        [SerializeField]
        protected Mesh hullMesh;
        public Mesh HullMesh
        {
            get { return hullMesh; }
            set
            {
                if (collisionShapePtr != null && value != hullMesh)
                {
                    Debug.LogError("Cannot change the Hull Mesh after the bullet shape has been created. This is only the initial value " +
                                    "Use LocalScaling to change the shape of a bullet shape.");
                }
                else
                {
                    hullMesh = value;
                }
            }
        }
        /*
        [SerializeField]
        protected Vector3 m_localScaling = Vector3.one;
        public Vector3 LocalScaling
        {
            get { return m_localScaling; }
            set
            {
                m_localScaling = value;
                if (collisionShapePtr != null)
                {
                    ((ConvexHullShape)collisionShapePtr).LocalScaling = value.ToBullet();
                }
            }
        }
        */

        //todo draw the hull when not in the world
        public override void OnDrawGizmosSelected()
        {

        }

        ConvexHullShape _CreateConvexHullShape()
        {
            return null;
        }

        public override CollisionShape CopyCollisionShape()
        {
            return _CreateConvexHullShape();
        }

        public override CollisionShape GetCollisionShape()
        {
            if (collisionShapePtr == null)
            {
                collisionShapePtr = _CreateConvexHullShape();
            }
            return collisionShapePtr;
        }
    }
}
