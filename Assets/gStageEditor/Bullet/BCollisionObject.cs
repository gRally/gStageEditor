using UnityEngine;
using System;
using System.Collections;
using BulletSharp;

namespace BulletUnity
{
    public class BCollisionObject : MonoBehaviour, IDisposable
    {
        //This is used to handle a design problem. 
        //We want OnEnable to add physics object to world and OnDisable to remove.
        //We also want user to be able to in script: AddComponent<CollisionObject>, configure it, add it to world, potentialy disable to delay it being added to world
        //Problem is OnEnable gets called before Start so that developer has no chance to configure object before it is added to world or prevent
        //It from being added.
        //Solution is not to add object to the world until after Start has been called. Start will do the first add to world. 
        protected bool m_startHasBeenCalled = false;

        protected CollisionObject m_collisionObject;
        protected BCollisionShape m_collisionShape;
        internal bool isInWorld = false;
        [SerializeField]
        protected BulletSharp.CollisionFlags m_collisionFlags = BulletSharp.CollisionFlags.None;
        [SerializeField]
        protected BulletSharp.CollisionFilterGroups m_groupsIBelongTo = BulletSharp.CollisionFilterGroups.DefaultFilter; // A bitmask
        [SerializeField]
        protected BulletSharp.CollisionFilterGroups m_collisionMask = BulletSharp.CollisionFilterGroups.AllFilter; // A colliding object must match this mask in order to collide with me.

        public virtual BulletSharp.CollisionFlags collisionFlags
        {
            get { return m_collisionFlags; }
            set {
                if (m_collisionObject != null && value != m_collisionFlags)
                {
                    m_collisionObject.CollisionFlags = value;
                    m_collisionFlags = value;
                } else
                {
                    m_collisionFlags = value;
                }
            }
        }

        public BulletSharp.CollisionFilterGroups groupsIBelongTo
        {
            get { return m_groupsIBelongTo; }
            set
            {
                if (m_collisionObject != null && value != m_groupsIBelongTo)
                {
                    Debug.LogError("Cannot change the collision group once a collision object has been created");
                } else 
                {
                    m_groupsIBelongTo = value;
                }
            }
        }

        public BulletSharp.CollisionFilterGroups collisionMask
        {
            get { return m_collisionMask; }
            set
            {
                if (m_collisionObject != null && value != m_collisionMask)
                {
                    Debug.LogError("Cannot change the collision mask once a collision object has been created");
                } else
                {
                    m_collisionMask = value;
                }
            }
        }
        public virtual void RemoveOnCollisionCallbackEventHandler()
        {
        }

        protected virtual void Awake()
        {
        }

        protected virtual void AddObjectToBulletWorld()
        {
        }

        protected virtual void RemoveObjectFromBulletWorld()
        {
        }

        protected virtual void Start()
        {
            m_startHasBeenCalled = true;
            AddObjectToBulletWorld();
        }

        protected virtual void OnEnable()
        {
            if (!isInWorld && m_startHasBeenCalled)
            {
                AddObjectToBulletWorld();
            }
        }

        protected virtual void OnDisable()
        {
            if (isInWorld)
            {
                RemoveObjectFromBulletWorld();
            }
        }

        protected virtual void OnDestroy()
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

        public virtual void SetPositionAndRotation(Vector3 position, Quaternion rotation)
        {
        }

        public virtual void SetRotation(Quaternion rotation)
        {
        }

    }
}
