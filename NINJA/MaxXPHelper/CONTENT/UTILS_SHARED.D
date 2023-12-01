func void Ninja_MaxXPHelper_LogInfo(var string message) {
    MEM_Info(ConcatStrings("MaxXPHelper: " , message));
};


func int Ninja_MaxXPHelper_ShouldRunHook() {
    return !(
        !Hlp_IsValidNpc(hero) ||
        Npc_IsDead(hero) ||
        MEM_Game.pause_screen ||
        Timer_IsPaused()
    );
};

func int Ninja_MaxXPHelper_EndsWith(var string str, var string suffix) {
    if STR_Len(str) < STR_Len(suffix) { return FALSE; };
    return STR_Compare(
        STR_SubStr(str, STR_Len(str) - STR_Len(suffix), STR_Len(suffix)),
        suffix
    ) == STR_EQUAL;
};

func int Ninja_MaxXPHelper_IsNpcSpawned(var oCNPC npc) {
    return (
        // 256 is partial zCVob_bitfield0_castDynShadow flag; found by experimenting, seems to work in G1
        // if NPC was never spawned it's 0, if it was ever active, it's 1 (persists with saves too)
        GOTHIC_BASE_VERSION == 1 && (npc._zCVob_bitfield[0] & 256) ||
        (
            (npc._zCVob_bitfield[0] & 256) && 
            // partial of sleeping mode flag?
            (npc._zCVob_bitfield[2] & 1)
        )
    );
};

func int _Ninja_MaxXPHelper_zCListSort_Cycle(var int zCListSort_currentPtr_Ptr, var int zCListSort_rootPtr) {
    const int ptr = 0; ptr = MEM_ReadInt(zCListSort_currentPtr_Ptr);
    if !ptr {
        MEM_WriteInt(zCListSort_currentPtr_Ptr, zCListSort_rootPtr);
    };
    const int listPtr = 0; listPtr = ptr;
    var zCListSort list;
    if !listPtr {
        return 0;
    };
    list = _^ (listPtr);
    listPtr = list.next;
    MEM_WriteInt(zCListSort_currentPtr_Ptr, listPtr);
    return list.data;
};

func int Ninja_MaxXPHelper_CanNpcSpawn(var oCNPC npc) {
    return npc.bitfield[0] & oCNpc_bitfield0_spawnInRange;        
};

func string Ninja_MaxXPHelper_GetInstanceName(var oCNPC npc) {
    const int symbolPtr = 0; symbolPtr = MEM_GetSymbolByIndex(Hlp_GetInstanceID(npc));
    if !symbolPtr {
        return "";
    };
    var zCPar_Symbol symbol; symbol = _^(symbolPtr);
    return symbol.name;
};

// Don't want handles from Hashtables to be persisted in Save Game file so
// workarounding that by calling Lego "private" hashtable API working on pointers
func int Ninja_MaxXPHelper_HT_Create() {
    return _HT_Create();
};

func int Ninja_MaxXPHelper_HT_Get(var int ptr, var int key) {
    return _HT_Get(ptr, key);
};

func void Ninja_MaxXPHelper_HT_Insert(var int ptr, var int value, var int key) {
    _HT_Insert(ptr, value, key);
};

func void Ninja_MaxXPHelper_HT_Remove(var int ptr, var int key) {
    _HT_Remove(ptr, key);
};

func void Ninja_MaxXPHelper_HT_ForEach(var int ptr, var func onEachFunc) {
    _HT_ForEach(ptr, onEachFunc);
};

func void Ninja_MaxXPHelper_HT_Destroy(var int htPtr) {
    if !htPtr { return; };
    _HT_Destroy(htPtr);
};

func int Ninja_MaxXPHelper_HT_Has(var int htPtr, var int key) {
    return _HT_Has(htPtr, key);
};

func void Ninja_MaxXPHelper_HT_InsertOrChange(var int ptr, var int key, var int value) {
    _HT_InsertOrChange(ptr, value, key);
};

func void Ninja_MaxXPHelper_HT_ClearAndCreate(var int htPtr, var int foreachFuncPtrMaybe) {
    if !htPtr { return; };
    const int ptr = 0; ptr = MEM_ReadInt(htPtr);
    if ptr {
        if foreachFuncPtrMaybe {
            //Ninja_MaxXPHelper_HT_ForEach(htPtr, foreachFuncPtrMaybe);
        };
        Ninja_MaxXPHelper_HT_Destroy(ptr);
    };
    MEM_WriteInt(htPtr, Ninja_MaxXPHelper_HT_Create());
};