using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;

public class LayoutPath : MonoBehaviour
{
    public List<Vector3> points = new List<Vector3>();
    private List<float> segments = new List<float>();

    [ShowOnly, Tooltip("Length in meters")]
    public float Length;

    [ShowOnly, Tooltip("Track Percentage")]
    public float Perc;

    [ShowOnly, Tooltip("Position on Path")]
    public Vector3 PosOnPath;

    [ShowOnly, Tooltip("Distance from beginning")]
    public float Distance;

    private Vector3 pointPrec;
    private Vector3 pointNext;

    [SerializeField] bool pointsPrerotated = false;

    [Header("Editing Path")] public bool EditLine;

    public Vector3 GetPointPrec()
    {
        return pointPrec;
    }

    public Vector3 GetPointNext()
    {
        return pointNext;
    }

    public Vector3 GetPoint(int index)
    {
        if (index < points.Count)
        {
            return points[index];
        }
        else
        {
            return new Vector3();
        }
    }

    public void PreRotatePoints()
    {
        if (!pointsPrerotated)
        {
            for (int i = 0; i < points.Count; i++)
            {
                points[i] = transform.TransformPoint(points[i]);
            }
        }

        pointsPrerotated = true;
    }

    public int GetPointsCount()
    {
        return points.Count;
    }

    public void Invert()
    {
        points.Reverse();
        calcLength();
    }

    public void AddPoint(Vector3 point)
    {
        points.Add(point);
        calcLength();
    }

    public void Clear()
    {
        points.Clear();
        calcLength();
    }

    public void RemoveAt(int index)
    {
        points.RemoveAt(index);
        calcLength();
    }

    public void UpdatePoint(int index, Vector3 point)
    {
        points[index] = point;
        calcLength();
    }

    public void SaveCameras()
    {
    }

    public void BuildObject(List<Vector3> pointsToUse)
    {
        points.Clear();
        foreach (var item in pointsToUse)
        {
            points.Add(item);
        }

        calcLength();
    }

    public void ExportXml(string pathXml)
    {
        gUtility.CXml xSpline = new gUtility.CXml(pathXml, true);
        for (int i = 0; i < points.Count; i++)
        {
            string POINT = string.Format("Points/P#{0}", i + 1);
            gUtility.Vector3 pos = new gUtility.Vector3(-points[i].x, points[i].z, -points[i].y);
            xSpline.Settings[POINT].WriteVector3("value", pos);
        }

        xSpline.Commit();
    }

    public void BuildObject(string pathXml, bool useUnityVector = false)
    {
        gUtility.CXml xSpline = new gUtility.CXml(pathXml, false);
        if (useUnityVector)
        {
            for (int i = 1; i <= xSpline.Settings["Points"].GetNamedChildrenCount("P"); ++i)
            {
                string POINT = string.Format("Points/P#{0}", i);
                gUtility.Vector3 pos = xSpline.Settings[POINT].ReadVector3("value", gUtility.Vector3.ZERO);
                Vector3 posU = new Vector3(pos.x, pos.y + 0.05f, pos.z);
                points.Add(posU);
            }
        }
        else
        {
            for (int i = 1; i <= xSpline.Settings.GetNamedChildrenCount("P"); ++i)
            {
                string POINT = string.Format("P#{0}", i);
                gUtility.Vector3 pos = xSpline.Settings[POINT].ReadVector3("pos", gUtility.Vector3.ZERO);
                Vector3 posU = new Vector3(-pos.x, pos.z, -pos.y);
                points.Add(posU);
                /*
                GameObject point = GameObject.CreatePrimitive(PrimitiveType.Capsule); //new GameObject(string.Format("point{0}", i - 1));
                point.name = string.Format("point{0}", i - 1);
                point.transform.localScale = new UnityEngine.Vector3(0.5f, 2.0f, 0.5f);
                point.transform.SetParent(pointsObj.transform);
                point.transform.position = posU;
                */
            }
        }
    }

    public void calcLength()
    {
        Length = 0;
        segments.Clear();
        for (int i = 0; i < points.Count - 1; i++)
        {
            float len = (points[i + 1] - points[i]).magnitude;
            segments.Add(len);
            Length += len;
        }
    }

    int segMin = -1;
    Vector3 AP = Vector3.zero;
    Vector3 AB = Vector3.zero;
    float magnitudeAB = 0.0f;
    float ABAPproduct = 0.0f;

    float distRel = 0.0f;

    //float distSegment = 0.0f;
    float fMin = 999999.0f;

