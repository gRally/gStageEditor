using UnityEngine;
using System.Collections;
using System;
using System.Runtime.InteropServices;
using System.Security;

public class SoftRigidDynamicsWorld_NO
{
    [DllImport("gSim_64", CallingConvention = CallingConvention.Cdecl), SuppressUnmanagedCodeSecurity]
    private static extern void btDynamicsWorld_addRigidBody2(IntPtr obj, IntPtr body, short group, short mask);

    // NU IntPtr _native;
    public SoftRigidDynamicsWorld_NO(IntPtr native)
    {
        // NU _native = native;
    }

    public void AddRigidBody()
    {

    }
}
