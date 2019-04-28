using System;
using UnityEngine;
using System.Collections;
using BulletSharp;

namespace BulletUnity {
	[AddComponentMenu("Physics Bullet/Shapes/Convex Hull")]
    public class BConvexHullShape : BCollisionShape {
        [SerializeField]
        protected Mesh hullMesh;
        public Mesh HullMesh
        {
            get { return hullMesh; }
            set
            {
                hullMesh = value;
            }
        }

        [SerializeField]
        protected Vector3 m_localScaling = Vector3.one;
        public Vector3 LocalScaling
        {
            get { return m_localScaling; }
            set
            {
                m_localScaling = value;
            }
        }

        //todo draw the hull when not in the world
        public override void OnDrawGizmosSelected() {
              
        }
    }
}
