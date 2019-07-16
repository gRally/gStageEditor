using UnityEngine;
using System.Collections;
using BulletSharp;
using BM = BulletSharp.Math;
using System;
using System.Runtime.InteropServices;
using AOT;

namespace BulletUnity {
    public class BGameObjectMotionState : MotionState, IDisposable {

        public Transform transform;
        // gRally
        public Vector3 NewPosition;
        public Quaternion NewRotation;
        // OPT public Vector3 NewScale;
        public bool IsChanged = false;

        // NU BM.Matrix wt;

        public BGameObjectMotionState(Transform t) {
            transform = Native.UtoB(t);
        }

		public delegate void GetTransformDelegate(out BM.Matrix worldTrans);
		public delegate void SetTransformDelegate(ref BM.Matrix m);

        //Bullet wants me to fill in worldTrans
        //This is called by bullet once when rigid body is added to the the world
        //For kinematic rigid bodies it is called every simulation step
		//[MonoPInvokeCallback(typeof(GetTransformDelegate))]
        public override void GetWorldTransform(out BM.Matrix worldTrans) {
            BulletSharp.Math.Vector3 pos = transform.position.ToBullet();
            BulletSharp.Math.Quaternion rot = transform.rotation.ToBullet();
            BulletSharp.Math.Matrix.AffineTransformation(1f, ref rot, ref pos, out worldTrans);
        }

        //Bullet calls this so I can copy bullet data to unity
        public override void SetWorldTransform(ref BM.Matrix m) {
            // gRally
            IsChanged = true;
            NewPosition = BSExtensionMethods2.ExtractTranslationFromMatrix(ref m);
            NewRotation = BSExtensionMethods2.ExtractRotationFromMatrix(ref m);
            // OPT NewScale = Native.UtoB(BSExtensionMethods2.ExtractScaleFromMatrix(ref m));

            //transform.position = BSExtensionMethods2.ExtractTranslationFromMatrix(ref m);
            //transform.rotation = BSExtensionMethods2.ExtractRotationFromMatrix(ref m);
            //transform.localScale = BSExtensionMethods2.ExtractScaleFromMatrix(ref m);
        }
    }
}
