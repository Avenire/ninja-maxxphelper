const int Ninja_MaxXPHelper_MortalNPCLocatorOn = 0;
const int Ninja_MaxXPHelper_MortalNPCLocatorHT = 0;
const int Ninja_MaxXPHelper_MortalNPCLocator_Nearby = 0;
const int Ninja_MaxXPHelper_MortalNPCLocator_MaxNPCToProcessEachFrameBeforeYield = 10;

class _Ninja_MaxXPHelper_Sphere {
    var int sphereHandle;
    var int cycle;
};
instance _Ninja_MaxXPHelper_Sphere_Proto(_Ninja_MaxXPHelper_Sphere) {
    sphereHandle = -1;
    cycle = 0;
};



func int Ninja_MaxXPHelper_MortalNPCLocator_BBoxInFrustrum(var zTBBox3D bbox) {
    const int call = 0;
    var int bboxPtr; bboxPtr = _@(bbox);
    var int camera;
    camera = _@(MEM_Camera);
    if (CALL_Begin(call))
    {
        CALL_IntParam(_@(bboxPtr));
        // todo MEM Switch, 5467792 = zCCamera BBox3DInFrustum, 5467888
        CALL__thiscall(_@(camera), 5467792);
        call = CALL_End();
    };
    return CALL_RetValAsInt() != 1;

};

func int Ninja_MaxXPHelper_MortalNPCLocator_GetWaypoint(var string wpname) {
    const int call = 0;
    var int waypointNamePtr; waypointNamePtr = _@s(wpname);
    if (CALL_Begin(call))
    {
        CALL__fastcall (_@(MEM_World.wayNet), _@(waypointNamePtr), MEMINT_SwitchG1G2(7366448, 8061744));
        call = CALL_End();  
    };
    return CALL_RetValAsInt();
}; 

func void Ninja_MaxXPHelper_MortalNPCLocator_AttachExpiringSphereToNpc(var c_npc npc, var int expiresAt) {

}; 

