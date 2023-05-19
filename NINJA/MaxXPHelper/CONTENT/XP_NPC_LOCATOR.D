const int Ninja_MaxXPHelper_XPNPCLocatorOn = 0;
const int Ninja_MaxXPHelper_XPNPCLocatorHT = 0;
const int Ninja_MaxXPHelper_XPNPCLocator_NearbyNPCArray = 0;
const int Ninja_MaxXPHelper_XPNPCLocator_MaxNPCToProcessEachFrameBeforeYield = 5;

class _Ninja_MaxXPHelper_TrackedSphere {
    var int sphereHandle;
    var int cycle;
};
instance _Ninja_MaxXPHelper_TrackedSphere_Proto(_Ninja_MaxXPHelper_TrackedSphere) {
    sphereHandle = -1;
    cycle = 0;
};

func int _Ninja_MaxXPHelper_XPNPCLocator_ProcessNPC(var oCNPC npc, var int processingNearby, var int cycle) {
    var c_npc cnpc; cnpc = _^(_@(npc));
    if Npc_IsPlayer(cnpc) {
        return FALSE;
    };
    var int waypointPointer; waypointPointer = Ninja_MaxXPHelper_GetWaypointByName(npc.wpname);
    var int waypointTrackedSphereHndl; waypointTrackedSphereHndl = HT_Get(Ninja_MaxXPHelper_XPNPCLocatorHT, waypointPointer);
    var _Ninja_MaxXPHelper_TrackedSphere trackedSphere;

    if processingNearby && HLP_IsValidHandle(waypointTrackedSphereHndl) && Npc_GetDistToWP(npc, npc.wpname) < 1000 {
        Ninja_MaxXPHelper_LogInfo(ConcatStrings("Remove WP ", npc.wpname));
        trackedSphere = get(waypointTrackedSphereHndl);
        EraseSphere(trackedSphere.sphereHandle);
        delete(waypointTrackedSphereHndl);
        HT_Remove(Ninja_MaxXPHelper_XPNPCLocatorHT, waypointPointer);
    };
    var int trackedSphereKey; trackedSphereKey = _@(npc);
    var int trackedSphereNpcHndl; trackedSphereNpcHndl = HT_Get(Ninja_MaxXPHelper_XPNPCLocatorHT, trackedSphereKey);
    if HLP_IsValidHandle(trackedSphereNpcHndl) {
        trackedSphere = get(trackedSphereNpcHndl);
        if !processingNearby && trackedSphere.cycle >= cycle {
            //Ninja_MaxXPHelper_LogInfo(ConcatStrings("Skip nearby NPC, already processed ", npc.name));
            return FALSE;
        };
        if Npc_IsDead(cnpc) {
            Ninja_MaxXPHelper_LogInfo(ConcatStrings(
                "Remove expired dead npc sphere ", npc.name)
            );
            EraseSphere(trackedSphere.sphereHandle);
            delete(trackedSphereNpcHndl);
            HT_Remove(Ninja_MaxXPHelper_XPNPCLocatorHT, trackedSphereKey);
            return TRUE;
        };
    };
    var int x; x = npc._zCVob_trafoObjToWorld[3];
    var int y; y = npc._zCVob_trafoObjToWorld[7];
    var int z; z = npc._zCVob_trafoObjToWorld[11];
    var int renderHandle; renderHandle = trackedSphereNpcHndl;
    var int color; color = Ninja_MaxXPHelper_SphereColorNotBeaten;
    if Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch && Ninja_MaxXPHelper_VictoryXPReceived(cnpc) {
        color = Ninja_MaxXPHelper_SphereColorConsiderG1DoubleXPGlitch;
    };
    var int visible; visible = processingNearby;
    var int canCreate; canCreate = FALSE;
    if !( 
        (cnpc.flags & NPC_FLAG_IMMORTAL) || 
        Npc_IsDead(cnpc) || 
        (!Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch && Ninja_MaxXPHelper_VictoryXPReceived(cnpc)) ||
        (!Ninja_MaxXPHelper_ConsiderLevelZeroNPC && cnpc.level <= 0)
    ) {
        if !Ninja_MaxXPHelper_IsNpcSpawned(npc) {
            if !processingNearby && waypointPointer {
                var zCWaypoint wp; wp = _^(waypointPointer);
                x = wp.pos[0];
                y = wp.pos[1];
                z = wp.pos[2];
                trackedSphereKey = waypointPointer;
                renderHandle = waypointTrackedSphereHndl;
                visible = TRUE;
                canCreate = TRUE;
            } else {
                canCreate = FALSE;
            };
        } else {
            canCreate = TRUE;
        };  
    };
    
    if !HLP_IsValidHandle(renderHandle) {
        if canCreate {
            renderHandle = new(_Ninja_MaxXPHelper_TrackedSphere_Proto);
            HT_Insert(Ninja_MaxXPHelper_XPNPCLocatorHT, renderHandle, trackedSphereKey);
        } else {
            return FALSE;
        };

    };
    trackedSphere = get(renderHandle);
    trackedSphere.cycle = cycle;
    if !visible {
        var zCVob vob; vob = _^(_@(npc));
        if trackedSphereKey == waypointPointer {
            var zCWaypoint wp; wp = _^(waypointPointer);
            var zCVob vob; vob = _^(wp.wpvob);
            visible = Ninja_MaxXPHelper_IsVobAheadOfCamera(vob);
        } else {
            visible = Ninja_MaxXPHelper_IsVobAheadOfCamera(vob);
        };
    };
    if visible {
        if !HLP_IsValidHandle(trackedSphere.sphereHandle) {
            trackedSphere.sphereHandle = DrawSphere3(0, 0, 0, 0, 0);
        };
        ShowSphere(trackedSphere.sphereHandle);
        UpdateSphere3(trackedSphere.sphereHandle, x, y, z, mkf(Ninja_MaxXPHelper_SphereRadius));
        SetSphereColor(trackedSphere.sphereHandle, color);
    } else {
        HideSphere(trackedSphere.sphereHandle);
    };
    return TRUE;
};

