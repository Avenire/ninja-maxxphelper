const int _Ninja_MaxXPHelper_Trackers_MaxBuckets = 100;
const int _Ninja_MaxXPHelper_Trackers_BucketsArray = 0;
const int _Ninja_MaxXPHelper_Trackers_NextID = 1;
const int _Ninja_MaxXPHelper_Trackers_Handles = 0;
const int Ninja_MaxXPHelper_Trackers_MaxPriority = 0;
const int _Ninja_MaxXPHelper_Trackers_FrameTime = 0;
const int _Ninja_MaxXPHelper_Trackers_MaxRenderingLevelEnabled = 0;

class _Ninja_MaxXPHelper_Tracker {
    var int xfcenter;
    var int yfcenter;
    var int zfcenter;
    var string textureName;
    var int trackerSprite;
    var int color;
    var int priority;
    var int next;
    var int prev;
    var int skip;
    var int autoExpireAt;
    var int zBufferBias;
};

instance _Ninja_MaxXPHelper_Tracker@(_Ninja_MaxXPHelper_Tracker) {
    priority = _Ninja_MaxXPHelper_Trackers_MaxBuckets - 1;
    next = 0;
    prev = 0;
    textureName = "";
    trackerSprite = 0;
};

func void _Ninja_MaxXPHelper_Tracker_Delete(var _Ninja_MaxXPHelper_Tracker this) {
    free(this.trackerSprite, Ninja_MaxXPHelper_TrackerSprite@);
};

const int Ninja_MaxXPHelper_Trackers_DistancePriority_Result[2] = {0,0};
func void Ninja_MaxXPHelper_Trackers_GetHeroDistanceBasedPriority(var int xf, var int yf, var int zf) {
    var oCNPC heroNpc; heroNpc = Hlp_GetNpc(hero);
    var int x; x = heroNpc._zCVob_trafoObjToWorld[zCVob_trafoObjToWorld_X];
    var int y; y = heroNpc._zCVob_trafoObjToWorld[zCVob_trafoObjToWorld_Y];
    var int z; z = heroNpc._zCVob_trafoObjToWorld[zCVob_trafoObjToWorld_Z];
    var int dx; dx = subf(x, xf);
    var int dy; dy = subf(y, yf);
    var int dz; dz = subf(z, zf);
    var int dist; dist = sqrtf(
        addf(
            mulf(dx, dx),
            addf(
                mulf(dy, dy),
                mulf(dz, dz)
            )
        )
    );
    Ninja_MaxXPHelper_Trackers_DistancePriority_Result[1] = roundf (divf(dist, mkf(2000))) + 1;
    Ninja_MaxXPHelper_Trackers_DistancePriority_Result[0] = dist;
};

func void Ninja_MaxXPHelper_Trackers_Release(var int trackerId) {
    var int trackerPtr; trackerPtr = Ninja_MaxXPHelper_HT_Get(_Ninja_MaxXPHelper_Trackers_Handles, trackerId);
    if !trackerPtr { return; };
    var _Ninja_MaxXPHelper_Tracker tracker; tracker = _^(trackerPtr);
    if trackerPtr == MEM_ReadIntArray(_Ninja_MaxXPHelper_Trackers_BucketsArray, tracker.priority) {
        MEM_WriteIntArray(_Ninja_MaxXPHelper_Trackers_BucketsArray, tracker.priority, tracker.next);
    };
    if tracker.next {
        var _Ninja_MaxXPHelper_Tracker next; next = _^(tracker.next);
        next.prev = tracker.prev;
    };
    if tracker.prev {
        var _Ninja_MaxXPHelper_Tracker prev; prev = _^(tracker.prev);
        prev.next = tracker.next;
    };
    free(trackerPtr, _Ninja_MaxXPHelper_Tracker@);
    Ninja_MaxXPHelper_HT_Remove(_Ninja_MaxXPHelper_Trackers_Handles, trackerId);
};

func void _Ninja_MaxXPHelper_Trackers_Draw(var _Ninja_MaxXPHelper_Tracker tracker) {
    if (tracker.skip || !tracker.trackerSprite) {
        return;
    };
    var Ninja_MaxXPHelper_TrackerSprite ts; ts = _^(tracker.trackerSprite);
    Ninja_MaxXPHelper_TrackerSprite_Draw(
        ts,
        tracker.xfcenter,
        tracker.yfcenter,
        tracker.zfcenter,
        tracker.color,
        Ninja_MaxXPHelper_IconSize,
        tracker.zBufferBias
    );
};

