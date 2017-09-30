using System;
using UnityEngine;
using System.Collections;

namespace BulletUnity {
    /*
        todo 
        continuous collision detection ccd
        */
    [AddComponentMenu("Physics Bullet/RigidBody")]
    public class BRigidBody : BCollisionObject, IDisposable
    {
        BulletSharp.Math.Vector3 _localInertia = BulletSharp.Math.Vector3.Zero;
        public BulletSharp.Math.Vector3 localInertia
        {
            get
            {
                return _localInertia;
            }
        }

        public bool isDynamic;

        [SerializeField]
        float _friction = .5f;
        public float friction
        {
            get { return _friction; }
            set 
            {
                _friction = value;
            }
        }

        [SerializeField]
        float _rollingFriction = 0f;
        public float rollingFriction
        {
            get { return _rollingFriction; }
            set
            {
                _rollingFriction = value;
            }
        }

        [SerializeField]
        float _linearDamping = 0f;
        public float linearDamping
        {
            get { return _linearDamping; }
            set
            {
                _linearDamping = value;
            }
        }

        [SerializeField]
        float _angularDamping = 0f;
        public float angularDamping
        {
            get { return _angularDamping; }
            set
            {
                _angularDamping = value;
            }
        }

        [SerializeField]
        float _restitution = 0f;
        public float restitution
        {
            get { return _restitution; }
            set
            {
                _restitution = value;
            }
        }

        [SerializeField]
        float _linearSleepingThreshold = .8f;
        public float linearSleepingThreshold
        {
            get { return _linearSleepingThreshold; }
            set
            {
                _linearSleepingThreshold = value;
            }
        }

        [SerializeField]
        float _angularSleepingThreshold = 1f;
        public float angularSleepingThreshold
        {
            get { return _angularSleepingThreshold; }
            set
            {
                _angularSleepingThreshold = value;
            }
        }

        [SerializeField]
        bool _additionalDamping = false;
        public bool additionalDamping
        {
            get { return _additionalDamping; }
            set
            {
                _additionalDamping = value;
            }
        }

        [SerializeField]
        float _additionalDampingFactor = .005f;
        public float additionalDampingFactor
        {
            get { return _additionalDampingFactor; }
            set
            {
                _additionalDampingFactor = value;
            }
        }

        [SerializeField]
        float _additionalLinearDampingThresholdSqr = .01f;
        public float additionalLinearDampingThresholdSqr
        {
            get { return _additionalLinearDampingThresholdSqr; }
            set
            {
                _additionalLinearDampingThresholdSqr = value;
            }
        }

        [SerializeField]
        float _additionalAngularDampingThresholdSqr = .01f;
        public float additionalAngularDampingThresholdSqr
        {
            get { return _additionalAngularDampingThresholdSqr; }
            set
            {
                _additionalAngularDampingThresholdSqr = value;
            }
        }

        [SerializeField]
        float _additionalAngularDampingFactor = .01f;
        public float additionalAngularDampingFactor
        {
            get { return _additionalAngularDampingFactor; }
            set
            {
                _additionalAngularDampingFactor = value;
            }
        }

        /* can lock axis with this */
        [SerializeField]
        UnityEngine.Vector3 _linearFactor = UnityEngine.Vector3.one;
        public UnityEngine.Vector3 linearFactor
        {
            get { return _linearFactor; }
            set
            {
                _linearFactor = value;
            }
        }

        [SerializeField]
        UnityEngine.Vector3 _angularFactor = UnityEngine.Vector3.one;
        public UnityEngine.Vector3 angularFactor
        {
            get { return _angularFactor; }
            set
            {
                _angularFactor = value;
            }
        }

        [SerializeField]
        float _mass = 1f;
        public float mass
        {
            set
            {
                if (_mass != value)
                {
                    _mass = value;
                }
            }
            get
            {
                return _mass;
            }
        }

        public UnityEngine.Vector3 velocity;
        public UnityEngine.Vector3 angularVelocity;
    }
}
