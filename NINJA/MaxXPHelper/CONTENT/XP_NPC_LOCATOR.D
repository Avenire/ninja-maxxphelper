const int _Ninja_MaxXPHelper_XPNPCLocator_Enabled = 0;
const int _Ninja_MaxXPHelper_XPNPCLocator_HandlesHT = 0;
const int _Ninja_MaxXPHelper_XPNPCLocator_NearbyNPCArray = 0;
const int Ninja_MaxXPHelper_XPNPCLocator_MaxNPCToProcessEachFrameBeforeYield = 5;
const int _Ninja_MaxXPHelper_XPNPCLocator_NextGlobalNpcPtr = 0;
const int _Ninja_MaxXPHelper_XPNPCLocator_NPCFullPassCycle = 0;
const int _Ninja_MaxXPHelper_XPNPCLocator_NPCToCycle_HT = 0;
const int _Ninja_MaxXPHelper_XPNPCLocator_NPCToAlternativeTrackerLocation_HT = 0;

const int _Ninja_MaxXPHelper_XPNPCLocator_TextureSymbol = 0;

func int _Ninja_MaxXPHelper_zCTexture_Exists(var string name) {
    CALL_zStringPtrParam(name);
    CALL__cdecl(MEMINT_SwitchG1G2(0, 6243600));
    return CALL_RetValAsInt();
};