const int _Ninja_MaxXPHelper_Trackers_SearchAndDestroy_TrackerHandle = -1;
const int _Ninja_MaxXPHelper_Trackers_SearchAndDestroy_TrackerPtr = -1;
func void _Ninja_MaxXPHelper_Trackers_SearchAndDestroy_FindHandle(var int trackerHandle, var int trackerPtr) {
    if _Ninja_MaxXPHelper_Trackers_SearchAndDestroy_TrackerHandle < 0 &&
        _Ninja_MaxXPHelper_Trackers_SearchAndDestroy_TrackerPtr == trackerPtr {
        _Ninja_MaxXPHelper_Trackers_SearchAndDestroy_TrackerHandle = trackerHandle;
    };
};
func void _Ninja_MaxXPHelper_Trackers_SearchAndDestroy(var int trackerPtr) {
    _Ninja_MaxXPHelper_Trackers_SearchAndDestroy_TrackerHandle = -1;
    _Ninja_MaxXPHelper_Trackers_SearchAndDestroy_TrackerPtr = trackerPtr;
    Ninja_MaxXPHelper_HT_ForEach(
        _Ninja_MaxXPHelper_Trackers_Handles, 
        _Ninja_MaxXPHelper_Trackers_SearchAndDestroy_FindHandle
    );
    Ninja_MaxXPHelper_Trackers_Release(_Ninja_MaxXPHelper_Trackers_SearchAndDestroy_TrackerHandle);
};

func void _Ninja_MaxXPHelper_Trackers_HandleToggleUseZBuffer() {
    if MEM_KeyState(Ninja_MaxXPHelper_ToggleTrackersUseZBufferKeyCode) == KEY_PRESSED {
        Ninja_MaxXPHelper_TrackersUseZBuffer = !Ninja_MaxXPHelper_TrackersUseZBuffer;
        Ninja_MaxXPHelper_SetIntOpt(Ninja_MaxXPHelper_TrackersUseZBuffer_OptKey, Ninja_MaxXPHelper_TrackersUseZBuffer);
        var string msg; msg = Ninja_MaxXPHelper_LOC_TrackersUseZBufferOn;
        if !Ninja_MaxXPHelper_TrackersUseZBuffer {
            msg = Ninja_MaxXPHelper_LOC_TrackersUseZBufferOff;
        };
        Ninja_MaxXPHelper_TextAlerts_Create(
            msg, 
            Ninja_MaxXPHelper_SystemAlertDurationInMillis, 
            Ninja_MaxXPHelper_SystemNotificationsColor,
            TRUE
        );
    };
};

func void _Ninja_MaxXPHelper_Trackers_HandleToggleMaxRenderingLevel() {
    if MEM_KeyState(Ninja_MaxXPHelper_ToggleTrackersMaxRenderingLevelKeyCode) == KEY_PRESSED {
        _Ninja_MaxXPHelper_Trackers_MaxRenderingLevelEnabled = !_Ninja_MaxXPHelper_Trackers_MaxRenderingLevelEnabled;
        var string msg; msg = Ninja_MaxXPHelper_LOC_TrackersMaxRenderingEnabledOn;
        if !_Ninja_MaxXPHelper_Trackers_MaxRenderingLevelEnabled {
            msg = Ninja_MaxXPHelper_LOC_TrackersMaxRenderingEnabledOff;
        };
        Ninja_MaxXPHelper_TextAlerts_Create(
            msg, 
            Ninja_MaxXPHelper_SystemAlertDurationInMillis, 
            Ninja_MaxXPHelper_SystemNotificationsColor,
            TRUE
        );
    };
};

