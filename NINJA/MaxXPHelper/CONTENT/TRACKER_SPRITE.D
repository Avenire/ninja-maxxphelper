class Ninja_MaxXPHelper_TrackerSprite {
    const int texture = 0;
    const int buffer = 0;
};
instance Ninja_MaxXPHelper_TrackerSprite@(Ninja_MaxXPHelper_TrackerSprite) {
    buffer = 0;
    texture = 0;
};

func void Ninja_MaxXPHelper_TrackerSprite_Delete(var Ninja_MaxXPHelper_TrackerSprite this) {
    if this.buffer {
        MEM_ArrayFree(this.buffer);
        this.buffer = 0;
        this.texture = 0; // todo: should release texture?
    };
};

func void _Ninja_MaxXPHelper_Trackers_UpdateVertex(
    var int verticesPtr, 
    var int vertexIdx, 
    var int xf, 
    var int yf,
    var int zf,
    var int color
) {
    const int resPtr = 0; resPtr = verticesPtr + vertexIdx * sizeof_zTRndSimpleVertex;
    MEM_WriteInt(resPtr, xf);
    MEM_WriteInt(resPtr + 4, yf);
    MEM_WriteInt(resPtr + 8, zf);
    MEM_WriteInt(resPtr + 20, color);
};

const int _Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx_Result[4] = {0,0,0,0};
func int _Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx(
    var int xfcenter, 
    var int yfcenter, var int zfcenter, 
    var int sideSize, 
    var int minSideSize,
    var int zBufferBias
) {
    const int EPSILON = 0;
    if EPSILON == 0 {
        EPSILON = 925353388; // should be around 0.00001 if interpreted as float
    };
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

    const int halfside = 0; halfside = mulf(sideSize, FLOATHALF);
    const int xCamera = 0; xCamera = addf(
        addf(
            mulf(MEM_Camera.trafoView[0], xfcenter),
            mulf(MEM_Camera.trafoView[1], yfcenter)
        ),
        addf(
            mulf(MEM_Camera.trafoView[2], zfcenter),
            MEM_Camera.trafoView[3]
        )
    );
    const int yCamera = 0; yCamera = addf(
        addf(
            mulf(MEM_Camera.trafoView[5], yfcenter),
            mulf(MEM_Camera.trafoView[4], xfcenter)
        ),
        addf(
            mulf(MEM_Camera.trafoView[6], zfcenter),
            MEM_Camera.trafoView[7]
        )
    );
    const int zCamera = 0; zCamera = addf(
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
    const int depthValue = 0; depthValue = addf(
        divf(MEM_Camera.farClipZ, addf(subf(MEM_Camera.farClipZ, MEM_Camera.nearClipZ), EPSILON)),
        divf(
            divf(
                negf(mulf(MEM_Camera.farClipZ, MEM_Camera.nearClipZ)),
                addf(subf(MEM_Camera.farClipZ, MEM_Camera.nearClipZ), EPSILON)
            ),
            addf(subf(zCamera, zBufferBias), EPSILON)
        )
    );
    if GOTHIC_BASE_VERSION == 2 {
        // For some reason Gothic 2 NotR does things bit differently.
        // First it does a reciprocate of passed Z in DrawPolySimple and that goes to DirectX.
        // Reciprocate means far values end up being close to 0, near values to 1.
        // Hence I do 1 - depthValue and then take a reciprocate of that to adapt the value for DrawPolySimple there.
        depthValue = divf(FLOATONE, addf(subf(FLOATONE, depthValue), EPSILON));
    };
    _Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx_Result[3] = depthValue;
    
    const int xCameraTranslatedByHalfSideInPerspective = 0; 
    xCameraTranslatedByHalfSideInPerspective = subf(
        addf(
            mulf(
                divf(
                    FLOATONE, 
                    addf(zCamera, EPSILON)
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
                        addf(zCamera, EPSILON)
                    )
                )
            ),
            MEM_Camera.xcenter
        )
    );
    const int yCameraTranslatedByHalfSideInPerspective = 0; 
    yCameraTranslatedByHalfSideInPerspective = subf(
        subf(
            MEM_Camera.ycenter, 
            mulf(
                divf(FLOATONE, addf(zCamera, EPSILON)),
                mulf(
                    addf(halfside, yCamera),
                    addf(MEM_Camera.viewDistanceY, EPSILON)
                )
            )
        ),
        subf(
            MEM_Camera.ycenter, 
            mulf(
                divf(FLOATONE, addf(zCamera, EPSILON)),
                mulf(
                    yCamera,
                    MEM_Camera.viewDistanceY
                )
            )
        )
    );
    const int px = 0; const int py = 0;
    Ninja_MaxXPHelper_ProjectCameraToPx(
        _@(_Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx_Result), 
        _@(px), 
        _@(py)
    );

    const int sideSizeShift = 0; sideSizeShift = yCameraTranslatedByHalfSideInPerspective;
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

func int _Ninja_MaxXPHelper_TrackerSprite_UpdateSprite(
    var int verticesPtr, var int xfcenter, var int yfcenter, var int zfcenter, var int color, var int iconSize,
    var int zBufferBias
) {
    const int px = 0; const int py = 0;
    if !_Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx(
        xfcenter, 
        yfcenter, 
        zfcenter, 
        iconSize, 
        mkf(10),
        zBufferBias
    ) {
        return FALSE;
    };
    const int px = 0; px = _Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx_Result[0];
    const int py = 0; py = _Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx_Result[1];
    const int wh = 0; wh = _Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx_Result[2];
    if gf(wh, iconSize) {
        wh = iconSize;
    };
    const int nwh = 0; nwh = negf(wh);
    const int d = 0; d = FLOATONE;
    const int depthValue = 0; depthValue = _Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx_Result[3];
    _Ninja_MaxXPHelper_Trackers_UpdateVertex(verticesPtr, 0, addf(px, nwh), addf(py, nwh), depthValue, color);
    _Ninja_MaxXPHelper_Trackers_UpdateVertex(verticesPtr, 1, addf(px, wh), addf(py, nwh), depthValue, color);
    _Ninja_MaxXPHelper_Trackers_UpdateVertex(verticesPtr, 2, addf(px, wh), addf(py, wh), depthValue, color);
    _Ninja_MaxXPHelper_Trackers_UpdateVertex(verticesPtr, 3, addf(px, nwh), addf(py, wh), depthValue, color);
    return TRUE;
};

func void Ninja_MaxXPHelper_TrackerSprite_Draw(
    var Ninja_MaxXPHelper_TrackerSprite this,
    var int xfcenter, var int yfcenter, var int zfcenter, var int color, var int iconSize,
    var int zBufferBias
) {
    if this.buffer && this.texture {
        const int verticesPtr = 0; verticesPtr = MEM_ReadInt(this.buffer);
        if !Ninja_MaxXPHelper_IsPointAhead(xfcenter, yfcenter, zfcenter) { return; };
        if _Ninja_MaxXPHelper_TrackerSprite_UpdateSprite(
            verticesPtr, 
            xfcenter, 
            yfcenter, 
            zfcenter,
            color,
            iconSize,
            zBufferBias
        ) {
            zRND_D3D_DrawPolySimple(this.texture, verticesPtr, 4);
        };
    };
};

func int Ninja_MaxXPHelper_TrackerSprite_Create(var string textureName) {
    var Ninja_MaxXPHelper_TrackerSprite trackerSprite; trackerSprite = _^(create(Ninja_MaxXPHelper_TrackerSprite@));
    trackerSprite.texture = zCTexture_Load(textureName);

    trackerSprite.buffer = MEM_ArrayCreate();
    var zCArray arr; arr = _^(trackerSprite.buffer);
    arr.numInArray = sizeof_zTRndSimpleVertex;
    arr.numAlloc = sizeof_zTRndSimpleVertex;
    arr.array = MEM_Alloc(4 * sizeof_zTRndSimpleVertex);
    const int off = 0; off = MEM_ReadInt(trackerSprite.buffer);
    MEM_WriteInt(off + 12, FLOATNULL);
    MEM_WriteInt(off + 16, FLOATNULL);
    off += sizeof_zTRndSimpleVertex;
    MEM_WriteInt(off + 12, FLOATONE);
    MEM_WriteInt(off + 16, FLOATNULL);
    off += sizeof_zTRndSimpleVertex;
    MEM_WriteInt(off + 12, FLOATONE);
    MEM_WriteInt(off + 16, FLOATONE);
    off += sizeof_zTRndSimpleVertex;
    MEM_WriteInt(off + 12, FLOATNULL);
    MEM_WriteInt(off + 16, FLOATONE);

    return _@(trackerSprite);
};