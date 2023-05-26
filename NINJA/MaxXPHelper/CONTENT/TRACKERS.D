const int _Ninja_MaxXPHelper_Trackers_MaxBuckets = 100;
const int _Ninja_MaxXPHelper_Trackers_BucketsArray = 0;
const int _Ninja_MaxXPHelper_Trackers_MaxRenderedBuckets = 5;
const int _Ninja_MaxXPHelper_Trackers_NextID = 1;
const int _Ninja_MaxXPHelper_Trackers_Handles = 0;
const int Ninja_MaxXPHelper_Trackers_MaxPriority = 0;
const int _Ninja_MaxXPHelper_Trackers_FrameTime = 0;
const int Ninja_MaxXPHelper_Trackers_zBufferEnabled = 0;

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
    var int size;
    var int autoExpireAt;
};

instance _Ninja_MaxXPHelper_Tracker@(_Ninja_MaxXPHelper_Tracker) {
    priority = _Ninja_MaxXPHelper_Trackers_MaxBuckets - 1;
    next = 0;
    prev = 0;
    textureName = "";
    trackerSprite = 0;
};

func void _Ninja_MaxXPHelper_Tracker_Delete(var _Ninja_MaxXPHelper_Tracker this) {
    // _Ninja_MaxXPHelper_Tracker_Delete destructor
    free(this.trackerSprite, Ninja_MaxXPHelper_TrackerSprite@);
};

const int Ninja_MaxXPHelper_Trackers_DistancePriority_Result[2] = {0,0};
func void Ninja_MaxXPHelper_Trackers_GetNpcToHeroDistanceBasedPriority(var oCNPC npc) {
    var int dist;
    var c_npc cnpc; cnpc = _^(_@(npc));
    if Ninja_MaxXPHelper_IsNpcSpawned(npc) {
        dist = mkf(Npc_GetDistToNpc(hero, cnpc));
    } else {
        dist = mkf(Npc_GetDistToWP(hero, npc.wpname));
    };
    Ninja_MaxXPHelper_Trackers_DistancePriority_Result[1] = roundf (divf(dist, mkf(2000))) + 1;
    Ninja_MaxXPHelper_Trackers_DistancePriority_Result[0] = dist;
};

func void Ninja_MaxXPHelper_Trackers_Release(var int trackerId) {
    var int trackerPtr; trackerPtr = HT_Get(_Ninja_MaxXPHelper_Trackers_Handles, trackerId);
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
    HT_Remove(_Ninja_MaxXPHelper_Trackers_Handles, trackerId);
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
        tracker.size
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
    HT_ForEach(
        _Ninja_MaxXPHelper_Trackers_Handles, 
        _Ninja_MaxXPHelper_Trackers_SearchAndDestroy_FindHandle
    );
    Ninja_MaxXPHelper_Trackers_Release(_Ninja_MaxXPHelper_Trackers_SearchAndDestroy_TrackerHandle);
};

func void _Ninja_MaxXPHelper_Trackers_Hook() {
    if  !Hlp_IsValidNpc(hero) ||
        MEM_Game.pause_screen ||
        Timer_IsPaused() {
        return;
    };
    if MEM_KeyState(KEY_G) == KEY_PRESSED {
        Ninja_MaxXPHelper_Trackers_zBufferEnabled = !Ninja_MaxXPHelper_Trackers_zBufferEnabled;
        var string msg; msg = Ninja_MaxXPHelper_LOC_TrackersRespectDepthBufferOn;
        if !Ninja_MaxXPHelper_Trackers_zBufferEnabled {
            msg = Ninja_MaxXPHelper_LOC_TrackersRespectDepthBufferOFF;
        };
        Ninja_MaxXPHelper_TextAlerts_Create(
            msg, 
            Ninja_MaxXPHelper_SystemAlertDuration, 
            RGBA(50, 255, 50, 0),
            TRUE
        );
    };
    var int bucketsRendered; bucketsRendered = 0;
    var int zrendererPtr; zrendererPtr = MEM_ReadInt(zrenderer_adr);
    zRND_D3D_SetAlphaBlendFunc(zRND_ALPHA_FUNC_BLEND);
    if Ninja_MaxXPHelper_Trackers_zBufferEnabled {
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
    var int maxBucketsToRender; maxBucketsToRender = _Ninja_MaxXPHelper_Trackers_MaxRenderedBuckets;
    if Ninja_MaxXPHelper_Trackers_zBufferEnabled {
        maxBucketsToRender = 1; // If depth buffer is on then attempt to render only high priority (usually nearby) trackers.
    };
    repeat(i, _Ninja_MaxXPHelper_Trackers_MaxBuckets - 2); var int i;
        if bucketsRendered >= _Ninja_MaxXPHelper_Trackers_MaxRenderedBuckets { break; };
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
        } else {
            continue;
        };
    end;
    if Ninja_MaxXPHelper_Trackers_zBufferEnabled {
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
        HT_ForEach(
            _Ninja_MaxXPHelper_Trackers_Handles, 
            _Ninja_MaxXPHelper_Trackers_InitHandles_Free
        );
        HT_Destroy(_Ninja_MaxXPHelper_Trackers_Handles);
    };
    _Ninja_MaxXPHelper_Trackers_Handles = HT_Create();
};

func void Ninja_MaxXPHelper_Trackers_Init() {
    _Ninja_MaxXPHelper_Trackers_NextID = 1;
    _Ninja_MaxXPHelper_Trackers_InitBuckets();
    _Ninja_MaxXPHelper_Trackers_InitHandles();
    const int once = 0;
    if !once {
        HookEngineF(zRND_D3D__EndFrame, 6, _Ninja_MaxXPHelper_Trackers_Hook);
        once = 1;
    };
};

func int Ninja_MaxXPHelper_Trackers_Create() {
    var int trackerPtr; trackerPtr = create(_Ninja_MaxXPHelper_Tracker@);
    HT_Insert(_Ninja_MaxXPHelper_Trackers_Handles, trackerPtr, _Ninja_MaxXPHelper_Trackers_NextID);
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
    var int trackerPtr; trackerPtr = HT_Get(_Ninja_MaxXPHelper_Trackers_Handles, trackerId);
    if !trackerPtr { return; };
    var _Ninja_MaxXPHelper_Tracker tracker; tracker = _^(trackerPtr);
    tracker.autoExpireAt = TimerGT() + durationInMillis;
};

func void Ninja_MaxXPHelper_Trackers_Hide(var int trackerId, var int keepPriority) {
    var int trackerPtr; trackerPtr = HT_Get(_Ninja_MaxXPHelper_Trackers_Handles, trackerId);
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
    var string textureName,
    var int size
) {
    var int trackerPtr; trackerPtr = HT_Get(_Ninja_MaxXPHelper_Trackers_Handles, trackerId);
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
    tracker.size = size;
    tracker.skip = FALSE;
};