func void _Ninja_MaxXPHelper_Trackers_Hook() {
    if !Ninja_MaxXPHelper_ShouldRunHook() {
        return;
    };
    // Encountered a bug where, when starting new game after game was already loaded (new game/loaded save)
    // game randomly stops rendering trackers (zCamera is negative so it early exited). After inspecting camera coords
    // when the bug was ocurring, it seemed like wrong transformation matrix is used (all X,Y,Z values are totally off)
    // and it could be due to the wrong camera used. Since I set the camera here I cannot reproduce the bug anymore.
    MEM_Camera = _^(MEM_Game._zCSession_camera);

    _Ninja_MaxXPHelper_Trackers_HandleToggleUseZBuffer();
    _Ninja_MaxXPHelper_Trackers_HandleToggleMaxRenderingLevel();

    var int bucketsRendered; bucketsRendered = 0;
    var int zrendererPtr; zrendererPtr = MEM_ReadInt(zrenderer_adr);
    zRND_D3D_SetAlphaBlendFunc(zRND_ALPHA_FUNC_BLEND);
    if Ninja_MaxXPHelper_TrackersUseZBuffer {
        zRND_XD3D_SetRenderState(D3DRS_ZENABLE, true);
        // Magic (explained). All of this is done to make my (potentially) transparent tracker sprites behave with depthbuffer on.
        // DrawPolySimple is stubborn and disables D3DRS_ALPHATESTENABLE if local state indicates it's set (xd3d_actRenderState[zRND_XD3D_D3DRS_ALPHATESTENABLE_OFFSET] != 0).
        // So I am forced to trick renderer into thinking it's disabled while it actually isn't.
        zRND_XD3D_SetRenderState(Ninja_MaxXPHelper_D3DRENDERSTATE_D3DRS_ALPHATESTENABLE, true);
        MEM_WriteInt(zrendererPtr + zRND_XD3D_D3DRS_ALPHATESTENABLE_OFFSET, 0);
        // I only am concerned about fully transparent background of sprites 
        // and game's defaults are much more aggresive (like slightly less than 200 alpha is already filtered out). 
        zRND_XD3D_SetRenderState(Ninja_MaxXPHelper_D3DRENDERSTATE_D3DRS_ALPHAREF, 1);
    } else {
        zRND_XD3D_SetRenderState(D3DRS_ZENABLE, false);
    };

    var int rendered; rendered = 0;
    _Ninja_MaxXPHelper_Trackers_FrameTime = TimerGT();
    var int maxBucketsToRender; maxBucketsToRender = Ninja_MaxXPHelper_TrackersRenderingLevel;
    repeat(i, _Ninja_MaxXPHelper_Trackers_MaxBuckets - 2); var int i;
        var int bucketRoot; bucketRoot = MEM_ReadIntArray(_Ninja_MaxXPHelper_Trackers_BucketsArray, i);
        if bucketRoot {
            while (bucketRoot);
                var _Ninja_MaxXPHelper_Tracker curr; curr = _^(bucketRoot);
                bucketRoot = curr.next;
                if curr.autoExpireAt && curr.autoExpireAt < _Ninja_MaxXPHelper_Trackers_FrameTime {
                    _Ninja_MaxXPHelper_Trackers_SearchAndDestroy(_@(curr));
                    continue;
                };
                _Ninja_MaxXPHelper_Trackers_Draw(curr);
                rendered = rendered + 1;
            end;
            bucketsRendered = bucketsRendered + 1;
        };
        // Checking it here so max priority bucket always gets a chance to render.
        if !_Ninja_MaxXPHelper_Trackers_MaxRenderingLevelEnabled && 
            bucketsRendered >= Ninja_MaxXPHelper_TrackersRenderingLevel { break; };
    end;
    if Ninja_MaxXPHelper_TrackersUseZBuffer {
        // I saw 0xb0 (184) somewhere in G1 assembly so I just naively set that here (could use the actual "on function entered" value but meh).
        zRND_XD3D_SetRenderState(Ninja_MaxXPHelper_D3DRENDERSTATE_D3DRS_ALPHAREF, 184);
        // Reverse the hack.
        MEM_WriteInt(zrendererPtr + zRND_XD3D_D3DRS_ALPHATESTENABLE_OFFSET, 1);
        zRND_XD3D_SetRenderState(15, false);
    } else {
        zRND_XD3D_SetRenderState(D3DRS_ZENABLE, true);
    };
};

