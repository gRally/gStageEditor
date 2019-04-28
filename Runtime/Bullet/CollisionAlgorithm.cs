using System;
using System.Runtime.InteropServices;
using System.Security;

namespace BulletSharp
{
	public class CollisionAlgorithmConstructionInfo : IDisposable
	{
		internal IntPtr _native;

		public CollisionAlgorithmConstructionInfo()
		{
		}

		public void Dispose()
		{
			Dispose(true);
			GC.SuppressFinalize(this);
		}

		protected virtual void Dispose(bool disposing)
		{
			if (_native != IntPtr.Zero)
			{
				_native = IntPtr.Zero;
			}
		}

		~CollisionAlgorithmConstructionInfo()
		{
			Dispose(false);
		}
	}

	public class CollisionAlgorithm : IDisposable
	{
		internal IntPtr _native;
        // NU private readonly bool _preventDelete;

		internal CollisionAlgorithm(IntPtr native, bool preventDelete = false)
		{
			_native = native;
            // NU _preventDelete = preventDelete;
		}

		public void Dispose()
		{
			Dispose(true);
			GC.SuppressFinalize(this);
		}

		protected virtual void Dispose(bool disposing)
		{
			if (_native != IntPtr.Zero)
			{
				_native = IntPtr.Zero;
			}
		}

		~CollisionAlgorithm()
		{
			Dispose(false);
		}
	}
}
