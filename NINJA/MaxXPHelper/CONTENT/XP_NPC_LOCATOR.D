const int _Ninja_MaxXPHelper_XPNPCLocator_Enabled = 0;
const int _Ninja_MaxXPHelper_XPNPCLocator_HandlesHT = 0;
const int _Ninja_MaxXPHelper_XPNPCLocator_NearbyNPCArray = 0;
const int Ninja_MaxXPHelper_XPNPCLocator_MaxNPCToProcessEachFrameBeforeYield = 5;
const int _Ninja_MaxXPHelper_XPNPCLocator_NextGlobalNpcPtr = 0;
const int _Ninja_MaxXPHelper_XPNPCLocator_NPCFullPassCycle = 0;

func string _Ninja_MaxXPHelper_XPNPCLocator_NpcToTexture(var c_npc npc) {
    if Ninja_MaxXPHelper_IsKnockable(hero, npc) {
        if Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch && Ninja_MaxXPHelper_VictoryXPReceived(npc) {
            return "MAXXPHELPER_DOUBLEXP_RANGED_KILL.tga";
        };
        return "MAXXPHELPER_KNOCKOUT.tga";
    };
    var int att; att = Npc_GetPermAttitude(hero, npc);
    return "MAXXPHELPER_KILL.tga";
}; 

func int _Ninja_MaxXPHelper_XPNPCLocator_NpcToColor(var c_npc npc) {
    var int att; att = Npc_GetPermAttitude(hero, npc);
    if att != ATT_HOSTILE { 
        return COL_WHITE; 
    } else { 
        return COL_RED; 
    };
};

func int _Ninja_MaxXPHelper_XPNPCLocator_ProcessNPC(var oCNPC npc, var int processingNearby) {
    var c_npc cnpc; cnpc = _^(_@(npc));
    if Npc_IsPlayer(cnpc) {
        return FALSE;
    };
    var int x; x = npc._zCVob_trafoObjToWorld[3];
    var int y; y = npc._zCVob_trafoObjToWorld[7];
    var int z; z = npc._zCVob_trafoObjToWorld[11];
    var int radiusZ; radiusZ = mulf(subf(npc._zCVob_bbox3D_maxs[2], npc._zCVob_bbox3D_mins[2]), FLOATHALF);
    
    var int trackerKey; trackerKey = _@(npc);
    var int trackerHandle; trackerHandle = Ninja_MaxXPHelper_HT_Get(_Ninja_MaxXPHelper_XPNPCLocator_HandlesHT, trackerKey);

    if Npc_IsDead(cnpc) {
        // Make sure we don't display dead.
        Ninja_MaxXPHelper_Trackers_Hide(trackerHandle, FALSE);
        return TRUE;
    };
    var int waypointPointer; waypointPointer = Ninja_MaxXPHelper_GetWaypointByName(npc.wpname);
    if !Ninja_MaxXPHelper_IsNpcSpawned(npc) {
        if !waypointPointer {
            return FALSE; // Nothing to show.
        };
        var zCWaypoint wp; wp = _^(waypointPointer);
        x = wp.pos[0];
        y = wp.pos[1];
        z = wp.pos[2];
    };
    if  (cnpc.flags & NPC_FLAG_IMMORTAL) || 
        (!Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch && Ninja_MaxXPHelper_VictoryXPReceived(cnpc)) ||
        (!Ninja_MaxXPHelper_ConsiderLevelZeroNPC && cnpc.level <= 0) {
        // No XP for NPC, skip.
        Ninja_MaxXPHelper_Trackers_Hide(trackerHandle, FALSE);
        return FALSE;
    };
    if !trackerHandle {
        trackerHandle = Ninja_MaxXPHelper_Trackers_Create();
        Ninja_MaxXPHelper_HT_Insert(_Ninja_MaxXPHelper_XPNPCLocator_HandlesHT, trackerHandle, trackerKey);
    };

    var int priority; priority = Ninja_MaxXPHelper_Trackers_MaxPriority;
    Ninja_MaxXPHelper_Trackers_GetNpcToHeroDistanceBasedPriority(npc);
    if !processingNearby {
        priority = Ninja_MaxXPHelper_Trackers_DistancePriority_Result[1];
    };
    var int size; size = Ninja_MaxXPHelper_IconSize;
    var int dist; dist = Ninja_MaxXPHelper_Trackers_DistancePriority_Result[0];
    var int color; color = _Ninja_MaxXPHelper_XPNPCLocator_NpcToColor(cnpc);
    if FALSE && gf(Ninja_MaxXPHelper_IconFadingNearbyDistance, dist) {
        var int factor; factor = subf(
            FLOATONE, 
            divf(
                subf(
                    Ninja_MaxXPHelper_IconFadingNearbyDistance, 
                    dist
                ), 
                Ninja_MaxXPHelper_IconFadingNearbyDistance
            )
        );
        color = ChangeAlpha(
            color, roundf(mulf(factor, Ninja_MaxXPHelper_ColorMaxFloat))
        );
    };
    Ninja_MaxXPHelper_Trackers_Show(
        trackerHandle, 
        x, 
        y,
        z, 
        color, 
        priority,
        _Ninja_MaxXPHelper_XPNPCLocator_NpcToTexture(cnpc),
        size
    );
    Ninja_MaxXPHelper_Trackers_SetZBufferBias(trackerHandle, radiusZ);
    if !processingNearby && _Ninja_MaxXPHelper_XPNPCLocator_NPCFullPassCycle < 2 {
        // Don't display distant NPCs until they were sorted into buckets (avoids weird flicker).
        Ninja_MaxXPHelper_Trackers_Hide(trackerHandle, TRUE);
    };
    return TRUE;
};

