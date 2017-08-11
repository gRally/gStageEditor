using System;
using UnityEngine;
using System.Collections;
using BulletSharp;
using BM = BulletSharp.Math;

namespace BulletUnity {
    [AddComponentMenu("Physics Bullet/Constraints/6 Degree Of Freedom")]
    public class B6DOFConstraintEdit : MonoBehaviour {
        //Todo not sure if this is working
        //todo should be properties so can capture changes and propagate to scene
        public static string HelpMessage = "\n" +
                                            "\nTIP: To see constraint limits:\n" +
                                            "  - In BulletPhysicsWorld turn on 'Do Debug Draw' and set 'Debug Draw Mode' flags\n" +
                                            "  - On Constraint set 'Debug Draw Size'\n" +
                                            "  - Press play";
        public enum ConstraintType
        {
            constrainToPointInSpace,
            constrainToAnotherBody
        }

        [Header("Reference Frame Local To This Object")]
        [SerializeField]
        protected Vector3 m_localConstraintPoint = Vector3.zero;
        public Vector3 localConstraintPoint
        {
            get { return m_localConstraintPoint; }
            set
            {
                m_localConstraintPoint = value;
            }
        }

        [SerializeField]
        protected Vector3 m_localConstraintAxisX = Vector3.forward;
        public Vector3 localConstraintAxisX
        {
            get { return m_localConstraintAxisX; }
            set
            {
                m_localConstraintAxisX = value;
            }
        }

        [SerializeField]
        protected Vector3 m_localConstraintAxisY = Vector3.up;
        public Vector3 localConstraintAxisY
        {
            get { return m_localConstraintAxisY; }
            set
            {
                m_localConstraintAxisY = value;
            }
        }

        [SerializeField]
        protected float m_breakingImpulseThreshold = Mathf.Infinity;
        public float breakingImpulseThreshold
        {
            get { return m_breakingImpulseThreshold; }
            set
            {
                m_breakingImpulseThreshold = value;
            }
        }

        [SerializeField]
        protected bool m_disableCollisionsBetweenConstrainedBodies = true;
        public bool disableCollisionsBetweenConstrainedBodies
        {
            get { return m_disableCollisionsBetweenConstrainedBodies; }
            set
            {
                m_disableCollisionsBetweenConstrainedBodies = value;
            }
        }

        [SerializeField]
        protected ConstraintType m_constraintType;
        public ConstraintType constraintType
        {
            get { return m_constraintType; }
            set
            {
                m_constraintType = value;
            }
        }

        [HideInInspector]
        [SerializeField]
        protected BRigidBody m_thisRigidBody;
        public BRigidBody thisRigidBody
        {
            get { return m_thisRigidBody; }
            set
            {
                m_thisRigidBody = value;
            }
        }

        [SerializeField]
        protected BRigidBody m_otherRigidBody;
        public BRigidBody otherRigidBody
        {
            get { return m_otherRigidBody; }
            set
            {
                m_otherRigidBody = value;
            }
        }

        [SerializeField]
        protected float m_debugDrawSize;
        public float debugDrawSize
        {
            get { return m_debugDrawSize; }
            set
            {
                m_debugDrawSize = value;
            }
        }

        [SerializeField]
        protected int m_overrideNumSolverIterations = 20;
        public int overrideNumSolverIterations
        {
            get { return m_overrideNumSolverIterations; }
            set
            {
                if (value < 1) value = 1;
                m_overrideNumSolverIterations = value;
            }
        }

        [Header("Limits")]
        [SerializeField]
        protected Vector3 m_linearLimitLower;
        public Vector3 linearLimitLower
        {
            get { return m_linearLimitLower; }
            set
            {
                m_linearLimitLower = value;
            }
        }

        [SerializeField]
        protected Vector3 m_linearLimitUpper;
        public Vector3 linearLimitUpper
        {
            get { return m_linearLimitUpper; }
            set
            {
                m_linearLimitUpper = value;
            }
        }

        [SerializeField]
        protected Vector3 m_angularLimitLowerRadians;
        public Vector3 angularLimitLowerRadians
        {
            get { return m_angularLimitLowerRadians; }
            set
            {
                m_angularLimitLowerRadians = value;
            }
        }

        [SerializeField]
        protected Vector3 m_angularLimitUpperRadians;
        public Vector3 angularLimitUpperRadians
        {
            get { return m_angularLimitUpperRadians; }
            set
            {
                m_angularLimitUpperRadians = value;
            }
        }

        [Header("Motor")]
        [SerializeField]
        protected Vector3 m_motorLinearTargetVelocity;
        public Vector3 motorLinearTargetVelocity
        {
            get { return m_motorLinearTargetVelocity; }
            set
            {
                m_motorLinearTargetVelocity = value;
            }
        }

        [SerializeField]
        protected Vector3 m_motorLinearMaxMotorForce;
        public Vector3 motorLinearMaxMotorForce
        {
            get { return m_motorLinearMaxMotorForce; }
            set
            {
                m_motorLinearMaxMotorForce = value;
            }
        }
    }
}
