using System;
using System.Runtime.InteropServices;
using System.Security;
using BulletSharp.Math;

namespace BulletSharp
{
    public enum ActivationState
    {
        Undefined = 0,
        ActiveTag = 1,
        IslandSleeping = 2,
        WantsDeactivation = 3,
        DisableDeactivation = 4,
        DisableSimulation = 5
    }

	[Flags]
	public enum AnisotropicFrictionFlags
	{
		FrictionDisabled = 0,
		Friction = 1,
		RollingFriction = 2
	}

	[Flags]
	public enum CollisionFlags
	{
		None = 0,
		StaticObject = 1,
		KinematicObject = 2,
		NoContactResponse = 4,
		CustomMaterialCallback = 8,
		CharacterObject = 16,
		DisableVisualizeObject = 32,
		DisableSpuCollisionProcessing = 64
	}

	[Flags]
	public enum CollisionObjectTypes
	{
		None = 0,
		CollisionObject = 1,
		RigidBody = 2,
		GhostObject = 4,
		SoftBody = 8,
		HFFluid = 16,
		UserType = 32,
		FeatherstoneLink = 64
	}

	public class CollisionObject : IDisposable
	{
		internal IntPtr _native;
        private bool _isDisposed;

        public Vector3 AnisotropicFriction;
        public float CcdMotionThreshold;
        public float CcdSquareMotionThreshold;
        public float CcdSweptSphereRadius;
        public CollisionFlags CollisionFlags;
        public int CompanionId;
        public float ContactProcessingThreshold;
        public float DeactivationTime;
        public float Friction;
        public bool HasContactResponse;
        public float HitFraction;
        public CollisionObjectTypes InternalType;
        public Vector3 InterpolationAngularVelocity;
        public Vector3 InterpolationLinearVelocity;
        public Matrix InterpolationWorldTransform;
        public bool IsActive;
        public bool IsKinematicObject;
        public int IslandTag;
        public bool IsStaticObject;
        public bool IsStaticOrKinematicObject;
        public float Restitution;
        public float RollingFriction;
        public object UserObject;
        public int UserIndex;
        public Matrix WorldTransform;

        public override bool Equals(object obj)
        {
            CollisionObject colObj = obj as CollisionObject;
            if (colObj == null)
            {
                return false;
            }
            return _native == colObj._native;
        }

        public override int GetHashCode()
        {
            return _native.GetHashCode();
        }

		public void Dispose()
		{
			Dispose(true);
			GC.SuppressFinalize(this);
		}

		protected virtual void Dispose(bool disposing)
		{
            if (!_isDisposed)
			{
                _isDisposed = true;
			}
		}

		~CollisionObject()
		{
			Dispose(false);
		}
	}

    [StructLayout(LayoutKind.Sequential)]
    internal struct CollisionObjectFloatData
    {
        public IntPtr BroadphaseHandle;
        public IntPtr CollisionShape;
        public IntPtr RootCollisionShape;
        public IntPtr Name;
        public TransformFloatData WorldTransform;
        public TransformFloatData InterpolationWorldTransform;
        public Vector3FloatData InterpolationLinearVelocity;
        public Vector3FloatData InterpolationAngularVelocity;
        public Vector3FloatData AnisotropicFriction;
        public float ContactProcessingThreshold;	
        public float DeactivationTime;
        public float Friction;
        public float RollingFriction;
        public float Restitution;
        public float HitFraction; 
        public float CcdSweptSphereRadius;
        public float CcdMotionThreshold;
        public int HasAnisotropicFriction;
        public int CollisionFlags;
        public int IslandTag1;
        public int CompanionId;
        public int ActivationState1;
        public int InternalType;
        public int CheckCollideWith;
        public int Padding;

        public static int Offset(string fieldName) { return Marshal.OffsetOf(typeof(CollisionObjectFloatData), fieldName).ToInt32(); }
    }
}
