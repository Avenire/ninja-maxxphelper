class Ninja_MaxXPHelper_TrackerSprite {
    var int texture;
    var int buffer;
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
    var int resPtr; resPtr = verticesPtr + vertexIdx * sizeof_zTRndSimpleVertex;
    MEM_WriteInt(resPtr, xf);
    MEM_WriteInt(resPtr + 4, yf);
    MEM_WriteInt(resPtr + 8, zf);
    MEM_WriteInt(resPtr + 20, color);
};

func int _Ninja_MaxXPHelper_TrackerSprite_UpdateSprite(
    var int verticesPtr, var int xfcenter, var int yfcenter, var int zfcenter, var int color, var int iconSize
) {
    var int px; var int py;
    if !_Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx(
        xfcenter, 
        yfcenter, 
        zfcenter, 
        iconSize, 
        Ninja_MaxXPHelper_MinIconSize
    ) {
        return FALSE;
    };
    var int px; px = _Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx_Result[0];
    var int py; py = _Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx_Result[1];
    var int wh; wh = _Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx_Result[2];
    if gf(wh, iconSize) {
        wh = iconSize;
    };
    var int nwh; nwh = negf(wh);
    var int d; d = FLOATONE;
    var int depthValue; depthValue = _Ninja_MaxXPHelper_Trackers_ProjectWorldToScreenPx_Result[3];
    _Ninja_MaxXPHelper_Trackers_UpdateVertex(verticesPtr, 0, addf(px, nwh), addf(py, nwh), depthValue, color);
    _Ninja_MaxXPHelper_Trackers_UpdateVertex(verticesPtr, 1, addf(px, wh), addf(py, nwh), depthValue, color);
    _Ninja_MaxXPHelper_Trackers_UpdateVertex(verticesPtr, 2, addf(px, wh), addf(py, wh), depthValue, color);
    _Ninja_MaxXPHelper_Trackers_UpdateVertex(verticesPtr, 3, addf(px, nwh), addf(py, wh), depthValue, color);
    return TRUE;
};

func void Ninja_MaxXPHelper_TrackerSprite_Draw(
    var Ninja_MaxXPHelper_TrackerSprite this,
    var int xfcenter, var int yfcenter, var int zfcenter, var int color, var int iconSize
) {
    const int once = 0;
    if !once {
        Ninja_MaxXPHelper_LogInfo(IntToString(zrenderer_adr));
        Ninja_MaxXPHelper_LogInfo(IntToString(MEM_ReadInt(zrenderer_adr)));
        Ninja_MaxXPHelper_LogInfo(ConcatStrings("buffer level? ", IntToString(MEM_ReadInt(MEM_ReadInt(zrenderer_adr) +  MEMINT_SwitchG1G2(2356, 2364) ))));
        once = 1;
    };
    if this.buffer && this.texture {
        var int verticesPtr; verticesPtr = MEM_ReadInt(this.buffer);
        if _Ninja_MaxXPHelper_TrackerSprite_UpdateSprite(
            verticesPtr, 
            xfcenter, 
            yfcenter, 
            zfcenter,
            color,
            iconSize
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
    var int off; off = MEM_ReadInt(trackerSprite.buffer);
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