func void _Ninja_MaxXPHelper_XPNPCLocator_ProcessNearby() 
{
    MEM_ArrayClear(_Ninja_MaxXPHelper_XPNPCLocator_NearbyNPCArray);
    Ninja_MaxXPHelper_oCNPCSearchVobList(_Ninja_MaxXPHelper_XPNPCLocator_NearbyNPCArray);
	repeat(i, MEM_ArraySize(_Ninja_MaxXPHelper_XPNPCLocator_NearbyNPCArray)); var int i;
        var oCNPC npc; npc = _^(MEM_ArrayRead(_Ninja_MaxXPHelper_XPNPCLocator_NearbyNPCArray, i));
        if Hlp_IsValidNpc(npc) {
            _Ninja_MaxXPHelper_XPNPCLocator_ProcessNPC(npc, TRUE);
            
        };
	end;
};

func int _Ninja_MaxXPHelper_XPNPCLocator_NextGlobalNpc() {
    if !_Ninja_MaxXPHelper_XPNPCLocator_NextGlobalNpcPtr {
        _Ninja_MaxXPHelper_XPNPCLocator_NextGlobalNpcPtr = MEM_World.voblist_npcs;
    };
    var int listPtr; listPtr = _Ninja_MaxXPHelper_XPNPCLocator_NextGlobalNpcPtr;
    var zCListSort list;
    if !listPtr {
        return 0;
    };
    list = _^ (listPtr);
    listPtr = list.next;
    _Ninja_MaxXPHelper_XPNPCLocator_NextGlobalNpcPtr = listPtr;
    return list.data;
};

func void _Ninja_MaxXPHelper_XPNPCLocator_HideHandle(var int trackerKey, var int trackerHandle) {
    Ninja_MaxXPHelper_Trackers_Hide(trackerHandle, TRUE);
};

