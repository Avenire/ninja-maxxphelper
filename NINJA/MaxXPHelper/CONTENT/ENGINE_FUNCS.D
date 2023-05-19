
func int _Ninja_MaxXPHelper_GetBBoxPtr(var zCVob vob) {
    const int zCVob_zTBBox3D_offset = 124;
    return +(_@(vob) + zCVob_zTBBox3D_offset);
};


func int Ninja_MaxXPHelper_IsVobAheadOfCamera(var zCVob vob) {
    const int call = 0;
    var int bboxPtr; bboxPtr = _Ninja_MaxXPHelper_GetBBoxPtr(vob);
    var int camera; camera = _@(MEM_Camera);
    if (CALL_Begin(call))
    {
        CALL_IntParam(_@(bboxPtr));
        CALL__thiscall(_@(camera), MEMINT_SwitchG1G2(5467792, 5551024));
        call = CALL_End();
    };
    return CALL_RetValAsInt() != 1;
};

func void Ninja_MaxXPHelper_oCNPCSearchVobList(var int bufferArrayPtr) {
	var int worldPtrArg; worldPtrArg = _@(MEM_World);
    var int bufferArrayPtrArg; bufferArrayPtrArg = bufferArrayPtr;
    var int oCNpc__classDef; oCNpc__classDef = MEMINT_SwitchG1G2(9286664, 11214368);
    var int zCWorld__SearchVobListByClass; zCWorld__SearchVobListByClass = MEMINT_SwitchG1G2(6249792, 6439504);
    const int null = 0;
	const int call = 0; 
	if (CALL_Begin(call)) {
		CALL_PtrParam(_@(null));                	
		CALL_PtrParam(_@(bufferArrayPtrArg));         
		CALL_PtrParam(_@(oCNpc__classDef));   	 	
		CALL__thiscall(_@(worldPtrArg), zCWorld__SearchVobListByClass);
		call = CALL_End();
	};
};

func int Ninja_MaxXPHelper_GetWaypointByName(var string wpname) {
    const int call = 0;
    var int waypointNamePtr; waypointNamePtr = _@s(wpname);
    if (CALL_Begin(call))
    {
        CALL__fastcall (_@(MEM_World.wayNet), _@(waypointNamePtr), MEMINT_SwitchG1G2(7366448, 8061744));
        call = CALL_End();  
    };
    return CALL_RetValAsInt();
}; 

func int Ninja_MaxXPHelper_IsNpcSpawned(var oCNPC npc) {
    return (
        // 256 is partial zCVob_bitfield0_castDynShadow flag; found by experimenting, seems to work in G1
        // if NPC was never spawned it's 0, if it was ever active, it's 1 (persists with saves too)
        GOTHIC_BASE_VERSION == 1 && (npc._zCVob_bitfield[0] & 256) ||
        (
            (npc._zCVob_bitfield[0] & 256) && 
            // partial of sleeping mode flag
            (npc._zCVob_bitfield[2] & 1)
        )
    );
};
