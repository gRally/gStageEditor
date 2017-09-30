using System;
using UnityEngine;
using System.Collections;
using BulletSharp;

namespace BulletUnity
{
    [AddComponentMenu("Physics Bullet/Shapes/Cylinder")]
    public class BCylinderShape : BCollisionShape
    {
        [SerializeField]
        protected Vector3 halfExtent = new Vector3(0.5f, 0.5f, 0.5f);
        public Vector3 HalfExtent
        {
            get { return halfExtent; }
            set
			{
				halfExtent = value;
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

        public override void OnDrawGizmosSelected()
        {
            if (drawGizmo == false)
            {
                return;
            }
            UnityEngine.Vector3 position = transform.position;
            UnityEngine.Quaternion rotation = transform.rotation;
            UnityEngine.Vector3 scale = m_localScaling;
            BUtility.DebugDrawCylinder(position, rotation, scale, halfExtent.x, halfExtent.y, 1, Color.yellow);
        }

    }
}