func void _Ninja_MaxXPHelper_XPNPCLocator_ReadInput() 
{
    if MEM_KeyState(Ninja_MaxXPHelper_ToggleXPNPCLocatorKeyCode) == KEY_PRESSED {
        _Ninja_MaxXPHelper_XPNPCLocator_Enabled = !_Ninja_MaxXPHelper_XPNPCLocator_Enabled;
        var string msg; msg = Ninja_MaxXPHelper_LOC_LocatorOn;
        if !_Ninja_MaxXPHelper_XPNPCLocator_Enabled {
            msg = Ninja_MaxXPHelper_LOC_LocatorOff;
            _Ninja_MaxXPHelper_XPNPCLocator_NPCFullPassCycle = 0;
           Ninja_MaxXPHelper_HT_ForEach(
                _Ninja_MaxXPHelper_XPNPCLocator_HandlesHT, 
                _Ninja_MaxXPHelper_XPNPCLocator_HideHandle
            );
        };
        Ninja_MaxXPHelper_TextAlerts_Create(
            msg, Ninja_MaxXPHelper_SystemAlertDuration, 
            RGBA(50, 255, 50, 0),
            TRUE
        );
    };    
};

func void _Ninja_MaxXPHelper_XPNPCLocator_RefreshLoop() {
    _Ninja_MaxXPHelper_XPNPCLocator_ReadInput();
    if _Ninja_MaxXPHelper_XPNPCLocator_Enabled {
        var int processed; processed = 0;
        _Ninja_MaxXPHelper_XPNPCLocator_ProcessNearby();
        while (_Ninja_MaxXPHelper_XPNPCLocator_Enabled && !Timer_IsPaused());
            var int npcPtr; npcPtr = _Ninja_MaxXPHelper_XPNPCLocator_NextGlobalNpc();
            if !npcPtr {
                _Ninja_MaxXPHelper_XPNPCLocator_NPCFullPassCycle = _Ninja_MaxXPHelper_XPNPCLocator_NPCFullPassCycle + 1;
                break;
            };
            var oCNPC npc; npc = _^(npcPtr);
            if Hlp_IsValidNpc(npc) {
                _Ninja_MaxXPHelper_XPNPCLocator_ProcessNPC(npc, FALSE);
            };
            processed = processed + 1;
            if processed > Ninja_MaxXPHelper_XPNPCLocator_MaxNPCToProcessEachFrameBeforeYield {
                // yield so the main thread isn't blocked for too long    
                break;
            };
        end;
    };
};

func void _Ninja_MaxXPHelper_XPNPCLocator_ReleaseHandle(var int trackerKey, var int trackerHandle) {
    Ninja_MaxXPHelper_Trackers_Release(trackerHandle);
};
func void _Ninja_MaxXPHelper_XPNPCLocator_InitHandlesHT() {
  if _Ninja_MaxXPHelper_XPNPCLocator_HandlesHT {
        Ninja_MaxXPHelper_HT_ForEach(
            _Ninja_MaxXPHelper_XPNPCLocator_HandlesHT, 
            _Ninja_MaxXPHelper_XPNPCLocator_ReleaseHandle
        );
        Ninja_MaxXPHelper_HT_DestroyPtr(_Ninja_MaxXPHelper_XPNPCLocator_HandlesHT);
    };
    _Ninja_MaxXPHelper_XPNPCLocator_HandlesHT = Ninja_MaxXPHelper_HT_Create();
};

func void _Ninja_MaxXPHelper_XPNPCLocator_InitNearbyNPCArray() {
    if _Ninja_MaxXPHelper_XPNPCLocator_NearbyNPCArray {
        MEM_ArrayFree(_Ninja_MaxXPHelper_XPNPCLocator_NearbyNPCArray);
    };
    _Ninja_MaxXPHelper_XPNPCLocator_NearbyNPCArray = MEM_ArrayCreate();
};

func void Ninja_MaxXPHelper_XPNPCLocator_Init() {
    _Ninja_MaxXPHelper_XPNPCLocator_Enabled = FALSE;
    _Ninja_MaxXPHelper_XPNPCLocator_NPCFullPassCycle = 0;
    _Ninja_MaxXPHelper_XPNPCLocator_NextGlobalNpcPtr = MEM_World.voblist_npcs;
    _Ninja_MaxXPHelper_XPNPCLocator_InitNearbyNPCArray();
    _Ninja_MaxXPHelper_XPNPCLocator_InitHandlesHT();
    FF_ApplyOnceGT(_Ninja_MaxXPHelper_XPNPCLocator_RefreshLoop);
};
