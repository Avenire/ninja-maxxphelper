
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


func void Ninja_MaxXPHelper_ProjectCameraToPx(var int zVEC3ptrvar, var int xfPtr, var int yfPtr) {
    const int call = 0;
    var int _thisPtr; _thisPtr = _@(MEM_Camera);
    if (CALL_Begin(call))
    {
        
        CALL_IntParam(_@(yfPtr));
        CALL_IntParam(_@(xfPtr));
        CALL_IntParam(_@(zVEC3ptrvar));
        CALL__thiscall(_@(_thisPtr), MEMINT_SwitchG1G2(5363696, 5439536));
        call = CALL_End();  
    };
};

const int _Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx_Result[4] = {0,0,0,0};
func int _Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx(
    var int xfcenter, 
    var int yfcenter, var int zfcenter, var int sideSize, var int minSideSize
) {
    // Given center point (xfcenter,yfcenter,zfcenter) in world's coordinate system (vobs/wp trafo positions) and desired sideSize size
    // sets _Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx_Result where:
    // idx 0: xfcenter screen pixel coord
    // idx 1: yfcenter screen pixel coord
    // idx 2: sideSize size scaled by zfcenter
    // idx 3: camera relative z for depth buffer (todo)
    // if point is in front of the camera (visible) and return TRUE, otherwise FALSE.
    // Below is reversed engineered center transformation algorithm found inlined in
    // zTBSphere3D::Draw, not sure if there's an engine call I could use, this seems to work fine.
    // Pretty much all ints here should be interpreted as 32bit floats.
    var int halfside; halfside = mulf(sideSize, FLOATHALF);
    var int xCamera; xCamera = addf(
        addf(
            mulf(MEM_Camera.camMatrix[0], xfcenter),
            mulf(MEM_Camera.camMatrix[1], yfcenter)
        ),
        addf(
            mulf(MEM_Camera.camMatrix[2], zfcenter),
            MEM_Camera.camMatrix[3]
        )
    );
    var int yCamera; yCamera = addf(
        addf(
            mulf(MEM_Camera.camMatrix[5], yfcenter),
            mulf(MEM_Camera.camMatrix[4], xfcenter)
        ),
        addf(
            mulf(MEM_Camera.camMatrix[6], zfcenter),
            MEM_Camera.camMatrix[7]
        )
    );
    var int zCamera; zCamera = addf(
        addf(
            mulf(MEM_Camera.camMatrix[9], yfcenter),
            mulf(MEM_Camera.camMatrix[8], xfcenter)
        ),
        addf(
            mulf(MEM_Camera.camMatrix[10], zfcenter),
            MEM_Camera.camMatrix[11]
        )
    );
    // Skip if not in front of the camera
    if !gf(zCamera, FLOATNULL) {
        return FALSE;
    };
    _Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx_Result[0] = xCamera;
    _Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx_Result[1] = yCamera;
    _Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx_Result[2] = zCamera;
    _Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx_Result[3] = zCamera;

    const int cameraTranslatedAtX[3] = {0,0,0};
    cameraTranslatedAtX[0] = addf(halfside, xCamera);
    cameraTranslatedAtX[1] = yCamera;
    cameraTranslatedAtX[2] = zCamera;
    
    const int cameraTranslatedAtY[3] = {0,0,0};
    cameraTranslatedAtY[0] = xCamera;
    cameraTranslatedAtY[1] = addf(halfside, yCamera);
    cameraTranslatedAtY[2] = zCamera;
    
    // Honestly I'm not sure if I interpreted below 2 variables correctly but hey, it works!
    var int lookAtCameraOffsetX; lookAtCameraOffsetX = subf(
        addf(
            mulf(
                divf(
                    FLOATONE, 
                    cameraTranslatedAtX[2]
                ), 
                mulf(
                    cameraTranslatedAtX[0], 
                    MEM_Camera.viewDistanceX
                )
            ),
            MEM_Camera.xcenter
        ),
        addf(
            mulf(
                xCamera,
                mulf(
                    MEM_Camera.viewDistanceX,
                    divf(
                        FLOATONE,
                        zCamera
                    )
                )
            ),
            MEM_Camera.xcenter
        )
    );
    var int lookAtCameraOffsetY; lookAtCameraOffsetY = subf(
        subf(
            MEM_Camera.ycenter, 
            mulf(
                divf(FLOATONE, cameraTranslatedAtY[2]),
                mulf(
                    cameraTranslatedAtY[1],
                    MEM_Camera.viewDistanceY
                )
            )
        ),
        subf(
            MEM_Camera.ycenter, 
            mulf(
                divf(FLOATONE, zCamera),
                mulf(
                    yCamera,
                    MEM_Camera.viewDistanceY
                )
            )
        )
    );
    var int px; var int py;
    Ninja_MaxXPHelper_ProjectCameraToPx(
        _@(_Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx_Result), 
        _@(px), 
        _@(py)
    );

    var int sideSizeShift; sideSizeShift = lookAtCameraOffsetY;
    if gf(lookAtCameraOffsetX, sideSizeShift) {
        sideSizeShift = lookAtCameraOffsetX;        
    };
    if gf(minSideSize, sideSizeShift) {
        sideSizeShift = minSideSize;
    };
    _Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx_Result[0] = px;
    _Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx_Result[1] = py;
    _Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx_Result[2] = sideSizeShift;
    return TRUE;
};