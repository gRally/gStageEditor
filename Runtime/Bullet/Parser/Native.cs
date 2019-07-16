using System.Runtime.InteropServices;

namespace BulletSharp
{
    public static class Native
    {
#if UNITY_IOS && !UNITY_EDITOR
        public const string Dll = "__Internal";
#else
        public const string Dll = "gSim_64"; // gRally "libbulletc";
#endif
        public const CallingConvention Conv = CallingConvention.Cdecl;

        
        public static UnityEngine.Transform UtoB(UnityEngine.Transform original)
        {
            var ret = original;
            ret.position = new UnityEngine.Vector3(original.position.x, original.position.z, original.position.y);
            ret.rotation = new UnityEngine.Quaternion(original.rotation.x, original.rotation.z, original.rotation.y, -original.rotation.w);
            ret.localScale = new UnityEngine.Vector3(original.localScale.x, original.localScale.z, original.localScale.y);
            return ret;
        }

        public static UnityEngine.Vector3 UtoB(UnityEngine.Vector3 original)
        {
            var ret = new UnityEngine.Vector3(original.x, original.z, original.y);
            return ret;
        }

        public static UnityEngine.Quaternion UtoB(UnityEngine.Quaternion original)
        {
            var ret = new UnityEngine.Quaternion(original.x, original.z, original.y, -original.w);
            return ret;
        }
    }
}
