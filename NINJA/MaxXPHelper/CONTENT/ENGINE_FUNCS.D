
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
    var int yfcenter, var int zfcenter, 
    var int sideSize, 
    var int minSideSize,
    var int zBufferBias
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
            mulf(MEM_Camera.trafoView[0], xfcenter),
            mulf(MEM_Camera.trafoView[1], yfcenter)
        ),
        addf(
            mulf(MEM_Camera.trafoView[2], zfcenter),
            MEM_Camera.trafoView[3]
        )
    );
    var int yCamera; yCamera = addf(
        addf(
            mulf(MEM_Camera.trafoView[5], yfcenter),
            mulf(MEM_Camera.trafoView[4], xfcenter)
        ),
        addf(
            mulf(MEM_Camera.trafoView[6], zfcenter),
            MEM_Camera.trafoView[7]
        )
    );
    var int zCamera; zCamera = addf(
        addf(
            mulf(MEM_Camera.trafoView[9], yfcenter),
            mulf(MEM_Camera.trafoView[8], xfcenter)
        ),
        addf(
            mulf(MEM_Camera.trafoView[10], zfcenter),
            MEM_Camera.trafoView[11]
        )
    );

    // Skip if not in front of the camera
    if !gf(zCamera, FLOATNULL) {
        return FALSE;
    };
    _Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx_Result[0] = xCamera;
    _Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx_Result[1] = yCamera;
    _Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx_Result[2] = zCamera;
    
    // Formula straight from wiki (Fixed-point representation, simplied). Works well so far.
    // https://en.wikipedia.org/wiki/Z-buffering
    // Values gets normalized to [0,1]
    var int depthValue; depthValue = addf(
        divf(MEM_Camera.farClipZ, subf(MEM_Camera.farClipZ, MEM_Camera.nearClipZ)),
        divf(
            divf(
                negf(mulf(MEM_Camera.farClipZ, MEM_Camera.nearClipZ)),
                subf(MEM_Camera.farClipZ, MEM_Camera.nearClipZ)
            ),
            subf(zCamera, zBufferBias)
        )
    );
    if GOTHIC_BASE_VERSION > 1 {
        // For some reason Gothic 2 NotR does things bit differently.
        // First it does a reciprocate of passed Z in DrawPolySimple and that goes to DirectX.
        // Reciprocate means far values end up being close to 0, near values to 1.
        // Hence I do 1 - depthValue and then take a reciprocate of that to adapt the value for DrawPolySimple there.
        depthValue = divf(FLOATONE, subf(FLOATONE, depthValue));
    };
    _Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx_Result[3] = depthValue;
    
    var int xCameraTranslatedByHalfSideInPerspective; 
    xCameraTranslatedByHalfSideInPerspective = subf(
        addf(
            mulf(
                divf(
                    FLOATONE, 
                    zCamera
                ), 
                mulf(
                    addf(halfside, xCamera), 
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
    var int yCameraTranslatedByHalfSideInPerspective; 
    yCameraTranslatedByHalfSideInPerspective = subf(
        subf(
            MEM_Camera.ycenter, 
            mulf(
                divf(FLOATONE, zCamera),
                mulf(
                    addf(halfside, yCamera),
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

    var int sideSizeShift; sideSizeShift = yCameraTranslatedByHalfSideInPerspective;
    if gf(xCameraTranslatedByHalfSideInPerspective, sideSizeShift) {
        sideSizeShift = xCameraTranslatedByHalfSideInPerspective;        
    };
    if gf(minSideSize, sideSizeShift) {
        sideSizeShift = minSideSize;
    };
    _Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx_Result[0] = px;
    _Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx_Result[1] = py;
    _Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx_Result[2] = sideSizeShift;
    return TRUE;
};

func void zRND_D3D_SetAlphaBlendFuncImmed(var int zTRnd_AlphaBlendFunc) {
    const int ptr = 0;
    ptr = zTRnd_AlphaBlendFunc;
    
    const int call = 0;
    if(CALL_Begin(call)) {
        CALL_IntParam(_@(ptr));
        CALL__thiscall(zrenderer_adr, MEMINT_SwitchG1G2(7439120, 6620880));

        call = CALL_End();
    };
};


func void zRND_D3D_SetAlphaBlendFuncImmed(var int zTRnd_AlphaBlendFunc) {
    const int ptr = 0;
    ptr = zTRnd_AlphaBlendFunc;
    
    const int call = 0;
    if(CALL_Begin(call)) {
        CALL_IntParam(_@(ptr));
        CALL__thiscall(zrenderer_adr, MEMINT_SwitchG1G2(7439120, 6620880));

        call = CALL_End();
    };
};