func string _Ninja_MaxXPHelper_XPNPCLocator_NpcToTexture(var c_npc npc) {
    const int specialTexture = 0; 
    specialTexture = Ninja_MaxXPHelper_HT_Get(_Ninja_MaxXPHelper_XPNPCLocator_TextureSymbol, 1000 + npc.aivar[AIV_MM_REAL_ID]);
    if !specialTexture {    
        const int normalizedGuild = 0; normalizedGuild = Ninja_MaxXPHelper_NormalizedGuild(npc.guild);
        specialTexture = Ninja_MaxXPHelper_HT_Get(_Ninja_MaxXPHelper_XPNPCLocator_TextureSymbol, 2000 + normalizedGuild);
    };
    if specialTexture {
        var zCPar_Symbol s; s = _^(specialTexture);
        const string textureName = ""; textureName = ConcatStrings(s.name, ".tga");
        textureName = ConcatStrings("MAXXPHELPER_", textureName);
        return textureName;
    };
    if Ninja_MaxXPHelper_IsKnockable(hero, npc) {
        if Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch && Ninja_MaxXPHelper_VictoryXPReceived(npc) {
            return "MAXXPHELPER_DOUBLEXP_RANGED_KILL2.tga";
        };
        return "MAXXPHELPER_KNOCKOUT2.tga";
    };
    return "MAXXPHELPER_DEAD2.tga";
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
func void _Ninja_MaxXPHelper_GetRoutinePos(var oCNPC npc) {
    const int returnAddr = 0; returnAddr = _@(_Ninja_MaxXPHelper_XPNPCLocator_TryGetLocation_Result);
    const int call = 0;
    const int npcPtr = 0; npcPtr = _@(npc);
    const int __this = 0; __this = MEMINT_SwitchG1G2(9290272, 11219400);
    if (CALL_Begin(call))
    {
        Ninja_MaxXPHelper_LogInfo(IntToString(returnAddr));
        CALL_IntParam(_@(npcPtr));
        CALL_IntParam(_@(returnAddr));
        CALL__thiscall(_@(__this), MEMINT_SwitchG1G2(7133552, 7821264));
        call = CALL_End();
    };
};

func int _Ninja_MaxXPHelper_XPNPCLocator_TryGetLocation(var oCNPC npc) {
    // todo cleanuo
    const int empty[3] = {0,0,0};
    const int x = 0; x = 0; 
    const int y = 0; y = 0; 
    const int z = 0; z = 0;
    var zCVob vob; vob = _^(_@(npc));
    if vob.globalVobTreeNode > 0 {
        x = npc._zCVob_trafoObjToWorld[zCVob_trafoObjToWorld_X];
        y = npc._zCVob_trafoObjToWorld[zCVob_trafoObjToWorld_Y];
        z = npc._zCVob_trafoObjToWorld[zCVob_trafoObjToWorld_Z];
        _Ninja_MaxXPHelper_XPNPCLocator_TryGetLocation_Result[0] = x;
        _Ninja_MaxXPHelper_XPNPCLocator_TryGetLocation_Result[1] = y;
        _Ninja_MaxXPHelper_XPNPCLocator_TryGetLocation_Result[2] = z;
        return TRUE;
    } else {
        if npc.state_hasRoutine {
            _Ninja_MaxXPHelper_GetRoutinePos(npc);
             if _Ninja_MaxXPHelper_XPNPCLocator_TryGetLocation_Result[0] == FLOATNULL && 
             _Ninja_MaxXPHelper_XPNPCLocator_TryGetLocation_Result[1] == FLOATNULL && 
             _Ninja_MaxXPHelper_XPNPCLocator_TryGetLocation_Result[2] == FLOATNULL {
                return FALSE;
            };
            return TRUE;
        } else {
            // If oCNpc does not have routine then it will never spawn unless present in the SpawnMan spawn list.
            const int i = 0; i = 0;
            while (i < MEM_SpawnManager.spawnList_numInArray);
                var oTSpawnNode node; node = _^(MEM_ArrayRead(_@(MEM_SpawnManager), i));
                if node.npc == _@(npc) {
                    x = node.spawnPos[0];
                    y = node.spawnPos[1];
                    z = node.spawnPos[2];
                    _Ninja_MaxXPHelper_XPNPCLocator_TryGetLocation_Result[0] = x;
                    _Ninja_MaxXPHelper_XPNPCLocator_TryGetLocation_Result[1] = y;
                    _Ninja_MaxXPHelper_XPNPCLocator_TryGetLocation_Result[2] = z;
                    return TRUE;
                };
                i = i + 1;
            end;
        };
    };
    return FALSE;
};

func int _Ninja_MaxXPHelper_XPNPCLocator_IsNpcDead(var c_npc npc) {
    var oCNPC _npc; _npc = _^(_@(npc));
    return Npc_IsDead(npc) || STR_Compare(_npc.wpname, "TOT") == STR_EQUAL;
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
    const int hasItems = FALSE; hasItems = FALSE;
    if MEMINT_SwitchG1G2(FALSE, TRUE) {
        const int init = 0;
        const int swampweed = 0; 
        const int berry = 0; 
        const int oldcoin = 0; 
        if !init {
            swampweed = MEM_GetSymbolIndex("ItPl_SwampHerb");
            berry = MEM_GetSymbolIndex("ITPL_DEX_HERB_01");
            oldcoin = MEM_GetSymbolIndex("itmi_oldcoin");
            init = TRUE;
        };
        if Npc_HasItems(cnpc, berry) || Npc_HasItems(cnpc, swampweed) || Npc_HasItems(cnpc, oldcoin) {
            // show tracker, todo
            hasItems = TRUE;
        };
    };
    if !hasItems && _Ninja_MaxXPHelper_XPNPCLocator_IsNpcDead(cnpc) {
        Ninja_MaxXPHelper_Trackers_Hide(trackerHandle, FALSE);
        return FALSE;
    };
    
    var string texture; texture = _Ninja_MaxXPHelper_XPNPCLocator_NpcToTexture(cnpc);
    const int color = 0; color = _Ninja_MaxXPHelper_XPNPCLocator_NpcToColor(cnpc);
    if 
        _Ninja_MaxXPHelper_XPNPCLocator_LocatorMode & _Ninja_MaxXPHelper_XPNPCLocator_LocatorModeXPItems &&
        hasItems && 
        !(cnpc.flags & NPC_FLAG_IMMORTAL) {
        texture = "MAXXPHELPER_LOOT.tga";
        color = Ninja_MaxXPHelper_PickpocketIndeterminableColor;
    }
    else if 
        _Ninja_MaxXPHelper_XPNPCLocator_LocatorMode & _Ninja_MaxXPHelper_XPNPCLocator_LocatorModePickpocket &&
        Ninja_MaxXPHelper_ConsiderPickpocketing && Ninja_MaxXPHelper_ThiefScanner_CanPickpocketNpc(cnpc) {
        texture = "MAXXPHELPER_PICKPOCKET2.tga";
        const int enoughDex = 0; enoughDex = Ninja_MaxXPHelper_ThiefScanner_EnoughDexToPickpocket(cnpc);
        if enoughDex == Ninja_MaxXPHelper_ThiefScanner_Unknown {
            color = Ninja_MaxXPHelper_PickpocketIndeterminableColor;
        } else if enoughDex == Ninja_MaxXPHelper_ThiefScanner_SeemsEnough {
            color = Ninja_MaxXPHelper_PickpocketSeemsEnoughDexColor;
        } else {
            color = Ninja_MaxXPHelper_PickpocketSeemsNotEnoughDexColor;
        };
    } else if 
        !(_Ninja_MaxXPHelper_XPNPCLocator_LocatorMode & _Ninja_MaxXPHelper_XPNPCLocator_LocatorModeNPCs) ||
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
        var zCVob vob; vob = _^(_@(npc));
        if !vob.globalVobTreeNode {
            color = RGBA(
                (color >> 16) & 255, 
                (color >> 8) & 255, 
                (color) & 255, 
                128
            );
        };
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


const int _Ninja_MaxXPHelper_XPNPCLocator_ProcessGlobalNPCs_Total = 0;
const int _Ninja_MaxXPHelper_XPNPCLocator_ProcessGlobalNPCs_Accumulator = 0;
const int _Ninja_MaxXPHelper_XPNPCLocator_ResetGlobalVOBSearch_Called = FALSE;

func void _Ninja_MaxXPHelper_XPNPCLocator_ProcessNearbyNPCs() 
{
    const int idx = 0;
    const int npcPtr = 0;
    const int size = 0;
    const int processed = 0; processed = 0;
    if idx >= size {
        MEM_ArrayClear(_Ninja_MaxXPHelper_XPNPCLocator_NearbyNPCArray);
        Ninja_MaxXPHelper_oCNPCSearchVobList(_Ninja_MaxXPHelper_XPNPCLocator_NearbyNPCArray);
        idx = 0;
    };
    size = MEM_ArraySize(_Ninja_MaxXPHelper_XPNPCLocator_NearbyNPCArray);
    
	while (idx < size);
        npcPtr = MEM_ArrayRead(_Ninja_MaxXPHelper_XPNPCLocator_NearbyNPCArray, idx);
        if npcPtr {
            var oCNPC npc; npc = _^(npcPtr);
            if Hlp_IsValidNpc(npc) {
                if _Ninja_MaxXPHelper_XPNPCLocator_ProcessNPC(npc, TRUE) {
                    // _Ninja_MaxXPHelper_XPNPCLocator_ProcessNearbyNPCs_Accumulator += 1;
                };
                processed = processed + 1;
            };
        };
        idx = idx + 1;
        if processed > Ninja_MaxXPHelper_XPNPCLocator_MaxNPCToProcessEachFrameBeforeYield {
            break;
        };
	end;
};

const int _Ninja_MaxXPHelper_XPNPCLocator_LocatorModeMaxIdx = 4;
const int _Ninja_MaxXPHelper_XPNPCLocator_LocatorModeNPCs = 4;
const int _Ninja_MaxXPHelper_XPNPCLocator_LocatorModeXPItems = 2;
const int _Ninja_MaxXPHelper_XPNPCLocator_LocatorModePickpocket = 1;

const int _Ninja_MaxXPHelper_XPNPCLocator_LocatorModeAll = 15;

var int _Ninja_MaxXPHelper_XPNPCLocator_LocatorModeIdx;
const int _Ninja_MaxXPHelper_XPNPCLocator_LocatorMode = _Ninja_MaxXPHelper_XPNPCLocator_LocatorModeAll;
var int _Ninja_MaxXPHelper_XPNPCLocator_LocatorModeTextHandle;
func void _Ninja_MaxXPHelper_XPNPCLocator_HideHandle(var int trackerKey, var int trackerHandle) {
    Ninja_MaxXPHelper_Trackers_Hide(trackerHandle, TRUE);
};
func void _Ninja_MaxXPHelper_XPNPCLocator_UpdateViewMode(var int change) {
    delete(_Ninja_MaxXPHelper_XPNPCLocator_LocatorModeTextHandle);
    if !_Ninja_MaxXPHelper_XPNPCLocator_Enabled {
        return;
    };
    const int goto = 0; 
    goto = MEM_StackPos.position;
    if change != 0 {
        _Ninja_MaxXPHelper_XPNPCLocator_ProcessGlobalNPCs_Total = -1;
        _Ninja_MaxXPHelper_XPNPCLocator_ResetGlobalVOBSearch_Called = TRUE;
        _Ninja_MaxXPHelper_XPNPCLocator_ProcessGlobalNPCs_Accumulator = 0;
        _Ninja_MaxXPHelper_XPNPCLocator_NextGlobalNpcPtr = 0;
    
        if _Ninja_MaxXPHelper_XPNPCLocator_LocatorModeIdx <= 0 {
            _Ninja_MaxXPHelper_XPNPCLocator_LocatorModeIdx = 0;
        };
        if change < 0 && _Ninja_MaxXPHelper_XPNPCLocator_LocatorModeIdx == 0 {
            _Ninja_MaxXPHelper_XPNPCLocator_LocatorModeIdx = _Ninja_MaxXPHelper_XPNPCLocator_LocatorModeMaxIdx - 1;
        } else {
            _Ninja_MaxXPHelper_XPNPCLocator_LocatorModeIdx = (
                _Ninja_MaxXPHelper_XPNPCLocator_LocatorModeIdx + change
            ) % _Ninja_MaxXPHelper_XPNPCLocator_LocatorModeMaxIdx;
        };
    };
    if _Ninja_MaxXPHelper_XPNPCLocator_LocatorModeIdx <= 0 {
        _Ninja_MaxXPHelper_XPNPCLocator_LocatorMode = _Ninja_MaxXPHelper_XPNPCLocator_LocatorModeAll;
    } else {
        _Ninja_MaxXPHelper_XPNPCLocator_LocatorMode = 1 << (_Ninja_MaxXPHelper_XPNPCLocator_LocatorModeIdx - 1);
    };
    if (
        !Ninja_MaxXPHelper_ConsiderPickpocketing && 
        _Ninja_MaxXPHelper_XPNPCLocator_LocatorMode == _Ninja_MaxXPHelper_XPNPCLocator_LocatorModePickpocket
    ) {
        if change == 0 { change = 1; };
        MEM_StackPos.position = goto;
    };
    const string msg = ""; msg = "";
    if _Ninja_MaxXPHelper_XPNPCLocator_LocatorMode == _Ninja_MaxXPHelper_XPNPCLocator_LocatorModeAll {
        msg = Ninja_MaxXPHelper_LOC_XPLocatorModeAll;
    } else if _Ninja_MaxXPHelper_XPNPCLocator_LocatorMode == _Ninja_MaxXPHelper_XPNPCLocator_LocatorModePickpocket {
        msg = Ninja_MaxXPHelper_LOC_XPLocatorModePickpocket;

    } else if _Ninja_MaxXPHelper_XPNPCLocator_LocatorMode == _Ninja_MaxXPHelper_XPNPCLocator_LocatorModeXPItems {
        msg = Ninja_MaxXPHelper_LOC_XPLocatorModeItems;

    } else if _Ninja_MaxXPHelper_XPNPCLocator_LocatorMode == _Ninja_MaxXPHelper_XPNPCLocator_LocatorModeNPCs {
        msg = Ninja_MaxXPHelper_LOC_XPLocatorModeNPCsToBeat;
    };
    msg = ConcatStrings(msg, " (");
    if _Ninja_MaxXPHelper_XPNPCLocator_ProcessGlobalNPCs_Total < 0 {
        msg = ConcatStrings(msg, "...");
    } else {
        msg = ConcatStrings(msg, IntToString( _Ninja_MaxXPHelper_XPNPCLocator_ProcessGlobalNPCs_Total));
    };
    msg = ConcatStrings(msg, ")");
    _Ninja_MaxXPHelper_XPNPCLocator_LocatorModeTextHandle = Print_Ext(
        0, 0, 
        msg,
        "Font_old_10_white.tga", 
        Ninja_MaxXPHelper_SystemNotificationsColor, -1
    );
};

func void _Ninja_MaxXPHelper_XPNPCLocator_ReadInput() {
    if MEM_KeyState(Ninja_MaxXPHelper_XPNPCLocatorNextModeKey) == KEY_PRESSED {
        _Ninja_MaxXPHelper_XPNPCLocator_UpdateViewMode(1);
    } else if MEM_KeyState(Ninja_MaxXPHelper_XPNPCLocatorPreviousModeKey) == KEY_PRESSED {
        _Ninja_MaxXPHelper_XPNPCLocator_UpdateViewMode(-1);
    } else if MEM_KeyState(Ninja_MaxXPHelper_ToggleXPNPCLocatorKeyCode) == KEY_PRESSED {
        _Ninja_MaxXPHelper_XPNPCLocator_Enabled = !_Ninja_MaxXPHelper_XPNPCLocator_Enabled;
        const string msg = ""; 
        if !_Ninja_MaxXPHelper_XPNPCLocator_Enabled {
            msg = Ninja_MaxXPHelper_LOC_LocatorOff;
            _Ninja_MaxXPHelper_XPNPCLocator_NPCFullPassCycle = 0;
            Ninja_MaxXPHelper_HT_ForEach(
                _Ninja_MaxXPHelper_XPNPCLocator_HandlesHT, 
                _Ninja_MaxXPHelper_XPNPCLocator_HideHandle
            );
            delete(_Ninja_MaxXPHelper_XPNPCLocator_LocatorModeTextHandle);
        } else {
            msg = Ninja_MaxXPHelper_LOC_LocatorOn;  
        };
        _Ninja_MaxXPHelper_XPNPCLocator_UpdateViewMode(0);
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
        if _Ninja_MaxXPHelper_zCListSort_Cycle_LastCallWrite && !_Ninja_MaxXPHelper_XPNPCLocator_ResetGlobalVOBSearch_Called {
            _Ninja_MaxXPHelper_XPNPCLocator_ProcessGlobalNPCs_Total = _Ninja_MaxXPHelper_XPNPCLocator_ProcessGlobalNPCs_Accumulator;
            _Ninja_MaxXPHelper_XPNPCLocator_UpdateViewMode(0);
            _Ninja_MaxXPHelper_XPNPCLocator_ProcessGlobalNPCs_Accumulator = 0;
        };
        if _Ninja_MaxXPHelper_zCListSort_Cycle_LastCallWrite && _Ninja_MaxXPHelper_XPNPCLocator_ResetGlobalVOBSearch_Called {
            _Ninja_MaxXPHelper_XPNPCLocator_ResetGlobalVOBSearch_Called = FALSE;
        };  
        if !npcPtr {
            _Ninja_MaxXPHelper_XPNPCLocator_NPCFullPassCycle = _Ninja_MaxXPHelper_XPNPCLocator_NPCFullPassCycle + 1;
            break;
        };
        var oCNPC npc; npc = _^(npcPtr);
        if Hlp_IsValidNpc(npc) {
            if _Ninja_MaxXPHelper_XPNPCLocator_ProcessNPC(npc, FALSE) {
                _Ninja_MaxXPHelper_XPNPCLocator_ProcessGlobalNPCs_Accumulator += 1;
            };
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

func void _Ninja_MaxXPHelper_XPNPCLocator_InitGuildToCode() {
    Ninja_MaxXPHelper_HT_ClearAndCreate(_@(_Ninja_MaxXPHelper_XPNPCLocator_TextureSymbol), 0);
    STRINT_SplitReset();
    const int count = 0; count = STR_SplitCount(
        Ninja_MaxXPHelper_GuildIcons, ";"
    );
    repeat(i, count); const int i = 0;
        const string guildSymbolName = ""; guildSymbolName = STRINT_SplitGet(i);
        const int symbolPtr = 0; symbolPtr = MEM_GetSymbol(guildSymbolName);
        if symbolPtr {
            var zCPar_Symbol s; s = _^(symbolPtr);
            Ninja_MaxXPHelper_HT_Insert(
                _Ninja_MaxXPHelper_XPNPCLocator_TextureSymbol,
                symbolPtr,
                2000 + s.content
            );
        } else {
            // Ninja_MaxXPHelper_LogInfo(ConcatStrings("XP locator g    uild icon not found - ", guildSymbolName));
        };
    end;
        STRINT_SplitReset();
    const int count = 0; count = STR_SplitCount(
        Ninja_MaxXPHelper_SpeciesIdIcons, ";"
    );
    repeat(i, count); const int i = 0;
        const string guildSymbolName = ""; guildSymbolName = STRINT_SplitGet(i);
        const int symbolPtr = 0; symbolPtr = MEM_GetSymbol(guildSymbolName);
        if symbolPtr {
            var zCPar_Symbol s; s = _^(symbolPtr);
            Ninja_MaxXPHelper_HT_Insert(
                _Ninja_MaxXPHelper_XPNPCLocator_TextureSymbol,
                symbolPtr,
                1000 + s.content
            );
        } else {
            // Ninja_MaxXPHelper_LogInfo(ConcatStrings("XP locator species icon not found - ", guildSymbolName));
        };
    end;
};

func void _Ninja_MaxXPHelper_XPNPCLocator_ResetGlobalVOBSearch() {
    const int npcPtr = 0; npcPtr = MEM_ReadInt(ESP + 4);
    if !npcPtr {
        Ninja_MaxXPHelper_LogInfo("Exit _Ninja_MaxXPHelper_XPNPCLocator_ResetGlobalVOBSearch - null vob");
        return;
    };
    var C_Npc npcMaybe; npcMaybe = _^(npcPtr);
    if Hlp_IsValidNpc(npcMaybe) {
        Ninja_MaxXPHelper_LogInfo("_Ninja_MaxXPHelper_XPNPCLocator_ResetGlobalVOBSearch - valid NPC vob, reset");
        _Ninja_MaxXPHelper_XPNPCLocator_NextGlobalNpcPtr = 0;
        _Ninja_MaxXPHelper_XPNPCLocator_ResetGlobalVOBSearch_Called = TRUE;
        _Ninja_MaxXPHelper_XPNPCLocator_ProcessGlobalNPCs_Accumulator = 0;
    } else {
    };
};

func void Ninja_MaxXPHelper_XPNPCLocator_Init() {
    Ninja_MaxXPHelper_HT_ClearAndCreate(_@(_Ninja_MaxXPHelper_XPNPCLocator_NPCToCycle_HT), 0);
    Ninja_MaxXPHelper_HT_ClearAndCreate(_@(_Ninja_MaxXPHelper_XPNPCLocator_NPCToAlternativeTrackerLocation_HT), 0);
    _Ninja_MaxXPHelper_XPNPCLocator_UpdateViewMode(0);
    _Ninja_MaxXPHelper_XPNPCLocator_NPCFullPassCycle = 0;
    _Ninja_MaxXPHelper_XPNPCLocator_NextGlobalNpcPtr = MEM_World.voblist_npcs;
    _Ninja_MaxXPHelper_XPNPCLocator_ProcessGlobalNPCs_Total = -1;
    _Ninja_MaxXPHelper_XPNPCLocator_ProcessGlobalNPCs_Accumulator = 0;
    _Ninja_MaxXPHelper_XPNPCLocator_InitNearbyNPCArray();
    _Ninja_MaxXPHelper_XPNPCLocator_InitHandlesHT();
    _Ninja_MaxXPHelper_XPNPCLocator_InitGuildToCode();
    FF_ApplyOnceGT(_Ninja_MaxXPHelper_XPNPCLocator_RefreshLoop);
    HookEngineF(
        MEMINT_SwitchG1G2(7172384, 7865136),
        6,
        _Ninja_MaxXPHelper_XPNPCLocator_ResetGlobalVOBSearch
    );
    HookEngineF(
        MEMINT_SwitchG1G2(7171824, 7864512),
        7,
        _Ninja_MaxXPHelper_XPNPCLocator_ResetGlobalVOBSearch
    );
};
