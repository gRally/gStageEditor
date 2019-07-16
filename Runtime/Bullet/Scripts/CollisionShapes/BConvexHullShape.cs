using System;
using UnityEngine;
using System.Collections;
using BulletSharp;
using System.Linq;

namespace BulletUnity {
	[AddComponentMenu("Physics Bullet/Shapes/Convex Hull")]
    public class BConvexHullShape : BCollisionShape {
        [SerializeField]
        protected Mesh hullMesh;
        public Mesh HullMesh
        {
            get { return hullMesh; }
            set
            {
                if (collisionShapePtr != null && value != hullMesh)
                {
                    Debug.LogError("Cannot change the Hull Mesh after the bullet shape has been created. This is only the initial value " +
                                    "Use LocalScaling to change the shape of a bullet shape.");
                }
                else {
                    hullMesh = value;
                }
            }
        }

        [SerializeField]
        protected Vector3 m_localScaling = Vector3.one;
        public Vector3 LocalScaling
        {
            get { return m_localScaling; }
            set
            {
                m_localScaling = value;
                if (collisionShapePtr != null)
                {
                    ((ConvexHullShape) collisionShapePtr).LocalScaling = value.ToBullet();
                }
            }
        }

        //todo draw the hull when not in the world
        public override void OnDrawGizmosSelected() {
              
        }

        ConvexHullShape _CreateConvexHullShape()
        {
            /* #gStageEditor 
            if (hullMesh == null)
            {
                // find the mesh
                var mesh = transform.GetComponent<MeshFilter>();
                var vertex = mesh.sharedMesh.vertices;
                var vertices = vertex.Select(x => new Vertex(x)).ToList();
                var result = MIConvexHull.ConvexHull.Create(vertices);
                var newVertices = result.Points.Select(x => x.ToVec()).ToArray();
                float[] points = new float[newVertices.Length * 3];
                for (int i = 0; i < newVertices.Length; i++)
                {
                    int idx = i * 3;
                    points[idx] = newVertices[i].x;
                    points[idx + 1] = newVertices[i].z;
                    points[idx + 2] = newVertices[i].y;
                }
                ConvexHullShape cs = new ConvexHullShape(points);
                cs.LocalScaling = m_localScaling.ToBullet();
                return cs;
            }
            else
            {
                var vertex = hullMesh.vertices;
                var vertices = vertex.Select(x => new Vertex(x)).ToList();
                var result = MIConvexHull.ConvexHull.Create(vertices);
                var newVertices = result.Points.Select(x => x.ToVec()).ToArray();
                float[] points = new float[newVertices.Length * 3];
                for (int i = 0; i < newVertices.Length; i++)
                {
                    int idx = i * 3;
                    points[idx] = newVertices[i].x;
                    points[idx + 1] = newVertices[i].z;
                    points[idx + 2] = newVertices[i].y;
                }
                ConvexHullShape cs = new ConvexHullShape(points);
                cs.LocalScaling = m_localScaling.ToBullet();
                return cs;
            }
            */
            return null;
        }

        public override CollisionShape CopyCollisionShape()
        {
            return _CreateConvexHullShape();
        }

        public override CollisionShape GetCollisionShape() {
            if (collisionShapePtr == null) {
                collisionShapePtr = _CreateConvexHullShape();
            }
            return collisionShapePtr;
        }
    }
}
