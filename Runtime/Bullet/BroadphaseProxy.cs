using System;
using System.Runtime.InteropServices;
using System.Security;
using BulletSharp.Math;

namespace BulletSharp
{
	public enum BroadphaseNativeType
	{
        BoxShape,
        TriangleShape,
        TetrahedralShape,
        ConvexTriangleMeshShape,
        ConvexHullShape,
        CONVEX_POINT_CLOUD_SHAPE_PROXYTYPE,
        CUSTOM_POLYHEDRAL_SHAPE_TYPE,
        IMPLICIT_CONVEX_SHAPES_START_HERE,
        SphereShape,
        MultiSphereShape,
        CapsuleShape,
        ConeShape,
        ConvexShape,
        CylinderShape,
        UniformScalingShape,
        MinkowskiSumShape,
        MinkowskiDifferenceShape,
        Box2DShape,
        Convex2DShape,
        CUSTOM_CONVEX_SHAPE_TYPE,
        CONCAVE_SHAPES_START_HERE,
        TriangleMeshShape,
        SCALED_TRIANGLE_MESH_SHAPE_PROXYTYPE,
        FAST_CONCAVE_MESH_PROXYTYPE,
        TerrainShape,
        GImpactShape,
        MultiMaterialTriangleMesh,
        EmptyShape,
        StaticPlaneShape,
        CUSTOM_CONCAVE_SHAPE_TYPE,
        CONCAVE_SHAPES_END_HERE,
        CompoundShape,
        SoftBodyShape,
        HFFLUID_SHAPE_PROXYTYPE,
        HFFLUID_BUOYANT_CONVEX_SHAPE_PROXYTYPE,
        INVALID_SHAPE_PROXYTYPE,
        MAX_BROADPHASE_COLLISION_TYPES
	}

	[Flags]
	public enum CollisionFilterGroups
	{
		None = 0,
		DefaultFilter = 1,
		StaticFilter = 2,
		KinematicFilter = 4,
		DebrisFilter = 8,
		SensorTrigger = 16,
		CharacterFilter = 32,
        AllFilter = -1
	}

	public class BroadphaseProxy
	{
		internal IntPtr _native;
        private Object _clientObject;

		internal BroadphaseProxy(IntPtr native)
		{
			_native = native;
		}

        public Vector3 AabbMax;
        public Vector3 AabbMin;
        public short CollisionFilterGroup;
        public short CollisionFilterMask;
        public IntPtr MultiSapParentProxy;
        public int Uid;
        public int UniqueId;
	}

	public class BroadphasePair
	{
		internal IntPtr _native;

		internal BroadphasePair(IntPtr native)
		{
			_native = native;
		}

        public CollisionAlgorithm Algorithm;
        public BroadphaseProxy Proxy0;
        public BroadphaseProxy Proxy1;
	}
}
