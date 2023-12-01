
func int _Ninja_MaxXPHelper_GetBBoxPtr(var zCVob vob) {
    const int zCVob_zTBBox3D_offset = 124;
    return +(_@(vob) + zCVob_zTBBox3D_offset);
};

func int Ninja_MaxXPHelper_IsVobAheadOfCamera(var zCVob vob) {
    const int call = 0;
    const int bboxPtr = 0; bboxPtr = _Ninja_MaxXPHelper_GetBBoxPtr(vob);
    const int camera = 0; camera = _@(MEM_Camera);
    if (CALL_Begin(call))
    {
        CALL_IntParam(_@(bboxPtr));
        CALL__thiscall(_@(camera), MEMINT_SwitchG1G2(5467792, 5551024));
        call = CALL_End();
    };
    return CALL_RetValAsInt() != 1;
};

func int Ninja_MaxXPHelper_IsPointAhead(var int xf, var int yf, var int zf) {
    const int call = 0;
    const int bbox[6] = {0,0,0,0,0,0};
    bbox[0] = xf;
    bbox[1] = yf;
    bbox[2] = zf;
    bbox[3] = xf;
    bbox[4] = yf;
    bbox[5] = zf;
    const int camera = 0; camera = _@(MEM_Camera);
    const int bboxPtr = 0; bboxPtr = _@(bbox);
    const int clip = 15; // No far clip
    const int clipPtr = 0; clipPtr = _@(clip);
    if (CALL_Begin(call))
    {
        CALL_IntParam(_@(clipPtr));
        CALL_IntParam(_@(bboxPtr));
        CALL__thiscall(_@(camera), MEMINT_SwitchG1G2(5467888, 5551120));
        call = CALL_End();
    };
    return CALL_RetValAsInt() != 1; // ZTCAM_CLIPTYPE_OUT
};

func void Ninja_MaxXPHelper_oCNPCSearchVobList(var int bufferArrayPtr) {
	const int worldPtrArg = 0; worldPtrArg = _@(MEM_World);
    const int bufferArrayPtrArg = 0; bufferArrayPtrArg = bufferArrayPtr;
    const int oCNpc__classDef = 0; oCNpc__classDef = MEMINT_SwitchG1G2(9286664, 11214368);
    const int zCWorld__SearchVobListByClass = 0; zCWorld__SearchVobListByClass = MEMINT_SwitchG1G2(6249792, 6439504);
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
    const int waypointNamePtr = 0; waypointNamePtr = _@s(wpname);
    if (CALL_Begin(call))
    {
        CALL__fastcall (_@(MEM_World.wayNet), _@(waypointNamePtr), MEMINT_SwitchG1G2(7366448, 8061744));
        call = CALL_End();  
    };
    return CALL_RetValAsInt();
};

func void Ninja_MaxXPHelper_ProjectCameraToPx(var int zVEC3ptrvar, var int xfPtr, var int yfPtr) {
    const int call = 0;
    const int _thisPtr = 0; _thisPtr = _@(MEM_Camera);
    if (CALL_Begin(call))
    {
        
        CALL_IntParam(_@(yfPtr));
        CALL_IntParam(_@(xfPtr));
        CALL_IntParam(_@(zVEC3ptrvar));
        CALL__thiscall(_@(_thisPtr), MEMINT_SwitchG1G2(5363696, 5439536));
        call = CALL_End();  
    };
};