    /// <summary>
    /// Gets the position on path.
    /// </summary>
    /// <param name="posInWorld">Position in world.</param>
    public void GetPositionOnPath(Vector3 posInWorld)
    {
        if (!pointsPrerotated)
        {
            PreRotatePoints();
        }

        //posInWorld = transform.TransformPoint (posInWorld);
        if (segments.Count == 0)
        {
            calcLength();
        }

        fMin = float.MaxValue;
        for (int i = 0; i < points.Count - 1; ++i)
        {
            var distTmp = (posInWorld - points[i]).sqrMagnitude;
            if (distTmp < fMin)
            {
                fMin = distTmp;
                segMin = i;
            }
        }

        int nPrec = 1;
        int nNext = -1;

        if (segMin > 0)
        {
            nPrec = getClosestPoint(posInWorld, points[segMin - 1], points[segMin]);
        }

        if (segMin < points.Count - 1)
        {
            nNext = getClosestPoint(posInWorld, points[segMin], points[segMin + 1]);
        }

        if (nPrec == 0)
        {
            segMin--;
        }
        else if (nNext == 0)
        {
            //segMin = segMin;
        }
        else
        {
            Distance = 0;
            for (int i = 0; i <= segMin; ++i)
            {
                Distance += segments[i];
            }

            Perc = 100.0f / Length * Distance;
            return;
        }

        pointPrec = points[segMin];
        pointNext = points[segMin + 1];
        getClosestPoint(posInWorld, pointPrec, pointNext);
        //dist è la distanza dal punto, quindi devo calcolare le distanze precedenti

        // son dentro, calcolo la distanza totale e la percentuale giusta
        for (int i = 0; i < segMin; ++i)
        {
            Distance += segments[i];
        }

        Perc = 100.0f / Length * Distance;
    }

    /// <summary>
    /// Gets the position on path.
    /// </summary>
    /// <param name="distanceFromBeginning">Distance from beginning.</param>
    public void GetPositionOnPath(float distanceFromBeginning)
    {
        float tmpDist = 0.0f;
        int iSeg = 0;

        if (segments.Count == 0)
        {
            calcLength();
        }

        if (segments.Count == 0)
        {
            return;
        }

        // cerco il segmento interessato...
        for (int i = 0; i < segments.Count; ++i)
        {
            tmpDist += segments[i];
            if (distanceFromBeginning < tmpDist)
            {
                iSeg = i;
                tmpDist -= segments[i];
                break;
            }
        }

        // distanza da A:
        tmpDist = distanceFromBeginning - tmpDist;

        // proporzione tra la lunghezza e la rimanente
        float fProp = tmpDist / segments[iSeg];

        pointPrec = points[iSeg];
        pointNext = points[iSeg + 1];
        Vector3 seg = pointNext - pointPrec;

        //seg.Normalise();
        seg = seg * fProp;

        PosOnPath = pointPrec + seg;
    }

    private int getClosestPoint(Vector3 P, Vector3 A, Vector3 B)
    {
        AP = P - A;
        AB = B - A;
        magnitudeAB = AB.sqrMagnitude;
        ABAPproduct = Vector3.Dot(AP, AB);
        distRel = ABAPproduct / magnitudeAB;

        if (distRel < 0.0f)
        {
            // segmento precedente	
            return -1;
        }
        else if (distRel > 1.0f)
        {
            // segmento successivo
            return 1;
        }
        else
        {
            // son dentro!
            PosOnPath = A + AB * distRel;
            Distance = (PosOnPath - A).magnitude;
            //distSegment = (P - PosOnPath).magnitude;
            return 0;
        }
    }

    [Header("Sentieri link")]
    public GameObject SentieriWaypoint;

    public void GenerateFromWaypoints()
    {
        if (SentieriWaypoint == null)
        {
            Debug.LogWarning("No Sentiery gameobject");
        }
        else
        {
            for (int i = 0; i < SentieriWaypoint.transform.childCount; i++)
            {
                points.Add(SentieriWaypoint.transform.GetChild(i).position);
            }
        }
    }

    public void ExportFromWaypoints()
    {

        float tollerance = 1.7f;
        var root = new GameObject("Root Export");
        int i = 0;

        // Simplify.
        var simplifiedPoints = new List<Vector3>();
        LineUtility.Simplify(points.ToList(), tollerance, simplifiedPoints);

        foreach (var point in simplifiedPoints)
        {
            var w = new GameObject("Point " + i);
            w.transform.position = point;
            w.transform.parent = root.transform;

            i++;
        }
    }

    public bool ImportMooseBin(string fileName)
    {
        points.Clear();
        var b = new BinaryReader(File.Open(fileName, FileMode.Open));
        var numPoints = b.ReadUInt32();
        for (var i = 0; i < numPoints; i++)
        {
            var x = b.ReadSingle();
            var y = b.ReadSingle();
            var z = b.ReadSingle();

            points.Add(new Vector3(-x, y, z));
        }

        return points.Count > 0;
    }

}