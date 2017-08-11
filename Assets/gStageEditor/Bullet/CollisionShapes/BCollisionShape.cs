using UnityEngine;
using System;
using System.Collections;

namespace BulletUnity {
    [System.Serializable]
    public abstract class BCollisionShape : MonoBehaviour, IDisposable {
        public enum CollisionShapeType {
            // dynamic
            BoxShape = 0,
            SphereShape = 1,
            CapsuleShape = 2,
            CylinderShape = 3,
            ConeShape = 4,
            ConvexHull = 5,
            CompoundShape = 6,

            // static
            BvhTriangleMeshShape = 7,
            StaticPlaneShape = 8,
        };

        public bool drawGizmo = true;
        void OnDestroy()
        {
            Dispose(false);
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        protected virtual void Dispose(bool isdisposing)
        {
        }

        public abstract void OnDrawGizmosSelected();
    }
}
