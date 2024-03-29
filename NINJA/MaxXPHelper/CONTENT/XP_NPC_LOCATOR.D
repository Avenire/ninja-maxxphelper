const int _Ninja_MaxXPHelper_XPNPCLocator_Enabled = 0;
const int _Ninja_MaxXPHelper_XPNPCLocator_HandlesHT = 0;
const int _Ninja_MaxXPHelper_XPNPCLocator_NearbyNPCArray = 0;
const int Ninja_MaxXPHelper_XPNPCLocator_MaxNPCToProcessEachFrameBeforeYield = 5;
const int _Ninja_MaxXPHelper_XPNPCLocator_NextGlobalNpcPtr = 0;
const int _Ninja_MaxXPHelper_XPNPCLocator_NPCFullPassCycle = 0;
const int _Ninja_MaxXPHelper_XPNPCLocator_NPCToCycle_HT = 0;
const int _Ninja_MaxXPHelper_XPNPCLocator_NPCToAlternativeTrackerLocation_HT = 0;

func string _Ninja_MaxXPHelper_XPNPCLocator_NpcToTexture(var c_npc npc) {
    if Ninja_MaxXPHelper_IsKnockable(hero, npc) {
        if Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch && Ninja_MaxXPHelper_VictoryXPReceived(npc) {
            return "MAXXPHELPER_DOUBLEXP_RANGED_KILL.tga";
        };
        return "MAXXPHELPER_KNOCKOUT.tga";
    };
    const int att = 0; att = Npc_GetPermAttitude(hero, npc);
    return "MAXXPHELPER_KILL.tga";
}; 

func int _Ninja_MaxXPHelper_XPNPCLocator_NpcToColor(var c_npc npc) {
    const int att = 0; att = Npc_GetPermAttitude(hero, npc);
    if att != ATT_HOSTILE { 
        return Ninja_MaxXPHelper_XPNPCLocatorNonHostileColor; 
    } else { 
        return Ninja_MaxXPHelper_XPNPCLocatorHostileColor; 
    };
};

const int _Ninja_MaxXPHelper_XPNPCLocator_TryGetLocation_Result[3] = {0,0,0}; 
func int _Ninja_MaxXPHelper_XPNPCLocator_TryGetLocation(var oCNPC npc) {
    const int empty[3] = {0,0,0};
    const int x = 0; x = 0; 
    const int y = 0; y = 0; 
    const int z = 0; z = 0;
    if !Ninja_MaxXPHelper_IsNpcSpawned(npc) {
        // todo: do all of this once per NPC?
        if !Ninja_MaxXPHelper_CanNpcSpawn(npc) {
            return FALSE;
        };
        const int altLocationPtr = 0; altLocationPtr = Ninja_MaxXPHelper_HT_Get(
            _Ninja_MaxXPHelper_XPNPCLocator_NPCToAlternativeTrackerLocation_HT,
            _@(npc)
        );
        if altLocationPtr {
            if altLocationPtr == _@(empty) { return FALSE; };
            x = MEM_ReadInt(altLocationPtr);
            y = MEM_ReadInt(altLocationPtr + 4);
            z = MEM_ReadInt(altLocationPtr + 8);
        } else {
            // Some NPCs in G2 seem to have incorrect waypoint set (lizard in NW_CITY_HARBOUR_01)
            // so need to check spawn position first
            const int i = 0; i = 0;
            while (i < MEM_SpawnManager.spawnList_numInArray);
                var oTSpawnNode node; node = _^(MEM_ArrayRead(_@(MEM_SpawnManager), i));
                if node.npc == _@(npc) {
                    x = node.spawnPos[0];
                    y = node.spawnPos[1];
                    z = node.spawnPos[2];
                    Ninja_MaxXPHelper_HT_InsertOrChange(_Ninja_MaxXPHelper_XPNPCLocator_NPCToAlternativeTrackerLocation_HT, _@(npc), _@(node.spawnPos));
                    break;
                };
                i = i + 1;
            end;
            // This can however still be world origin (0,0,0) so if that's the case then fallback to WP location...
            if x == FLOATNULL && y == FLOATNULL && z == FLOATNULL {
                const int waypointPointer = 0; waypointPointer = Ninja_MaxXPHelper_GetWaypointByName(npc.wpname);
                if waypointPointer {
                    var zCWaypoint wp; wp = _^(waypointPointer);
                    x = wp.pos[0];
                    y = wp.pos[1];
                    z = wp.pos[2];
                    Ninja_MaxXPHelper_HT_InsertOrChange(_Ninja_MaxXPHelper_XPNPCLocator_NPCToAlternativeTrackerLocation_HT, _@(npc), _@(wp.pos));
                };
            };
            if x == FLOATNULL && y == FLOATNULL && z == FLOATNULL {
                Ninja_MaxXPHelper_HT_InsertOrChange(_Ninja_MaxXPHelper_XPNPCLocator_NPCToAlternativeTrackerLocation_HT, _@(npc), _@(empty));
                return FALSE;
            };
        };
    } else {
        x = npc._zCVob_trafoObjToWorld[zCVob_trafoObjToWorld_X];
        y = npc._zCVob_trafoObjToWorld[zCVob_trafoObjToWorld_Y];
        z = npc._zCVob_trafoObjToWorld[zCVob_trafoObjToWorld_Z];
    };

    _Ninja_MaxXPHelper_XPNPCLocator_TryGetLocation_Result[0] = x;
    _Ninja_MaxXPHelper_XPNPCLocator_TryGetLocation_Result[1] = y;
    _Ninja_MaxXPHelper_XPNPCLocator_TryGetLocation_Result[2] = z;
    return TRUE;
};

