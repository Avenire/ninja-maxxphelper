func void Ninja_MaxXPHelper_LogInfo(var string message) {
    MEM_Info(ConcatStrings("MaxXPHelper: " , message));
};

func void Ninja_MaxXPHelper_LogError(var string message) {
    MEM_Error(ConcatStrings("MaxXPHelper: " , message));
};


func int Ninja_MaxXPHelper_ShouldRunHook() {
    if !Hlp_IsValidNpc(hero) { return FALSE; };
    if Npc_IsDead(hero) { return FALSE; };
    if MEM_Game.pause_screen { return FALSE; };
    if Timer_IsPaused() { return FALSE; };
    return TRUE;
};

func int Ninja_MaxXPHelper_EndsWith(var string str, var string suffix) {
    if STR_Len(str) < STR_Len(suffix) { return FALSE; };
    return STR_Compare(
        STR_SubStr(str, STR_Len(str) - STR_Len(suffix), STR_Len(suffix)),
        suffix
    ) == STR_EQUAL;
};

func int Ninja_MaxXPHelper_IsNpcSpawned(var oCNPC npc) {
    var zCVob vob; vob = _^(_@(npc));
    return vob.globalVobTreeNode > 0;
};

const int _Ninja_MaxXPHelper_zCListSort_Cycle_LastCallWrite = 0;

func int _Ninja_MaxXPHelper_zCListSort_Cycle(var int zCListSort_currentPtr_Ptr, var int zCListSort_rootPtr) {
    if !zCListSort_currentPtr_Ptr {
        return 0;
    };
    const int ptr = 0; ptr = MEM_ReadInt(zCListSort_currentPtr_Ptr);
    if !ptr {
        MEM_WriteInt(zCListSort_currentPtr_Ptr, zCListSort_rootPtr);
        _Ninja_MaxXPHelper_zCListSort_Cycle_LastCallWrite = TRUE;
    } else {
        _Ninja_MaxXPHelper_zCListSort_Cycle_LastCallWrite = FALSE;
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

func void Ninja_MaxXPHelper_HT_Remove(var int ptr, var int key) {
    _HT_Remove(ptr, key);
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

func void _Ninja_MaxXPHelper_oCNpcInventory_UnpackCategory (var int npcInventoryPtr, var int invCategory) {
	//0x00670740 public: void __thiscall oCNpcInventory::UnpackItemsInCategory(int)
	//0x00710A20 public: void __thiscall oCNpcInventory::UnpackItemsInCategory(void)

	//0x0066FAD0 public: void __thiscall oCNpcInventory::UnpackCategory(int)
	const int oCNpcInventory__UnpackCategory_G1 = 6748880;

	//0x0070F620 public: void __thiscall oCNpcInventory::UnpackCategory(void)
	const int oCNpcInventory__UnpackCategory_G2 = 7403040;

	if (!npcInventoryPtr) { return; };

	const int call = 0;
	if (CALL_Begin(call)) {
		if (MEMINT_SwitchG1G2 (1, 0)) {
			CALL_IntParam (_@ (invCategory));
		};
		CALL__thiscall (_@ (npcInventoryPtr), MEMINT_SwitchG1G2 (oCNpcInventory__UnpackCategory_G1, oCNpcInventory__UnpackCategory_G2));
		call = CALL_End();
	};
};

// Below taken from https://github.com/Bad-Scientists/AF-Script-Packet/blob/main/inventory_oCNpc.d (and slightly adjusted)
func int _Ninja_MaxXPHelper_Npc_GetNpcInventoryPtr (var int slfInstance) {
	var oCNpc slf; slf = Hlp_GetNPC (slfInstance);
	if (!Hlp_IsValidNPC (slf)) { return 0; };

	const int npcInventoryPtr = 0; npcInventoryPtr = _@ (slf.inventory2_vtbl);
	return + npcInventoryPtr;
};

func void Ninja_MaxXPHelper_NPC_InventoryPrint (var int slfInstance) {
	var oCNpc slf; slf = Hlp_GetNPC (slfInstance);
	if !Hlp_IsValidNPC(slf) { return; };

	const int npcInventoryPtr = 0; npcInventoryPtr = _Ninja_MaxXPHelper_Npc_GetNpcInventoryPtr (slf);

	var oCItem itm;
	var zCListSort list;

	const int noOfCategories = 0;
	const int offset = 0;
	const int ptr = 0;

	//G1/G2A compatibility --> we cannot use inventory2_inventory1_next / inventory2_inventory_next properties, but instead we have to read from inventory offsets
	if (GOTHIC_BASE_VERSION == 1) {
		offset = 1528;						// 0x05F8 zCListSort<oCItem>*
		noOfCategories = INV_CAT_MAX;
	} else {
		offset = 1816;						// 0x0718 zCListSort<oCItem>*
		noOfCategories = 1;
	};

	repeat (invCat, noOfCategories); var int invCat;
		_Ninja_MaxXPHelper_oCNpcInventory_UnpackCategory (npcInventoryPtr, invCat);
		ptr = MEM_ReadInt (_@ (slf) + offset + (12 * invCat));
		while (ptr);
			list = _^ (ptr);
			if (list.data) {
				itm = _^ (list.data);
                PrintS_Ext(itm.name, COL_WHITE);
			};
			ptr = list.next;
		end;
	end;
};