func void _Ninja_MaxXPHelper_Trackers_InitBuckets() {
    if _Ninja_MaxXPHelper_Trackers_BucketsArray {
        MEM_Free(_Ninja_MaxXPHelper_Trackers_BucketsArray);
    };
    _Ninja_MaxXPHelper_Trackers_BucketsArray = MEM_Alloc(4 * _Ninja_MaxXPHelper_Trackers_MaxBuckets);
        repeat(i, _Ninja_MaxXPHelper_Trackers_MaxBuckets - 1); var int i;
        MEM_WriteIntArray(_Ninja_MaxXPHelper_Trackers_BucketsArray, i, 0);
    end;
};

func void _Ninja_MaxXPHelper_Trackers_InitHandles_Free(var int trackerId, var int trackerPtr) {
    var _Ninja_MaxXPHelper_Tracker tracker; tracker = _^(trackerPtr);
    free(trackerPtr, _Ninja_MaxXPHelper_Tracker@);
};
func void _Ninja_MaxXPHelper_Trackers_InitHandles() {
    if _Ninja_MaxXPHelper_Trackers_Handles {
        Ninja_MaxXPHelper_HT_ForEach(
            _Ninja_MaxXPHelper_Trackers_Handles, 
            _Ninja_MaxXPHelper_Trackers_InitHandles_Free
        );
        Ninja_MaxXPHelper_HT_Destroy(_Ninja_MaxXPHelper_Trackers_Handles);
    };
    _Ninja_MaxXPHelper_Trackers_Handles = Ninja_MaxXPHelper_HT_Create();
};
const int Ninja_MaxXPHelper_Trackers_Init_Once = 0;
func void Ninja_MaxXPHelper_Trackers_Init() {
    _Ninja_MaxXPHelper_Trackers_NextID = 1;
    _Ninja_MaxXPHelper_Trackers_InitBuckets();
    _Ninja_MaxXPHelper_Trackers_InitHandles();
    if !Ninja_MaxXPHelper_Trackers_Init_Once {
        // Hook before focus labels are drawn as their presence makes trackers wiggle as camera rotates.
        // In fact, focus labels wiggle themselves but why this gets applied to sprites... Could be it sets
        // something weird with DX Device?
        // todo: Riddle - understand wth does drawing of focus label do that causes this issue...
        HookEngineF(oCGame_UpdatePlayerStatus, 6, _Ninja_MaxXPHelper_Trackers_Hook);
        Ninja_MaxXPHelper_Trackers_Init_Once = 1;
    };
};

func int Ninja_MaxXPHelper_Trackers_Create() {
    var int trackerPtr; trackerPtr = create(_Ninja_MaxXPHelper_Tracker@);
    Ninja_MaxXPHelper_HT_Insert(_Ninja_MaxXPHelper_Trackers_Handles, trackerPtr, _Ninja_MaxXPHelper_Trackers_NextID);
    var int rootPtr; rootPtr = MEM_ReadIntArray(_Ninja_MaxXPHelper_Trackers_BucketsArray, _Ninja_MaxXPHelper_Trackers_MaxBuckets - 1);
    if rootPtr {
        var _Ninja_MaxXPHelper_Tracker oldRootTracker; oldRootTracker = _^(rootPtr);
        var _Ninja_MaxXPHelper_Tracker newRootTracker; newRootTracker = _^(trackerPtr);
        oldRootTracker.prev = trackerPtr;
        newRootTracker.next = rootPtr;
    };
    MEM_WriteIntArray(_Ninja_MaxXPHelper_Trackers_BucketsArray, _Ninja_MaxXPHelper_Trackers_MaxBuckets - 1, trackerPtr);
    _Ninja_MaxXPHelper_Trackers_NextID = _Ninja_MaxXPHelper_Trackers_NextID + 1;
    return _Ninja_MaxXPHelper_Trackers_NextID - 1;
};