func int _Ninja_MaxXPHelper_XPNPCLocator_ProcessNPC(var oCNPC npc, var int processingNearby) {
    var c_npc cnpc; cnpc = _^(_@(npc));
    if Npc_IsPlayer(cnpc) {
        return FALSE;
    };

    const int x = 0; x = 0; 
    const int y = 0; y = 0; 
    const int z = 0; z = 0;
    
    const int trackerKey = 0; trackerKey = _@(npc);
    const int trackerHandle = 0; trackerHandle = Ninja_MaxXPHelper_HT_Get(_Ninja_MaxXPHelper_XPNPCLocator_HandlesHT, trackerKey);
    if  Npc_IsDead(cnpc) {
        Ninja_MaxXPHelper_Trackers_Hide(trackerHandle, FALSE);
        return FALSE;
    };
    if !processingNearby && 
        Ninja_MaxXPHelper_HT_Get(_Ninja_MaxXPHelper_XPNPCLocator_NPCToCycle_HT, trackerKey) == _Ninja_MaxXPHelper_XPNPCLocator_NPCFullPassCycle + 1 {
        return FALSE;
    };
    Ninja_MaxXPHelper_HT_InsertOrChange(
        _Ninja_MaxXPHelper_XPNPCLocator_NPCToCycle_HT, 
        trackerKey, 
        _Ninja_MaxXPHelper_XPNPCLocator_NPCFullPassCycle + 1
    );
    
    var string texture; texture = _Ninja_MaxXPHelper_XPNPCLocator_NpcToTexture(cnpc);
    const int color = 0; color = _Ninja_MaxXPHelper_XPNPCLocator_NpcToColor(cnpc);
    if Ninja_MaxXPHelper_ConsiderPickpocketing && Ninja_MaxXPHelper_ThiefScanner_CanPickpocketNpc(cnpc) {
        texture = "MAXXPHELPER_PICKPOCKET.tga";
        const int enoughDex = 0; enoughDex = Ninja_MaxXPHelper_ThiefScanner_EnoughDexToPickpocket(cnpc);
        if enoughDex == Ninja_MaxXPHelper_ThiefScanner_Unknown {
            color = Ninja_MaxXPHelper_PickpocketIndeterminableColor;
        } else if enoughDex == Ninja_MaxXPHelper_ThiefScanner_SeemsEnough {
            color = Ninja_MaxXPHelper_PickpocketSeemsEnoughDexColor;
        } else {
            color = Ninja_MaxXPHelper_PickpocketSeemsNotEnoughDexColor;
        };
    } else if 
        Ninja_MaxXPHelper_PickpocketTrackersOnly ||
        (cnpc.flags & NPC_FLAG_IMMORTAL) || 
        (!Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch && Ninja_MaxXPHelper_VictoryXPReceived(cnpc)) ||
        (!Ninja_MaxXPHelper_ConsiderLevelZeroNPC && cnpc.level <= 0) {
        Ninja_MaxXPHelper_Trackers_Hide(trackerHandle, FALSE);
        return FALSE;
    };

    if !_Ninja_MaxXPHelper_XPNPCLocator_TryGetLocation(npc) {
        return FALSE;
    };
    x = _Ninja_MaxXPHelper_XPNPCLocator_TryGetLocation_Result[0];
    y = _Ninja_MaxXPHelper_XPNPCLocator_TryGetLocation_Result[1];
    z = _Ninja_MaxXPHelper_XPNPCLocator_TryGetLocation_Result[2];
    if !trackerHandle {
        trackerHandle = Ninja_MaxXPHelper_Trackers_Create();
        Ninja_MaxXPHelper_HT_Insert(_Ninja_MaxXPHelper_XPNPCLocator_HandlesHT, trackerHandle, trackerKey);
    };

    const int priority = 0; priority = Ninja_MaxXPHelper_Trackers_MaxPriority;
    if !processingNearby {
        Ninja_MaxXPHelper_Trackers_GetHeroDistanceBasedPriority(x, y, z);
        priority = Ninja_MaxXPHelper_Trackers_DistancePriority_Result[1];
    };

    Ninja_MaxXPHelper_Trackers_Show(
        trackerHandle, 
        x, 
        y,
        z, 
        color, 
        priority,
        texture
    );
    if Ninja_MaxXPHelper_TrackersUseZBuffer {
        Ninja_MaxXPHelper_Trackers_SetZBufferBias(
            trackerHandle, 
            mulf(subf(npc._zCVob_bbox3D_maxs[2], npc._zCVob_bbox3D_mins[2]), FLOATHALF)
        );
    };
    return TRUE;
};