func int Ninja_MaxXPHelper_MortalNPCLocator_ProcessNPC(var int npcPtr, var int processingNearby, var int cycle) {
 
    var c_npc slf; slf = _^ (npcPtr);
    var zCVob vob; vob = _^(npcPtr);
    var oCNPC npc; npc = _^(npcPtr);
    if Npc_IsPlayer(slf) {
        return FALSE;
    };
    var int waypointPointer; waypointPointer = Ninja_MaxXPHelper_MortalNPCLocator_GetWaypoint(npc.wpname);
    var int waypointTrackedSphereHndl; waypointTrackedSphereHndl = HT_Get(Ninja_MaxXPHelper_MortalNPCLocatorHT, waypointPointer);
    var _Ninja_MaxXPHelper_Sphere trackedSphere;
    if processingNearby && HLP_IsValidHandle(waypointTrackedSphereHndl) && Npc_GetDistToWP(npc, npc.wpname) < 1000 {
        Ninja_MaxXPHelper_LogInfo(ConcatStrings("Remove WP ", npc.wpname));
        trackedSphere = get(waypointTrackedSphereHndl);
        EraseSphere(trackedSphere.sphereHandle);
        delete(waypointTrackedSphereHndl);
        HT_Remove(Ninja_MaxXPHelper_MortalNPCLocatorHT, waypointPointer);
    };
    var int key; key = _@(npc);
    var int trackedSphereNpcHndl; trackedSphereNpcHndl = HT_Get(Ninja_MaxXPHelper_MortalNPCLocatorHT, key);
    if HLP_IsValidHandle(trackedSphereNpcHndl) {
        trackedSphere = get(trackedSphereNpcHndl);
        if !processingNearby && trackedSphere.cycle >= cycle {
            Ninja_MaxXPHelper_LogInfo(ConcatStrings("Skip nearby NPC ", npc.name));
            return FALSE;
        };
        if Npc_IsDead(slf) {
            Ninja_MaxXPHelper_LogInfo(ConcatStrings(
                "Remove expired dead npc sphere ", npc.name)
            );
            EraseSphere(trackedSphere.sphereHandle);
            delete(trackedSphereNpcHndl);
            HT_Remove(Ninja_MaxXPHelper_MortalNPCLocatorHT, key);
            return TRUE;
        };
    };
    var int x; x = npc._zCVob_trafoObjToWorld[3];
    var int y; y = npc._zCVob_trafoObjToWorld[7];
    var int z; z = npc._zCVob_trafoObjToWorld[11];
    var int renderHandle; renderHandle = trackedSphereNpcHndl;
    var int color; color = Ninja_MaxXPHelper_SphereColorNotBeaten;
    if Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch && Ninja_MaxXPHelper_VictoryXPReceived(slf) {
        color = Ninja_MaxXPHelper_SphereColorConsiderG1DoubleXPGlitch;
    };
    var int visible; visible = processingNearby;
    var int canCreate; canCreate = FALSE;
    if !( 
        (slf.flags & NPC_FLAG_IMMORTAL) || 
        Npc_IsDead(slf) || 
        (!Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch && Ninja_MaxXPHelper_VictoryXPReceived(slf)) ||
        (!Ninja_MaxXPHelper_ConsiderLevelZeroNPC && slf.level <= 0)
    ) {
        //Ninja_MaxXPHelper_LogInfo(ConcatStrings("Located ", npc.name));
        if (vob.bitfield[0] & zCVob_bitfield4_dontWriteIntoArchive) == 0 {
            //Ninja_MaxXPHelper_LogInfo(ConcatStrings("Dont Write into archive: ", npc.name));
            if !processingNearby && waypointPointer {
                var zCWaypoint wp; wp = _^(waypointPointer);
                x = wp.pos[0];
                y = wp.pos[1];
                z = wp.pos[2];
                key = waypointPointer;
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
            //Ninja_MaxXPHelper_LogInfo(ConcatStrings("Render handle not valid for: ", npc.name));
            renderHandle = new(_Ninja_MaxXPHelper_Sphere_Proto);
            HT_Insert(Ninja_MaxXPHelper_MortalNPCLocatorHT, renderHandle, key);
        } else {
            return FALSE;
        };

    };
    trackedSphere = get(renderHandle);
    trackedSphere.cycle = cycle;
    if !visible {
        var zTBBox3D targetBBox; targetBBox = _^(_@(npc) + 124);
        visible = Ninja_MaxXPHelper_MortalNPCLocator_BBoxInFrustrum(targetBBox);
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


func void Ninja_MaxXPHelper_MortalNPCLocator_ProcessNearby(var int cycle) 
{
	var int vobArrayPtr; vobArrayPtr = Ninja_MaxXPHelper_MortalNPCLocator_Nearby;
    MEM_ArrayClear(vobArrayPtr);
	var int worldPtr; worldPtr = _@(MEM_World);
    var int oCNpc__classDef;
    oCNpc__classDef = 9286664;
	const int call = 0; var int zero;
	if (CALL_Begin(call)) {
		CALL_PtrParam(_@(zero));                	
		CALL_PtrParam(_@(vobArrayPtr));         
		CALL_PtrParam(_@(oCNpc__classDef));   	 	
		CALL__thiscall(_@(worldPtr), 6249792);
		call = CALL_End();
	};
	repeat(i, MEM_ArraySize(vobArrayPtr)); var int i;
        var int vobPtr; vobPtr = MEM_ArrayRead(vobArrayPtr, i);
        Ninja_MaxXPHelper_MortalNPCLocator_ProcessNPC(vobPtr, TRUE, cycle);
	end;
};

const int _Ninja_MaxXPHelper_MortalNPCLocator_NextGlobalNpc_listPtr = 0;
func int _Ninja_MaxXPHelper_MortalNPCLocator_NextGlobalNpc(var int cyclePtr) {
    var int listPtr; listPtr = _Ninja_MaxXPHelper_MortalNPCLocator_NextGlobalNpc_listPtr;
    var zCListSort list;
    if !listPtr {
        if cyclePtr {
            MEM_WriteInt(cyclePtr, MEM_ReadInt(cyclePtr) + 1);
        };
        listPtr = +(MEM_ReadInt (_@ (MEM_World) + MEMINT_SwitchG1G2 (25196, 25220)));
    };
    list = _^ (listPtr);
    listPtr = list.next;
    _Ninja_MaxXPHelper_MortalNPCLocator_NextGlobalNpc_listPtr = listPtr;
    return list.data;
};


func void Ninja_MaxXPHelper_MortalNPCLocator()
{   
    // todo update nearby first
    // todo use icarus exposed member
    
    var int processed; processed = 0;
    const int cycle = 0;
    Ninja_MaxXPHelper_MortalNPCLocator_ProcessNearby(cycle);
    
    while (Ninja_MaxXPHelper_MortalNPCLocatorOn);
        if Timer_IsPaused() {
            return;
        };
        var int npcPtr; npcPtr = _Ninja_MaxXPHelper_MortalNPCLocator_NextGlobalNpc(_@(cycle));
        if !npcPtr {
            continue;
        };
        if Ninja_MaxXPHelper_MortalNPCLocator_ProcessNPC(npcPtr, FALSE, cycle) {
            processed = processed + 1;
        };
        if processed > Ninja_MaxXPHelper_MortalNPCLocator_MaxNPCToProcessEachFrameBeforeYield {
            // yield
            return;
        };
	end;
};



func void Ninja_MaxXPHelper_MortalNPCLocator_Init() {
    _Ninja_MaxXPHelper_MortalNPCLocator_NextGlobalNpc_listPtr = 0;
    Ninja_MaxXPHelper_MortalNPCLocator_Nearby = MEM_ArrayCreate();
    Ninja_MaxXPHelper_MortalNPCLocatorHT= HT_Create();
    FF_ApplyExtGT(Ninja_MaxXPHelper_Loop, 0, -1);
    FF_ApplyExtGT(Ninja_MaxXPHelper_LoopRef, 0, -1);
};

func void Ninja_MaxXPHelper_LoopRef() {
    if Ninja_MaxXPHelper_MortalNPCLocatorOn {
        Ninja_MaxXPHelper_MortalNPCLocator();
    };
};
func void _Ninja_MaxXPHelper_MortalNPCLocator_Clear(var int key, var int value) {
    var _Ninja_MaxXPHelper_Sphere p; p = get(value);
    if HLP_IsValidHandle(p.sphereHandle) {
        HideSphere(p.sphereHandle);
    };
};
// todo: cache list so NPCs are not looped over every frame.
func void Ninja_MaxXPHelper_Loop() 
{
    if MEM_KeyState(Ninja_MaxXPHelper_ToggleMortalNPCLocatorKeyCode) == KEY_PRESSED {
        Ninja_MaxXPHelper_MortalNPCLocatorOn = !Ninja_MaxXPHelper_MortalNPCLocatorOn;
        Ninja_MaxXPHelper_AddTextAlert(
            ConcatStrings("Locator toggled ", IntToString(Ninja_MaxXPHelper_MortalNPCLocatorOn)), 
            1000, 
            RGBA(50, 255, 50, 0)
        );
        if Ninja_MaxXPHelper_MortalNPCLocatorOn {
        } else {
          HT_ForEach(Ninja_MaxXPHelper_MortalNPCLocatorHT, _Ninja_MaxXPHelper_MortalNPCLocator_Clear);  
        };
    };    
};