func void _Ninja_MaxXPHelper_Trackers_MoveBucket(var _Ninja_MaxXPHelper_Tracker tracker, var int newBucketIdx) {
    var int newBucketRootPtr; newBucketRootPtr = MEM_ReadIntArray(_Ninja_MaxXPHelper_Trackers_BucketsArray, newBucketIdx);
    var int oldBucketRootPtr; oldBucketRootPtr = MEM_ReadIntArray(_Ninja_MaxXPHelper_Trackers_BucketsArray, tracker.priority);
    var int trackerPtr; trackerPtr = _@(tracker);
    if tracker.priority == newBucketIdx {
        return;
    };
    // Moving tracker to priority bucket sets it as new root of that new bucket. 
    if oldBucketRootPtr == trackerPtr {
        MEM_WriteIntArray(_Ninja_MaxXPHelper_Trackers_BucketsArray, tracker.priority, tracker.next);
    };
    if tracker.prev {
        var _Ninja_MaxXPHelper_Tracker prevNode; prevNode = _^(tracker.prev);
        prevNode.next = tracker.next;
    };
    if tracker.next {
        var _Ninja_MaxXPHelper_Tracker nextNode; nextNode = _^(tracker.next);
        nextNode.prev = tracker.prev;
    };
    if newBucketRootPtr {
        var _Ninja_MaxXPHelper_Tracker oldRoot; oldRoot = _^(newBucketRootPtr);
        tracker.next = _@(oldRoot);
        oldRoot.prev = trackerPtr;
    } else {
        tracker.next = 0;
    };
    tracker.prev = 0;
    MEM_WriteIntArray(_Ninja_MaxXPHelper_Trackers_BucketsArray, newBucketIdx, trackerPtr);
};

func void Ninja_MaxXPHelper_Trackers_SetAutoExpire(var int trackerId, var int durationInMillis) {
    var int trackerPtr; trackerPtr = Ninja_MaxXPHelper_HT_Get(_Ninja_MaxXPHelper_Trackers_Handles, trackerId);
    if !trackerPtr { return; };
    var _Ninja_MaxXPHelper_Tracker tracker; tracker = _^(trackerPtr);
    tracker.autoExpireAt = TimerGT() + durationInMillis;
};

func void Ninja_MaxXPHelper_Trackers_SetZBufferBias(var int trackerId, var int zBufferBias) {
    var int trackerPtr; trackerPtr = Ninja_MaxXPHelper_HT_Get(_Ninja_MaxXPHelper_Trackers_Handles, trackerId);
    if !trackerPtr { return; };
    var _Ninja_MaxXPHelper_Tracker tracker; tracker = _^(trackerPtr);
    tracker.zBufferBias = zBufferBias;
};

func void Ninja_MaxXPHelper_Trackers_Hide(var int trackerId, var int keepPriority) {
    var int trackerPtr; trackerPtr = Ninja_MaxXPHelper_HT_Get(_Ninja_MaxXPHelper_Trackers_Handles, trackerId);
    if !trackerPtr { return; };
    var _Ninja_MaxXPHelper_Tracker tracker; tracker = _^(trackerPtr);
    tracker.skip = TRUE;
    if !keepPriority {
        var int priority; priority = _Ninja_MaxXPHelper_Trackers_MaxBuckets - 1;
        _Ninja_MaxXPHelper_Trackers_MoveBucket(tracker, priority);
        tracker.priority = priority;
    };
};

func void Ninja_MaxXPHelper_Trackers_Show(
    var int trackerId,
    var int xfcenter, 
    var int yfcenter, 
    var int zfcenter, 
    var int color, 
    var int priority,
    var string textureName
) {
    var int trackerPtr; trackerPtr = Ninja_MaxXPHelper_HT_Get(_Ninja_MaxXPHelper_Trackers_Handles, trackerId);
    if !trackerPtr { return; };
    var _Ninja_MaxXPHelper_Tracker tracker; tracker = _^(trackerPtr);
    if priority < 0 {
        priority = Ninja_MaxXPHelper_Trackers_MaxPriority;
    } else if priority >= _Ninja_MaxXPHelper_Trackers_MaxBuckets - 1 {
        priority = _Ninja_MaxXPHelper_Trackers_MaxBuckets - 2;
    };

    _Ninja_MaxXPHelper_Trackers_MoveBucket(tracker, priority);
    tracker.priority = priority;
    if !tracker.trackerSprite || 
        STR_Compare(tracker.textureName, textureName) != STR_EQUAL {        
        free(tracker.trackerSprite, Ninja_MaxXPHelper_TrackerSprite@);
        tracker.textureName = textureName;
        tracker.trackerSprite = Ninja_MaxXPHelper_TrackerSprite_Create(tracker.textureName);
    };

    tracker.xfcenter = xfcenter;
    tracker.yfcenter = yfcenter;
    tracker.zfcenter = zfcenter;
    tracker.color = color;
    tracker.skip = FALSE;
};
