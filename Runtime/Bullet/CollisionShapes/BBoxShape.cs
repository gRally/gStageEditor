using System;
using UnityEngine;
using System.Collections;
using BulletSharp;

namespace BulletUnity {
	[AddComponentMenu("Physics Bullet/Shapes/Box")]
    public class BBoxShape : BCollisionShape {
        //public Vector3 extents = Vector3.one;

        [SerializeField]
        protected Vector3 extents = Vector3.one;
        public Vector3 Extents
        {
            get { return extents; }
            set
            {
                if (value != extents)
                {
                    Debug.LogError("Cannot change the extents after the bullet shape has been created. Extents is only the initial value " +
                                    "Use LocalScaling to change the shape of a bullet shape.");
                } else {
                    extents = value;
                }
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

        public override void OnDrawGizmosSelected() {
            if (drawGizmo == false)
            {
                return;
            }
            Vector3 position = transform.position;
            Quaternion rotation = transform.rotation;
            Vector3 scale = m_localScaling;
            BUtility.DebugDrawBox(position, rotation, scale, extents, Color.yellow);
        }

    }
}
