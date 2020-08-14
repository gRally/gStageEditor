using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class StartFinish : StageResources
{
    [Header("Start")]
    public float StartDistance = 100.0f;
    public float StartCarRelative = -100.0f;
    public float StartCo0Relative = -25.0f;
    public float StartCo1Relative = -50.0f;
    public float StartEndRelative = 25.0f;

    [Header("Splits")]
    public float Split1Distance = 200.0f;
    public float Split2Distance = 500.0f;
    public float Split3Distance = 800.0f;

    [Header("Finish")]
    public float FinishDistance = 1000.0f;
    public float FinishCo0Relative = -100.0f;
    public float FinishStopRelative = 200.0f;
    public float FinishEndRelative = 25.0f;

    float oldStartCarRelative = 0.0f;
    float oldStartDistance = 0.0f;
    float oldStartCo0Relative = 0.0f;
    float oldStartCo1Relative = 0.0f;
    float oldStartEndRelative = 0.0f;

    float oldSplit1Distance = 0.0f;
    float oldSplit2Distance = 0.0f;
    float oldSplit3Distance = 0.0f;

    float oldFinishDistance = 0.0f;
    float oldFinishCo0Relative = 0.0f;
    float oldFinishStopRelative = 0.0f;
    float oldFinishEndRelative = 0.0f;

    [ShowOnly, Header("Data Calculated")]
    public float RealLength;

    public LayoutPath layout = null;
    [Header("Signals")]
    public bool useCustomSigns;
    public string resourceName = "Default";
    public float SignalDistanceFromCenter = 2.5f;
    public float SignalDistanceFromBanner = 0.8f;

    //[ShowOnly, Tooltip("Points 3d"), Header("Spline Points")]
    [HideInInspector]
    public List<Vector3> Points = new List<Vector3>();

    public bool UpdatePoints()
    {
        if (SomethingIsChanged())
        {
            try
            {
                if (layout == null)
                {
                    layout = transform.GetComponent<LayoutPath>();
                }

                Points.Clear();
                layout.GetPositionOnPath(StartDistance + StartCarRelative);
                Points.Add(layout.PosOnPath);

                layout.GetPositionOnPath(StartDistance + StartCo1Relative + StartCo0Relative);
                Points.Add(layout.PosOnPath);
                layout.GetPositionOnPath(StartDistance + StartCo1Relative);
                Points.Add(layout.PosOnPath);
                layout.GetPositionOnPath(StartDistance);
                Points.Add(layout.PosOnPath);
                layout.GetPositionOnPath(StartDistance + StartEndRelative);
                Points.Add(layout.PosOnPath);

                layout.GetPositionOnPath(Split1Distance);
                Points.Add(layout.PosOnPath);
                layout.GetPositionOnPath(Split2Distance);
                Points.Add(layout.PosOnPath);
                layout.GetPositionOnPath(Split3Distance);
                Points.Add(layout.PosOnPath);

                layout.GetPositionOnPath(FinishDistance + FinishCo0Relative);
                Points.Add(layout.PosOnPath);
                layout.GetPositionOnPath(FinishDistance);
                Points.Add(layout.PosOnPath);
                layout.GetPositionOnPath(FinishDistance + FinishStopRelative);
                Points.Add(layout.PosOnPath);
                layout.GetPositionOnPath(FinishDistance + FinishStopRelative + FinishEndRelative);
                Points.Add(layout.PosOnPath);
            }
            catch (System.Exception ex)
            {
                Debug.LogError(ex.ToString());
                return false;
            }
        }
        return true;
    }

    public void CalculateSplits()
    {
        var realDist = FinishDistance - StartDistance;
        var distSplits = realDist / 4.0f;
        Split1Distance = StartDistance + (distSplits * 1.0f);
        Split2Distance = StartDistance + (distSplits * 2.0f);
        Split3Distance = StartDistance + (distSplits * 3.0f);
    }

    public void PlaceSignals(bool addCollider = true)
    {
        float farCrossRoad = -10f;
        if (layout == null)
        {
            return;
        }

        if (addCollider)
        {
            AddCollider();
        }

        /*
        // Co0
        layout.GetPositionOnPath(StartDistance + StartCo1Relative + StartCo0Relative);
        var pos = layout.PosOnPath;
        var p0 = layout.GetPointPrec();
        var p1 = layout.GetPointNext();

        var dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
        if (settings.useCustomSigns)
        {
            CreateMeshFromPrefab(transform, resourceName, "StageSigns/SignStart0_00", pos + (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND);
            CreateMeshFromPrefab(transform, resourceName, "StageSigns/SignStart0_00", pos - (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND);
        }
        else
        {
            // helper
            CreateFakeMesh(transform, "SignStart0_00", pos + (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), new Vector3(0.3f, 0.6f, 0.3f), Vector3.zero, HEIGHT_DETECTION.LOWER_POINT_AT_GROUND);
            CreateFakeMesh(transform, "SignStart0_00", pos - (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), new Vector3(0.3f, 0.6f, 0.3f), Vector3.zero, HEIGHT_DETECTION.LOWER_POINT_AT_GROUND);
        }
        */

        // Start -----------------------------------------------------------------------------------
        // gazebo
        layout.GetPositionOnPath(StartDistance + StartCarRelative);
        Vector3 pos = layout.PosOnPath;
        Vector3 p0 = layout.GetPointPrec();
        Vector3 p1 = layout.GetPointNext();
        Vector3 dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
        CreateMeshFromPrefab(true, transform, resourceName, "StartStop_Area/Gazebo_00", pos, Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.PIVOT_AT_GROUND, "Gazebo_00");

        // Marshall table
        CreateMeshFromPrefab(false, transform, resourceName, "StartStop_Area/Group_Marshal_Table_00", pos - (dot * 4f), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(0, 180, 0), HEIGHT_DETECTION.PIVOT_AT_GROUND, "Marshall_Table_00");

        // Co0
        layout.GetPositionOnPath(StartDistance + StartCo1Relative + StartCo0Relative);
        pos = layout.PosOnPath;
        if (!MeshIsPlaceable(pos, "Crossroad"))
        {
            StartCo0Relative += farCrossRoad;
            layout.GetPositionOnPath(StartDistance + StartCo1Relative + StartCo0Relative);
            pos = layout.PosOnPath;
        }
        p0 = layout.GetPointPrec();
        p1 = layout.GetPointNext();
        dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/SignStart0_00", pos + (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND, "SignStart0_00", "Crossroad");
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/SignStart0_00", pos - (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND, "SignStart0_00", "Crossroad");

        // Co1
        layout.GetPositionOnPath(StartDistance + StartCo1Relative);
        if (!MeshIsPlaceable(pos, "Crossroad"))
        {
            StartCo1Relative += farCrossRoad;
            layout.GetPositionOnPath(StartDistance + StartCo1Relative);
            pos = layout.PosOnPath;
        }
        pos = layout.PosOnPath;
        p0 = layout.GetPointPrec();
        p1 = layout.GetPointNext();
        dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/SignStart1_00", pos + (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND, "SignStart1_00", "Crossroad");
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/SignStart1_00", pos - (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND, "SignStart1_00", "Crossroad");

        // start
        layout.GetPositionOnPath(StartDistance - SignalDistanceFromBanner);
        pos = layout.PosOnPath;
        if (!MeshIsPlaceable(pos, "Crossroad"))
        {
            SignalDistanceFromBanner += farCrossRoad;
            layout.GetPositionOnPath(StartDistance - SignalDistanceFromBanner);
            pos = layout.PosOnPath;
        }
        p0 = layout.GetPointPrec();
        p1 = layout.GetPointNext();
        dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/SignStart2_00", pos + (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND, "SignStart2_00");
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/SignStart2_00", pos - (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND, "SignStart2_00");

        // banner start
        layout.GetPositionOnPath(StartDistance);
        pos = layout.PosOnPath;
        p0 = layout.GetPointPrec();
        p1 = layout.GetPointNext();
        CreateMeshFromPrefab(true, transform, resourceName, "StageSigns/BannerStart_00", pos, Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.PLACE_AS_IS, "BannerStart_00");

        // photocells
        layout.GetPositionOnPath(StartDistance + 0.5f);
        pos = layout.PosOnPath;
        p0 = layout.GetPointPrec();
        p1 = layout.GetPointNext();
        dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
        CreateMeshFromPrefab(false, transform, resourceName, "StartStop_Area/PhotoCell_Left_00", pos + (dot * (SignalDistanceFromCenter - 0.1f)), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND, "PhotoCell_Left_00");
        CreateMeshFromPrefab(false, transform, resourceName, "StartStop_Area/PhotoCell_Right_00", pos - (dot * (SignalDistanceFromCenter - 0.1f)), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND, "PhotoCell_Right_00");

        // end
        layout.GetPositionOnPath(StartDistance + StartEndRelative);
        pos = layout.PosOnPath;
        if (!MeshIsPlaceable(pos, "Crossroad"))
        {
            StartEndRelative += farCrossRoad;
            layout.GetPositionOnPath(StartDistance + StartEndRelative);
            pos = layout.PosOnPath;
        }
        p0 = layout.GetPointPrec();
        p1 = layout.GetPointNext();
        dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/SignFree_00", pos + (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND, "SignFree_00");
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/SignFree_00", pos - (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND, "SignFree_00");


        // split 1
        layout.GetPositionOnPath(Split1Distance);
        pos = layout.PosOnPath;
        if (!MeshIsPlaceable(pos, "Crossroad"))
        {
            Split1Distance += farCrossRoad;
            layout.GetPositionOnPath(Split1Distance);
            pos = layout.PosOnPath;
        }
        p0 = layout.GetPointPrec();
        p1 = layout.GetPointNext();
        dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/SignSplit1_00", pos + (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND, "SignSplit1_00");
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/SignSplit1_00", pos - (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND, "SignSplit1_00");

        // split 2
        layout.GetPositionOnPath(Split2Distance);
        pos = layout.PosOnPath;
        if (!MeshIsPlaceable(pos, "Crossroad"))
        {
            Split2Distance += farCrossRoad;
            layout.GetPositionOnPath(Split2Distance);
            pos = layout.PosOnPath;
        }
        p0 = layout.GetPointPrec();
        p1 = layout.GetPointNext();
        dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/SignSplit2_00", pos + (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND, "SignSplit2_00");
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/SignSplit2_00", pos - (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND, "SignSplit2_00");

        // split 3
        layout.GetPositionOnPath(Split3Distance);
        pos = layout.PosOnPath;
        if (!MeshIsPlaceable(pos, "Crossroad"))
        {
            Split3Distance += farCrossRoad;
            layout.GetPositionOnPath(Split3Distance);
            pos = layout.PosOnPath;
        }
        p0 = layout.GetPointPrec();
        p1 = layout.GetPointNext();
        dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/SignSplit3_00", pos + (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND, "SignSplit3_00");
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/SignSplit3_00", pos - (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND, "SignSplit3_00");


        // finish ----------------------------------------------------------------------------------
        // Co0
        layout.GetPositionOnPath(FinishDistance + FinishCo0Relative);
        pos = layout.PosOnPath;
        if (!MeshIsPlaceable(pos, "Crossroad"))
        {
            FinishCo0Relative += farCrossRoad;
            layout.GetPositionOnPath(FinishDistance + FinishCo0Relative);
            pos = layout.PosOnPath;
        }
        p0 = layout.GetPointPrec();
        p1 = layout.GetPointNext();
        dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/SignEnd0_00", pos + (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND, "SignEnd0_00");
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/SignEnd0_00", pos - (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND, "SignEnd0_00");

        // finish
        layout.GetPositionOnPath(FinishDistance - SignalDistanceFromBanner);
        pos = layout.PosOnPath;
        if (!MeshIsPlaceable(pos, "Crossroad"))
        {
            SignalDistanceFromBanner += farCrossRoad;
            layout.GetPositionOnPath(FinishDistance - SignalDistanceFromBanner);
            pos = layout.PosOnPath;
        }
        p0 = layout.GetPointPrec();
        p1 = layout.GetPointNext();
        dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/SignEnd1_00", pos + (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND, "SignEnd1_00");
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/SignEnd1_00", pos - (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND, "SignEnd1_00");

        // banner finish
        layout.GetPositionOnPath(FinishDistance);
        pos = layout.PosOnPath;
        p0 = layout.GetPointPrec();
        p1 = layout.GetPointNext();
        CreateMeshFromPrefab(true, transform, resourceName, "StageSigns/BannerFinish_00", pos, Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.PLACE_AS_IS, "BannerFinish_00");

        // photocells
        layout.GetPositionOnPath(FinishDistance + 0.5f);
        pos = layout.PosOnPath;
        p0 = layout.GetPointPrec();
        p1 = layout.GetPointNext();
        dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
        CreateMeshFromPrefab(false, transform, resourceName, "StartStop_Area/PhotoCell_Left_00", pos + (dot * (SignalDistanceFromCenter - 0.1f)), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND, "PhotoCell_Left_00");
        CreateMeshFromPrefab(false, transform, resourceName, "StartStop_Area/PhotoCell_Right_00", pos - (dot * (SignalDistanceFromCenter - 0.1f)), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND, "PhotoCell_Right_00");

        // -3
        layout.GetPositionOnPath(FinishDistance + FinishStopRelative - 150f);
        pos = layout.PosOnPath;
        if (!MeshIsPlaceable(pos, "Crossroad"))
        {
            layout.GetPositionOnPath(FinishDistance + FinishStopRelative - 150f + farCrossRoad);
            pos = layout.PosOnPath;
        }
        p0 = layout.GetPointPrec();
        p1 = layout.GetPointNext();
        dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/EndStageSign3_00", pos + (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.PIVOT_AT_GROUND, "EndStageSign3_00");
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/EndStageSign3_00", pos - (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.PIVOT_AT_GROUND, "EndStageSign3_00");

        // -2
        layout.GetPositionOnPath(FinishDistance + FinishStopRelative - 100f);
        pos = layout.PosOnPath;
        if (!MeshIsPlaceable(pos, "Crossroad"))
        {
            layout.GetPositionOnPath(FinishDistance + FinishStopRelative - 100f + farCrossRoad);
            pos = layout.PosOnPath;
        }
        p0 = layout.GetPointPrec();
        p1 = layout.GetPointNext();
        dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/EndStageSign2_00", pos + (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.PIVOT_AT_GROUND, "EndStageSign2_00");
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/EndStageSign2_00", pos - (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.PIVOT_AT_GROUND, "EndStageSign2_00");

        // -1
        layout.GetPositionOnPath(FinishDistance + FinishStopRelative - 50f);
        pos = layout.PosOnPath;
        if (!MeshIsPlaceable(pos, "Crossroad"))
        {
            layout.GetPositionOnPath(FinishDistance + FinishStopRelative - 50f + farCrossRoad);
            pos = layout.PosOnPath;
        }
        p0 = layout.GetPointPrec();
        p1 = layout.GetPointNext();
        dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/EndStageSign1_00", pos + (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.PIVOT_AT_GROUND, "EndStageSign1_00");
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/EndStageSign1_00", pos - (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.PIVOT_AT_GROUND, "EndStageSign1_00");
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/StopRoadCone_00", pos + (dot * (SignalDistanceFromCenter - 0.3f)), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND, "StopRoadCone_00");
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/StopRoadCone_00", pos - (dot * (SignalDistanceFromCenter - 0.3f)), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND, "StopRoadCone_00");

        // stop
        layout.GetPositionOnPath(FinishDistance + FinishStopRelative);
        pos = layout.PosOnPath;
        if (!MeshIsPlaceable(pos, "Crossroad"))
        {
            FinishStopRelative += farCrossRoad;
            layout.GetPositionOnPath(FinishDistance + FinishStopRelative);
            pos = layout.PosOnPath;
        }
        p0 = layout.GetPointPrec();
        p1 = layout.GetPointNext();
        dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/SignEnd2_00", pos + (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND, "SignEnd2_00");
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/SignEnd2_00", pos - (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND, "SignEnd2_00");

        // gazebo
        layout.GetPositionOnPath(FinishDistance + FinishStopRelative - 2f);
        pos = layout.PosOnPath;
        p0 = layout.GetPointPrec();
        p1 = layout.GetPointNext();

        dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
        CreateMeshFromPrefab(true, transform, resourceName, "StartStop_Area/Gazebo_00", pos, Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.PIVOT_AT_GROUND, "Gazebo_00");

        // Marshall table
        CreateMeshFromPrefab(false, transform, resourceName, "StartStop_Area/Group_Marshal_Table_00", pos - (dot * 4f), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(0, 180, 0), HEIGHT_DETECTION.PIVOT_AT_GROUND, "Marshall_Table_00");

        // end
        layout.GetPositionOnPath(FinishDistance + FinishStopRelative + FinishEndRelative);
        pos = layout.PosOnPath;
        if (!MeshIsPlaceable(pos, "Crossroad"))
        {
            FinishEndRelative += farCrossRoad;
            layout.GetPositionOnPath(FinishDistance + FinishStopRelative + FinishEndRelative);
            pos = layout.PosOnPath;
        }
        p0 = layout.GetPointPrec();
        p1 = layout.GetPointNext();
        dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/SignFree_00", pos + (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND, "SignFree_00");
        CreateMeshFromPrefab(false, transform, resourceName, "StageSigns/SignFree_00", pos - (dot * SignalDistanceFromCenter), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0), HEIGHT_DETECTION.LOWER_POINT_AT_GROUND, "SignFree_00");

        // far far end
        layout.GetPositionOnPath(FinishDistance + FinishStopRelative + FinishEndRelative + 6f);
        pos = layout.PosOnPath;

        p0 = layout.GetPointPrec();
        p1 = layout.GetPointNext();

        dot = Vector3.Cross(p1 - p0, Vector3.up).normalized;
        CreateMeshFromPrefab(true, transform, resourceName, "Barriers/JerseyEnd_00", pos + (dot * 2.2f), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 0, 0), HEIGHT_DETECTION.PIVOT_AT_GROUND, "JerseyEnd_00");
        CreateMeshFromPrefab(true, transform, resourceName, "Barriers/JerseyEnd_00", pos, Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 0, 0), HEIGHT_DETECTION.PIVOT_AT_GROUND, "JerseyEnd_00");
        CreateMeshFromPrefab(true, transform, resourceName, "Barriers/JerseyEnd_00", pos - (dot * 2.2f), Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 0, 0), HEIGHT_DETECTION.PIVOT_AT_GROUND, "JerseyEnd_00");
    }

    /// <summary>
    /// clean the signs
    /// </summary>
    public void CleanSigns()
    {
        int childs = transform.childCount;
        for (int i = childs - 1; i >= 0; i--)
        {
            var element = transform.GetChild(i);
            var name = element.name.ToLower();
            if (name.Contains("signstart") ||
                name.Contains("signsplit") ||
                name.Contains("signend") ||
                name.Contains("signfree") ||
                name.Contains("bannerstart") ||
                name.Contains("bannerfinish") ||
                name.Contains("marshall_table") ||
                name.Contains("photocell") ||
                name.Contains("gazebo") ||
                name.Contains("endstage") ||
                name.Contains("jerseyend") ||
                name.Contains("stoproadcone"))
            {
                DestroyImmediate(element.gameObject);
            }
        }
        for (int i = 0; i < transform.childCount; i++)
        {
            var element = transform.GetChild(i);
            if (element.name.ToLower().StartsWith("signstart") ||
                element.name.ToLower().StartsWith("signsplit") ||
                element.name.ToLower().StartsWith("signend") ||
                element.name.ToLower().StartsWith("signfree") ||
                element.name.ToLower().StartsWith("bannerstart") ||
                element.name.ToLower().StartsWith("bannerfinish"))
            {
                CleanSigns();
                break;
            }
        }
    }

    /*
    private void createSign(string signName, Vector3 pos, Vector3 p0, Vector3 p1, float raise = 5.00f)
	{
        pos.y = pos.y + raise;
        //string path = "Assets/gStageEditor/Resources/" + signName + ".prefab";
        //GameObject anchor_point = UnityEditor.AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;
        GameObject prefab_instance = Instantiate(Resources.Load<GameObject>(signName));
        prefab_instance.transform.position = pos;
        prefab_instance.transform.rotation = Quaternion.LookRotation(p1 - p0) * Quaternion.Euler(270, 90, 0);
        prefab_instance.transform.SetParent(transform);
        prefab_instance.name = signName;

        ApplyDistance(prefab_instance);
    }
    */

    bool SomethingIsChanged()
    {
        bool isChanged = StartCarRelative != oldStartCarRelative ||
                         StartDistance != oldStartDistance ||
                         StartCo0Relative != oldStartCo0Relative ||
                         StartCo1Relative != oldStartCo1Relative ||
                         StartEndRelative != oldStartEndRelative ||
                         Split1Distance != oldSplit1Distance ||
                         Split2Distance != oldSplit2Distance ||
                         Split3Distance != oldSplit3Distance ||
                         FinishDistance != oldFinishDistance ||
                         FinishCo0Relative != oldFinishCo0Relative ||
                         FinishStopRelative != oldFinishStopRelative ||
                         FinishEndRelative != oldFinishEndRelative;

        oldStartDistance = StartDistance;
        oldStartCo0Relative = StartCo0Relative;
        oldStartCo1Relative = StartCo1Relative;
        oldStartEndRelative = StartEndRelative;

        oldSplit1Distance = Split1Distance;
        oldSplit2Distance = Split2Distance;
        oldSplit3Distance = Split3Distance;

        oldFinishDistance = FinishDistance;
        oldFinishCo0Relative = FinishCo0Relative;
        oldFinishStopRelative = FinishStopRelative;
        oldFinishEndRelative = FinishEndRelative;

        return isChanged;
    }

    void ApplyDistance(GameObject obj, float offset = 0.08f) // 0.06 on plane is ok
    {
        var mesh = obj.GetComponent<MeshFilter>().sharedMesh;
        var matrix = obj.transform.localToWorldMatrix;

        RaycastHit hit;

        var point = matrix.MultiplyPoint(mesh.bounds.min);
        var raHit = Physics.Raycast(point, Vector3.down, out hit);
        if (raHit)
        {
            obj.transform.position = obj.transform.position - new Vector3(0.0f, hit.distance - offset, 0.0f);
        }
    }

    void AddCollider()
    {
        var layerIndex = LayerMask.NameToLayer("COLLISION");
        var collisions = Resources.FindObjectsOfTypeAll(typeof(GameObject));
        foreach (var o in collisions)
        {
            var col = (GameObject)o;
            if (col.layer == layerIndex && col.GetComponent<MeshCollider>() == null)
            {
                col.AddComponent<MeshCollider>();
            }
        }
    }

    void RemoveCollider()
    {
        var layerIndex = LayerMask.NameToLayer("COLLISION");
        var collisions = Resources.FindObjectsOfTypeAll(typeof(GameObject));
        foreach (var o in collisions)
        {
            var col = (GameObject)o;
            if (col.layer == layerIndex)
            {
                DestroyImmediate(col.GetComponent<MeshCollider>());
            }
        }
    }
}