func void _Ninja_MaxXPHelper_XPNPCLocator_ProcessNearby(var int cycle) 
{
    MEM_ArrayClear(Ninja_MaxXPHelper_XPNPCLocator_NearbyNPCArray);
    Ninja_MaxXPHelper_oCNPCSearchVobList(Ninja_MaxXPHelper_XPNPCLocator_NearbyNPCArray);
    const int newCycleLog = 0;
    if newCycleLog < cycle {
        newCycleLog = cycle;
        Ninja_MaxXPHelper_LogInfo(ConcatStrings("Nearby there're ", IntToString(MEM_ArraySize(Ninja_MaxXPHelper_XPNPCLocator_NearbyNPCArray))));
    };
	repeat(i, MEM_ArraySize(Ninja_MaxXPHelper_XPNPCLocator_NearbyNPCArray)); var int i;
        var oCNPC npc; npc = _^(MEM_ArrayRead(Ninja_MaxXPHelper_XPNPCLocator_NearbyNPCArray, i));
        _Ninja_MaxXPHelper_XPNPCLocator_ProcessNPC(npc, TRUE, cycle);
	end;
};

const int _Ninja_MaxXPHelper_XPNPCLocator_NextGlobalNpcPtr = 0;
func int _Ninja_MaxXPHelper_XPNPCLocator_NextGlobalNpc(var int cyclePtr) {
    var int listPtr; listPtr = _Ninja_MaxXPHelper_XPNPCLocator_NextGlobalNpcPtr;
    var zCListSort list;
    if !listPtr {
        if cyclePtr {
            MEM_WriteInt(cyclePtr, MEM_ReadInt(cyclePtr) + 1);
        };
        listPtr = MEM_World.voblist_npcs;  
    };
    list = _^ (listPtr);
    listPtr = list.next;
    _Ninja_MaxXPHelper_XPNPCLocator_NextGlobalNpcPtr = listPtr;
    return list.data;
};

func void _Ninja_MaxXPHelper_XPNPCLocator_Hide(var int _, var int trackedSphereHndl) {
    var _Ninja_MaxXPHelper_TrackedSphere ts; ts = get(trackedSphereHndl);
    if HLP_IsValidHandle(ts.sphereHandle) {
        HideSphere(ts.sphereHandle);
    };
};

func void Ninja_MaxXPHelper_ReadInputLoop() 
{
    if MEM_KeyState(Ninja_MaxXPHelper_ToggleXPNPCLocatorKeyCode) == KEY_PRESSED {
        Ninja_MaxXPHelper_XPNPCLocatorOn = !Ninja_MaxXPHelper_XPNPCLocatorOn;
        var string msg; msg = Ninja_MaxXPHelper_LOC_LocatorOn;
        if !Ninja_MaxXPHelper_XPNPCLocatorOn {
            msg = Ninja_MaxXPHelper_LOC_LocatorOff;
            HT_ForEach(Ninja_MaxXPHelper_XPNPCLocatorHT, _Ninja_MaxXPHelper_XPNPCLocator_Hide);  
        } else {
            
        };
        Ninja_MaxXPHelper_AddTextAlert(
            msg, Ninja_MaxXPHelper_SystemAlertDuration, 
            RGBA(50, 255, 50, 0),
            TRUE
        );
    };    
};

func void Ninja_MaxXPHelper_RefreshLoop() {
    const int fullCycles = 0;
    if Ninja_MaxXPHelper_XPNPCLocatorOn {
        var int processed; processed = 0;
        _Ninja_MaxXPHelper_XPNPCLocator_ProcessNearby(fullCycles);
        while (Ninja_MaxXPHelper_XPNPCLocatorOn && !Timer_IsPaused());
            var int npcPtr; npcPtr = _Ninja_MaxXPHelper_XPNPCLocator_NextGlobalNpc(_@(fullCycles));
            if !npcPtr {
                continue;
            };
            var oCNPC npc; npc = _^(npcPtr);
            _Ninja_MaxXPHelper_XPNPCLocator_ProcessNPC(npc, FALSE, fullCycles);
            processed = processed + 1;
            if processed > Ninja_MaxXPHelper_XPNPCLocator_MaxNPCToProcessEachFrameBeforeYield {
                // yield so the main thread isn't blocked for too long
                return;
            };
        end;
    };
};

func void Ninja_MaxXPHelper_XPNPCLocator_Init() {
    _Ninja_MaxXPHelper_XPNPCLocator_NextGlobalNpcPtr = 0;
    Ninja_MaxXPHelper_XPNPCLocator_NearbyNPCArray = MEM_ArrayCreate();
    if HLP_IsValidHandle(Ninja_MaxXPHelper_XPNPCLocatorHT) {
        Ninja_MaxXPHelper_LogInfo(
            ConcatStrings(
                "Unreleased resources! ", 
                IntToString(HT_GetNumber(Ninja_MaxXPHelper_XPNPCLocatorHT))
            )
        );
    };
    Ninja_MaxXPHelper_XPNPCLocatorHT = HT_Create();
    FF_ApplyExtGT(Ninja_MaxXPHelper_ReadInputLoop, 0, -1);
    FF_ApplyExtGT(Ninja_MaxXPHelper_RefreshLoop, 0, -1);
};