func void _Ninja_MaxXPHelper_XPNPCLocator_ProcessNearbyNPCs() 
{
    const int idx = 0;
    const int size = 0;
    const int processed = 0; processed = 0;
    if idx == size {
        MEM_ArrayClear(_Ninja_MaxXPHelper_XPNPCLocator_NearbyNPCArray);
        Ninja_MaxXPHelper_oCNPCSearchVobList(_Ninja_MaxXPHelper_XPNPCLocator_NearbyNPCArray);
        size = MEM_ArraySize(_Ninja_MaxXPHelper_XPNPCLocator_NearbyNPCArray);
        idx = 0;
    };
    
	while (idx < size);
        var oCNPC npc; npc = _^(MEM_ArrayRead(_Ninja_MaxXPHelper_XPNPCLocator_NearbyNPCArray, idx));
        if Hlp_IsValidNpc(npc) {
            _Ninja_MaxXPHelper_XPNPCLocator_ProcessNPC(npc, TRUE);
            processed = processed + 1;
        };
        idx = idx + 1;
        if processed > Ninja_MaxXPHelper_XPNPCLocator_MaxNPCToProcessEachFrameBeforeYield {
            break;
        };
	end;
};

func void _Ninja_MaxXPHelper_XPNPCLocator_HideHandle(var int trackerKey, var int trackerHandle) {
    Ninja_MaxXPHelper_Trackers_Hide(trackerHandle, TRUE);
};
func void _Ninja_MaxXPHelper_XPNPCLocator_ReadInput() {
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
        } else if Ninja_MaxXPHelper_ConsiderPickpocketing {
            msg = ConcatStrings(msg, " ");
            msg = ConcatStrings(msg, Ninja_MaxXPHelper_LOC_ConsiderPickpocketingEnabled);
        };
        Ninja_MaxXPHelper_TextAlerts_Create(
            msg, 
            Ninja_MaxXPHelper_SystemAlertDurationInMillis, 
            Ninja_MaxXPHelper_SystemNotificationsColor,
            TRUE
        );
    };    
};

func void _Ninja_MaxXPHelper_XPNPCLocator_ProcessGlobalNPCs() {
    const int processed = 0; processed = 0;
    while (TRUE);
        const int npcPtr = 0; npcPtr = _Ninja_MaxXPHelper_zCListSort_Cycle(_@(_Ninja_MaxXPHelper_XPNPCLocator_NextGlobalNpcPtr), MEM_World.voblist_npcs);
        if !npcPtr {
            _Ninja_MaxXPHelper_XPNPCLocator_NPCFullPassCycle = _Ninja_MaxXPHelper_XPNPCLocator_NPCFullPassCycle + 1;
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

func void _Ninja_MaxXPHelper_XPNPCLocator_RefreshLoop() {
    _Ninja_MaxXPHelper_XPNPCLocator_ReadInput();
    if _Ninja_MaxXPHelper_XPNPCLocator_Enabled {
        _Ninja_MaxXPHelper_XPNPCLocator_ProcessNearbyNPCs();
        _Ninja_MaxXPHelper_XPNPCLocator_ProcessGlobalNPCs();
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
        Ninja_MaxXPHelper_HT_Destroy(_Ninja_MaxXPHelper_XPNPCLocator_HandlesHT);
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
    Ninja_MaxXPHelper_HT_ClearAndCreate(_@(_Ninja_MaxXPHelper_XPNPCLocator_NPCToCycle_HT), 0);
    Ninja_MaxXPHelper_HT_ClearAndCreate(_@(_Ninja_MaxXPHelper_XPNPCLocator_NPCToAlternativeTrackerLocation_HT), 0);
    _Ninja_MaxXPHelper_XPNPCLocator_Enabled = FALSE;
    _Ninja_MaxXPHelper_XPNPCLocator_NPCFullPassCycle = 0;
    _Ninja_MaxXPHelper_XPNPCLocator_NextGlobalNpcPtr = MEM_World.voblist_npcs;
    _Ninja_MaxXPHelper_XPNPCLocator_InitNearbyNPCArray();
    _Ninja_MaxXPHelper_XPNPCLocator_InitHandlesHT();
    FF_ApplyOnceGT(_Ninja_MaxXPHelper_XPNPCLocator_RefreshLoop);
};
