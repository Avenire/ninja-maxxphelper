const int Ninja_MaxXPHelper_WarningAlerts_ItemSpawnHT_Handle = 0;
const int Ninja_MaxXPHelper_WarningAlerts_LostPickpocketHT_Handle = 0;
const int Ninja_MaxXPHelper_WarningAlerts_RequiredInfoHT_Handle = 0;
const int Ninja_MaxXPHelper_WarningAlerts_ChapterOptimalInfoHT_Handle = 0;
const int _Ninja_MaxXPHelper_Last_B_GiveXP_XP = 0;
const int _Ninja_MaxXPHelper_InXPWatchdog = FALSE;

var int _Ninja_MaxXPHelper_XPLogID;

class Ninja_MaxXPHelper_Entry {
    var string argument;
};
instance Ninja_MaxXPHelper_Entry@(Ninja_MaxXPHelper_Entry) {
};
// WTF
// why is func id B_CreateAmbientInv 0
// why is const int MEMINT_DoStackPopPosOffset = MEMINT_DoStackFrameSize + MEMINT_DoStackFrameSize - 6 * 4; defined as such
// why is this happening on level change and apparently create instance
// log memint esp before hitting the breakpoint
func void _Ninja_MaxXPHelper_B_CreateAmbientInv_Hook(var C_NPC slf) {
    Ninja_MaxXPHelper_LogInfo(ConcatStrings("Enter _Ninja_MaxXPHelper_B_CreateAmbientInv_Hook ", slf.name));
    if (!_@(MEM_Game)) || (!_@(MEM_StackPos)) {
        Ninja_MaxXPHelper_LogInfo(
            "Called during level change, init..."
        );    
        MEM_InitLabels();
        MEM_InitGlobalInst();
    };
    PassArgumentN(slf);
    ContinueCall();
    if !Ninja_MaxXPHelper_ShouldRunHook() {
        return;
    };
    const int ht = 0; ht = Ninja_MaxXPHelper_WarningAlerts_ItemSpawnHT_Handle;
    const int instanceId = 0; instanceId = Hlp_GetInstanceID(slf);
    if !ht { return; };
    if !Ninja_MaxXPHelper_HT_Has(ht, instanceId) { return; };
    const int itemId = 0; itemId = Ninja_MaxXPHelper_HT_Get(ht, instanceId);
    if itemId < 0 { return; };
    var oCNpc onpc; onpc = _^(_@(slf));
    Ninja_MaxXPHelper_LogInfo(ConcatStrings("testing item on ", onpc.name));
    if Npc_HasItems(slf, itemId) <= 0 {
        // todo: if opted in
        Ninja_MaxXPHelper_NPC_InventoryPrint(instanceId);
        const int symbolPtr = 0; symbolPtr = MEM_GetSymbolByIndex(itemId);
        var zCPar_Symbol symbol; symbol = _^(symbolPtr);
        const int s = 0; s = SB_New();
        SB(slf.name);
        SB(" spawned without required item "); 
        SB(symbol.name);
        Ninja_MaxXPHelper_TextAlerts_Create(
            SB_ToString(),  
            Ninja_MaxXPHelper_DeathAlertTextDurationInMillis, 
            Ninja_MaxXPHelper_PickpocketAlertsWarningColor, 
            FALSE
        );
        Ninja_MaxXPHelper_LogError(SB_ToString());
        SB_Clear();
        SB_Destroy();
    };
};

func void _Ninja_MaxXPHelper_WarningAlerts_Handler_REQUIRED_ITEM_SPAWN() {
    const string npcCode = ""; npcCode = STRINT_SplitGet(1);
    const string itemCode = ""; itemCode = STRINT_SplitGet(2);
    const int npcId = 0; npcId = MEM_GetSymbolIndex(npcCode);
    const int itemId = 0; itemId = MEM_GetSymbolIndex(itemCode);
    var C_NPC npc; npc = Hlp_GetNpc(npcId);
    Ninja_MaxXPHelper_HT_InsertOrChange(
        Ninja_MaxXPHelper_WarningAlerts_ItemSpawnHT_Handle,
        npcId,
        itemId
    );  
};

func void _Ninja_MaxXPHelper_WarningAlerts_Handler_PICKPOCKET_LOST_OnChoice() {
    const string onChoiceFunctionCode = ""; onChoiceFunctionCode = STRINT_SplitGet(1);
    const string npcsCodes = ""; npcsCodes = STRINT_SplitGet(2);
    const int onChoice = 0; onChoice = MEM_GetSymbolIndex(onChoiceFunctionCode);
    if onChoice > 0 {
        const int handle = 0; handle = create(Ninja_MaxXPHelper_Entry@);
        var Ninja_MaxXPHelper_Entry entry; entry = _^(handle);
        entry.argument = npcsCodes;
        Ninja_MaxXPHelper_HT_InsertOrChange(
            Ninja_MaxXPHelper_WarningAlerts_LostPickpocketHT_Handle,
            onChoice,
            handle
        );
    };
};

func void _Ninja_MaxXPHelper_WarningAlerts_Handler_CHAPTER_OPTIMAL_INFO() {
    const string instanceName = ""; instanceName = STRINT_SplitGet(1);
    const int instanceId = 0; instanceId = MEM_GetSymbolIndex(instanceName);
    if instanceId < 0 { return; };
    if _Ninja_MaxXPHelper_debug {
        const int s = 0; s = SB_New();
        SB(" instance="); 
        SB(instanceName);
        SB(" id="); 
        SB(IntToString(instanceId));
        SB(" chapter="); 
        SB(STRINT_SplitGet(2));
        Ninja_MaxXPHelper_LogInfo(SB_ToString());  
        SB_Clear();
        SB_Destroy();
    };
    const int handle = 0; handle = create(Ninja_MaxXPHelper_Entry@);
    var Ninja_MaxXPHelper_Entry entry; entry = _^(handle);
    entry.argument = STRINT_SplitGet(2);
    Ninja_MaxXPHelper_HT_InsertOrChange(
        Ninja_MaxXPHelper_WarningAlerts_ChapterOptimalInfoHT_Handle,
        instanceId,
        handle
    );
};

func void _Ninja_MaxXPHelper_WarningAlerts_ChapterOptimalInfo(var int choiceOrInfoId) {
    const int ht = 0; ht = Ninja_MaxXPHelper_WarningAlerts_ChapterOptimalInfoHT_Handle;
    const int instanceId = 0; instanceId = choiceOrInfoId;
    const int symbolPtr = 0; symbolPtr = MEM_GetSymbolByIndex(instanceId);
    if _Ninja_MaxXPHelper_debug {
        const int s = 0; s = SB_New();
        SB(" _Ninja_MaxXPHelper_WarningAlerts_OnChoice_ChapterOptimalInfo checking"); 
        SB(" instanceId="); 
        SB(IntToString(instanceId)); 
        Ninja_MaxXPHelper_LogInfo(SB_ToString());  
        SB_Clear();
        SB_Destroy();
    };
    var zCPar_Symbol symbol; symbol = _^(symbolPtr);
    if !Ninja_MaxXPHelper_HT_Has(ht, instanceId) { return; };
    var Ninja_MaxXPHelper_Entry entry; entry = get(
        Ninja_MaxXPHelper_HT_Get(ht, instanceId)
    );
    if _Ninja_MaxXPHelper_debug {
        const int s = 0; s = SB_New();
        SB(" instance="); 
        SB(symbol.name);
        SB(" id="); 
        SB(IntToString(instanceId));
        SB(" chapter="); 
        SB(entry.argument);
        Ninja_MaxXPHelper_LogInfo(SB_ToString());  
        SB_Clear();
        SB_Destroy();
    };
    const int chapter = 0; chapter = STR_ToInt(entry.argument);
    if Kapitel >= chapter { return; }; // todo: on next chapter, check if any dialogs were missed (won't work for choices) tho?
    const int s = 0; s = SB_New();
    SB(symbol.name);
    SB(" info should be taken in chapter "); 
    SB(IntToString(chapter));
    Ninja_MaxXPHelper_TextAlerts_Create(
        SB_ToString(),  
        Ninja_MaxXPHelper_DeathAlertTextDurationInMillis, 
        Ninja_MaxXPHelper_PickpocketAlertsWarningColor, 
        FALSE
    );  
    SB_Clear();
    SB_Destroy();
};

func void _Ninja_MaxXPHelper_WarningAlerts_Handler_REQUIRED_INFO_BEFORE_DEAD() {
    const string npcCode = ""; npcCode = STRINT_SplitGet(1);
    const string infosCodes = ""; infosCodes = STRINT_SplitGet(2);
    const int npcId = 0; npcId = MEM_GetSymbolIndex(npcCode);
    var C_NPC npc; npc = Hlp_GetNpc(npcId);
    if Hlp_IsValidNpc(npc) {
        const int handle = 0; handle = create(Ninja_MaxXPHelper_Entry@);
        var Ninja_MaxXPHelper_Entry entry; entry = _^(handle);
        entry.argument = infosCodes;
        Ninja_MaxXPHelper_HT_InsertOrChange(
            Ninja_MaxXPHelper_WarningAlerts_RequiredInfoHT_Handle,
            npcId,
            handle
        );
    };
};

func void _Ninja_MaxXPHelper_WarningAlerts_ParseConfig() {
    Ninja_MaxXPHelper_HT_ClearAndCreate(_@(Ninja_MaxXPHelper_WarningAlerts_ItemSpawnHT_Handle), 0);
    Ninja_MaxXPHelper_HT_ClearAndCreate(_@(Ninja_MaxXPHelper_WarningAlerts_LostPickpocketHT_Handle), 0);
    Ninja_MaxXPHelper_HT_ClearAndCreate(_@(Ninja_MaxXPHelper_WarningAlerts_RequiredInfoHT_Handle), 0);
    Ninja_MaxXPHelper_HT_ClearAndCreate(_@(Ninja_MaxXPHelper_WarningAlerts_ChapterOptimalInfoHT_Handle), 0);
       
    const int streamPtr = 0; streamPtr = Ninja_MaxXPHelper_OpenFileStreamForReading(Ninja_MaxXPHelper_WarningAlerts_WarningsConfigFilePath);
    
    if streamPtr {
        const int gotoLabel = 0; gotoLabel = MEM_StackPos.position;
        if !Ninja_MaxXPHelper_EOF(streamPtr) {  
            STRINT_SplitReset();
            const string line = ""; line = Ninja_MaxXPHelper_TextLine(streamPtr);
            const int count = 0; count = STR_SplitCount(line, ";");
            Ninja_MaxXPHelper_LogInfo(line);
            if count > 0 {
                const string type = ""; type = STRINT_SplitGet(0);
                const int handler = 0; handler = MEM_GetSymbolIndex(ConcatStrings("_Ninja_MaxXPHelper_WarningAlerts_Handler_", type));
                if handler < 0 { continue; };
                MEM_CallByID(handler);
            };
            MEM_StackPos.position = gotoLabel;
        };
        Ninja_MaxXPHelper_CloseFileStream(streamPtr);
    };
};

const int _Ninja_MaxXPHelper_fileHandle = 0;
func int _Ninja_MaxXPHelper_WIN_WriteFile(
    var int hFile,
    var int lpBuffer,
    var int nNumberOfBytesToWrite,
    var int lpNumberOfBytesWritten,
    var int lpOverlapped) {
    const int call = 0;
    if(CALL_Begin(call)) {
        CALL_IntParam(_@(lpOverlapped));
        CALL_IntParam(_@(lpNumberOfBytesWritten));
        CALL_IntParam(_@(nNumberOfBytesToWrite));
        CALL_IntParam(_@(lpBuffer));
        CALL_IntParam(_@(hFile));
        CALL__stdcall(WriteFile);
        call = CALL_End();
    };
    return CALL_RetValAsInt();
};
func int _Ninja_MaxXPHelper_WIN_CopyFile(
    var string sourceFilename,
    var string targetFilename
) {
    const int call = 0;
    const int addr = 0;
    var zString lpExistingFileNameStr; lpExistingFileNameStr = MEM_PtrToInst(_@s(sourceFilename));
    var zString lpNewFileNameStr; lpNewFileNameStr = MEM_PtrToInst(_@s(targetFilename));
    const int bFailIfExists = 0;
    if !addr {
        addr = FindKernelDllFunction("CopyFileA");
    };
    if(CALL_Begin(call)) {
        CALL_IntParam(_@(bFailIfExists));
        CALL_PtrParam(_@(lpNewFileNameStr.ptr));
        CALL_PtrParam(_@(lpExistingFileNameStr.ptr));
        CALL__stdcall(addr);
        call = CALL_End();
    };
    return CALL_RetValAsInt();
};

func int _Ninja_MaxXPHelper_WIN_GetLastError() {
    const int call = 0;
    const int addr = 0;
    if !addr {
        addr = FindKernelDllFunction("GetLastError");
    };
    if(CALL_Begin(call)) {
        CALL__stdcall(addr);
        call = CALL_End();
    };
    return CALL_RetValAsInt();
};
const string _Ninja_MaxXPHelper_LastRelevantFunc = "";

func void _Ninja_MaxXPHelper_LogXPToCSV(var int add_xp, var string context, var C_NPC _self) {
    const int ESP = 0;
    ESP = MEMINT_FindFrameBoundary(MEMINT_GetESP(), -1);
    ESP += MEMINT_DoStackFrameSize; 
    const int passedMySelf = 0; passedMySelf = 0;
    const int mySelf = 0; mySelf = MEM_GetFuncID(_Ninja_MaxXPHelper_LogXPToCSV);
    const string lastRelevantFunc = ""; lastRelevantFunc = "";
    const string firstRelevantFunc = ""; firstRelevantFunc = "";
    const int loop = 0; loop = MEM_StackPos.position; 
    const int popPos = 0;
    popPos = MEM_ReadInt(ESP-MEMINT_DoStackPopPosOffset);
    const int continueCallId = 0;
    if !continueCallId {
        continueCallId = MEM_GetFuncID(ContinueCall);
    };
    if (passedMySelf) {
            const int valid = 0;
        if (popPos < 0 || popPos >= MEM_Parser.stack_stacksize) {
            valid = false;
        } else {
            valid = true;
            const int funcID = 0; var zCPar_Symbol symb;
            funcID = MEM_GetFuncIDByOffset(popPos);
            symb   = _^(MEM_ReadIntArray(contentSymbolTableAddress, funcID));
        };
        if valid  {
            if !IsHookD(funcID) && funcID != continueCallId {
                lastRelevantFunc = symb.name;
                if STR_Compare(firstRelevantFunc, "") == STR_Equal {
                    firstRelevantFunc = symb.name;
                };
            };
        } else {
        };
    } else if (popPos < MEM_Parser.stack_stacksize) {
        const int funcID = 0;
        funcID = MEM_GetFuncIDByOffset(popPos);
        passedMySelf = (funcID == mySelf);
    };
    if passedMySelf && valid && _Ninja_MaxXPHelper_debug {
        const int offset = 0; offset = MEM_ReadInt(ContentParserAddress + zCParser_stack_offset);
        //Ninja_MaxXPHelper_LogInfo(ConcatStrings("B_GivePlayerXP: looping over a valid symbol ", symb.name));
        //Ninja_MaxXPHelper_LogInfo(ConcatStrings("B_GivePlayerXP: symbol content ", IntToString(symb.content)));
        //Ninja_MaxXPHelper_LogInfo(ConcatStrings("B_GivePlayerXP: ", IntToString(MEM_ReadInt(offset + popPos - 5))));
        //Ninja_MaxXPHelper_LogInfo(ConcatStrings("B_GivePlayerXP: ", IntToString(popPos)));
    };
    if (MEMINT_IsFrameBoundary(ESP)) {
        ESP += MEMINT_DoStackFrameSize;
        MEM_StackPos.position = loop;
    };
    if STR_Compare(lastRelevantFunc, "") != STR_EQUAL {
        const int s = 0; s = SB_New();
        // Total amount
        SB("");
        SB(context);
        SB(";");
        SB(IntToString(add_xp));
        // Top, non-hooked Daedalus function whence Give XP call originated
        SB(";");
        if _Ninja_MaxXPHelper_InXPWatchdog {
            SB(_Ninja_MaxXPHelper_LastRelevantFunc);
        } else {
            SB(lastRelevantFunc);
            _Ninja_MaxXPHelper_LastRelevantFunc = lastRelevantFunc;
        };
        // self instance name (victim is set as "self" instance in the original, can also try lookup function params)
        SB(";");
        const int instId = 0; instId = Hlp_GetInstanceID(_self);
        var zCPar_Symbol instSymb; instSymb = _^(MEM_ReadIntArray(contentSymbolTableAddress, instId));
        SB(instSymb.name);
        // Currently loaded ZEN
        SB(";");
        SB(MEM_World.worldName);
        // Hero nearest wp (helps identify things like teleport XP)
        SB(";");
        SB(Npc_GetNearestWP(hero));
        // self wp
        var oCNPC _npc; _npc = _^(_@(_self));
        SB(";");
        SB(_npc.wpname);
        SB(";");
        SB(_npc.name);
        SB(";");
        SB(IntToString(Kapitel));
        SB(";");
        SB(firstRelevantFunc);
        SB(";");
        SB(IntToString(TimerGT()));
        SBc(13);
        SBc(10);
        
        const int lpNumberOfBytesWritten = 0;
        var string log; log = SB_ToString();
        const int err = 0; err = 0;
        if _Ninja_MaxXPHelper_fileHandle {
            var zString _zString; _zString = MEM_PtrToInst(_@s(log));
            err = _Ninja_MaxXPHelper_WIN_WriteFile(
                _Ninja_MaxXPHelper_fileHandle, _zString.ptr, _zString.len, _@(lpNumberOfBytesWritten), 0
            );
        };
        if !err {
            Ninja_MaxXPHelper_LogInfo(IntToString(_Ninja_MaxXPHelper_WIN_GetLastError()));
        };
        SB_Clear();
        SB_Destroy();        
    };
};


func void _Ninja_MaxXPHelper_B_GivePlayerXP_Hook(var int add_xp) {
    Ninja_MaxXPHelper_LogInfo("Enter _Ninja_MaxXPHelper_B_GivePlayerXP_Hook");
    _Ninja_MaxXPHelper_LogXPToCSV(add_xp, "B_GivePlayerXP called", self);
    _Ninja_MaxXPHelper_Last_B_GiveXP_XP = _Ninja_MaxXPHelper_Last_B_GiveXP_XP + add_xp;
    PassArgumentI(add_xp);
    ContinueCall();
};

const string _Ninja_MaxXPHelper_sessionFilepath = "";
var string _Ninja_MaxXPHelper_lastSaveFile;
const string _Ninja_MaxXPHelper_TMPLogFile = "Saves/currentsession_maxxphelper.log.tmp";
func void _Ninja_MaxXPHelper_OnSave() {
    // Below is taken from LeGo _BW_SaveGame implementation.
    const int slot = 0; slot = MEM_ReadInt(EBP+oCSavegameManager__SetAndWriteSavegame_bp_offset);
    const string saveFile = ""; saveFile = ConcatStrings("Saves/savegame", IntToString(slot)); //_BIN_GetSavefilePath(slot);
    _Ninja_MaxXPHelper_lastSaveFile = saveFile;
    _Ninja_MaxXPHelper_sessionFilepath = ConcatStrings(saveFile, "/maxxphelper.log");
    
    const string msg = ""; msg = ConcatStrings("[OnSave] copying TMP XP log, from = ", _Ninja_MaxXPHelper_TMPLogFile);
    msg = ConcatStrings(msg, " to = ");
    msg = ConcatStrings(msg, _Ninja_MaxXPHelper_sessionFilepath);
    Ninja_MaxXPHelper_LogInfo(msg);
    const int err = 0; err = _Ninja_MaxXPHelper_WIN_CopyFile(
        _Ninja_MaxXPHelper_TMPLogFile,
        _Ninja_MaxXPHelper_sessionFilepath
    );
    Ninja_MaxXPHelper_LogInfo(ConcatStrings("[OnSave] XP log file copied, status = ", IntToString(err)));
};

func int _Ninja_MaxXPHelper_WIN_CloseHandle(var int hObject) {
    const int call = 0;
    if(CALL_Begin(call)) {
        CALL_IntParam(_@(hObject));
        CALL__stdcall(CloseHandle);
        call = CALL_End();
    };
    return CALL_RetValAsInt();
};

var int Ninja_MaxXPHelper_LevelChanges;
func void _Ninja_MaxXPHelper_OnLoad() {
    var CGameManager man; man = _^(MEM_ReadInt(MEMINT_gameMan_Pointer_address));
    const int slot = 0; slot = MEM_ReadInt(man.menu_load_savegame + menu_savegame_slot_offset);
    const string saveFile = ""; 
    if slot == 0 {
        Ninja_MaxXPHelper_LogInfo("_Ninja_MaxXPHelper_OnLoad invalid savegame slot, ignoring...");
        return;
    } else {
        saveFile = ConcatStrings("Saves/savegame", IntToString(slot));
    };
    if Ninja_MaxXPHelper_LevelChanges == 0 {
        saveFile = ""; // New game, don't load anything
    };
    if _Ninja_MaxXPHelper_fileHandle {
        Ninja_MaxXPHelper_LogInfo(ConcatStrings("[OnLoad] Closing open file handle = ", IntToString(_Ninja_MaxXPHelper_fileHandle)));
        const int err = 0; err = _Ninja_MaxXPHelper_WIN_CloseHandle(_Ninja_MaxXPHelper_fileHandle);
        Ninja_MaxXPHelper_LogInfo(ConcatStrings("[OnLoad] Closing file handle returned ", IntToString(err)));
    };
    _Ninja_MaxXPHelper_sessionFilepath = ConcatStrings(saveFile, "/maxxphelper.log");
    Ninja_MaxXPHelper_LogInfo(ConcatStrings("[OnLoad] _Ninja_MaxXPHelper_sessionFilepath = ", _Ninja_MaxXPHelper_sessionFilepath));
    if STR_Compare(saveFile, "") != STR_EQUAL {
        // Try restoring save's log file. Ignore errors.
        const int copyRet = 0; copyRet = _Ninja_MaxXPHelper_WIN_CopyFile(
            _Ninja_MaxXPHelper_sessionFilepath,
            _Ninja_MaxXPHelper_TMPLogFile
        );
        Ninja_MaxXPHelper_LogInfo(ConcatStrings("[OnLoad] Copying existing XP log file, status = ", IntToString(copyRet)));
        if !copyRet {
            Ninja_MaxXPHelper_TextAlerts_Create(
                "Failed to initialize XP log file, please reload.",  
                Ninja_MaxXPHelper_DeathAlertTextDurationInMillis, 
                Ninja_MaxXPHelper_PickpocketAlertsWarningColor, 
                TRUE
            ); 
        };
    } else {
        Ninja_MaxXPHelper_LogInfo("[OnLoad] New game, not restoring XP log");
    };
    _Ninja_MaxXPHelper_fileHandle = WIN_CreateFile(
        _Ninja_MaxXPHelper_TMPLogFile, 
        4, // FILE_APPEND_DATA 
        FILE_SHARE_READ, 
        0, 
        4, // OPEN_ALWAYS 
        FILE_ATTRIBUTE_NORMAL | 67108864, // Delete on closing handle
        0
    );
    Ninja_MaxXPHelper_LogInfo(ConcatStrings("[OnLoad] Opened TMP file, handle = ", IntToString(_Ninja_MaxXPHelper_fileHandle)));
};



const int Ninja_MaxXPHelper_WarningAlerts_Init_Once = FALSE;

func void Ninja_MaxXPHelper_WarningAlerts_OnNPCDeath(var C_NPC npc) {
    const int instanceId = 0; instanceId = Hlp_GetInstanceID(npc);
    const int ht = 0; ht = Ninja_MaxXPHelper_WarningAlerts_RequiredInfoHT_Handle;
    if !Ninja_MaxXPHelper_HT_Has(ht, instanceId) { return; };
    STRINT_SplitReset();
    const int entryPtr = 0;
    entryPtr = Ninja_MaxXPHelper_HT_Get(ht, instanceId);
    var Ninja_MaxXPHelper_Entry entry; entry = _^(entryPtr);
    const int count = 0; count = STR_SplitCount(entry.argument, ",");
    repeat(i, count); const int i = 0;
        const string infoCode = ""; infoCode = STRINT_SplitGet(i);
        const int instanceId = 0; instanceId = MEM_GetSymbolIndex(infoCode);
        if instanceId < 0 { continue; };
        if Npc_KnowsInfo(hero, instanceId) { continue; };
        const int s = 0; s = SB_New();
        SB(npc.name);
        SB(" died but hero does not know required info "); 
        SB(infoCode);
        Ninja_MaxXPHelper_TextAlerts_Create(
            SB_ToString(),  
            Ninja_MaxXPHelper_DeathAlertTextDurationInMillis, 
            Ninja_MaxXPHelper_PickpocketAlertsWarningColor, 
            FALSE
        );  
        SB_Clear();
        SB_Destroy();
    end;
    if Ninja_MaxXPHelper_HT_Has(ht, instanceId) {
        Ninja_MaxXPHelper_HT_Remove(ht, instanceId);
    };
};


func void Ninja_MaxXPHelper_WarningAlerts_OnLostPickpocket(var C_NPC npc) {
    const int _VictimCount = 0; _VictimCount = VictimCount + 1;
    const int _VictimLevel = 0; _VictimLevel = VictimLevel;
    const int _ThiefLevel = 0; _ThiefLevel = ThiefLevel;
	if(_VictimLevel == 0)
	{
		_VictimLevel = 2;
	};
	if(_VictimCount >= _VictimLevel)
	{
		_ThiefLevel = _ThiefLevel + 1;
	};
    _Ninja_MaxXPHelper_LogXPToCSV(-(ThiefXP + (_ThiefLevel * 10)), ConcatStrings(npc.name, " pickpocket opportunity lost penalty"), npc);
};

func void _Ninja_MaxXPHelper_WarningAlerts_LostPickpocket(var int choiceOrInfoId) {
    const int ht = 0; ht = Ninja_MaxXPHelper_WarningAlerts_LostPickpocketHT_Handle;
    if Ninja_MaxXPHelper_HT_Has(ht, choiceOrInfoId) { return; };
    const int entryPtr = 0; entryPtr = Ninja_MaxXPHelper_HT_Get(ht, choiceOrInfoId);
    if !entryPtr { return; };
    var Ninja_MaxXPHelper_Entry entry; entry = _^(entryPtr);
    STRINT_SplitReset();
    const int count = 0; count = STR_SplitCount(entry.argument, ",");
    repeat(i, count); const int i = 0;
        const string npcCode = ""; npcCode = STRINT_SplitGet(i);
        const int npcInstanceId = 0; npcInstanceId = MEM_GetSymbolIndex(npcCode);
        if npcInstanceId < 0 { continue; };
        var C_NPC npc; npc = Hlp_GetNpc(npcInstanceId);
        if Hlp_IsValidNpc(npc) {
            if Ninja_MaxXPHelper_ThiefScanner_HasPlayerPickedPocket(npc) {
                Ninja_MaxXPHelper_TextAlerts_Create(
                    ConcatStrings(npc.name, " is no longer pickpocketable"),  
                    Ninja_MaxXPHelper_DeathAlertTextDurationInMillis, 
                    Ninja_MaxXPHelper_PickpocketAlertsWarningColor, 
                    FALSE
                ); 
                Ninja_MaxXPHelper_WarningAlerts_OnLostPickpocket(npc); 
            };
        };
    end;
};

func void _Ninja_MaxXPHelper_WarningAlerts_OnChoice() {
    // OnChoice is __fastcall convention, ECX is oCInformationManager, EDX is oCInfoChoice* param.
    Ninja_MaxXPHelper_LogInfo("Ninja_MaxXPHelper_WarningAlerts_OnChoice");
    var oCInfoChoice choice; choice = _^(EDX);
    _Ninja_MaxXPHelper_WarningAlerts_LostPickpocket(choice.Function);
    _Ninja_MaxXPHelper_WarningAlerts_ChapterOptimalInfo(choice.Function);
};

func void _Ninja_MaxXPHelper_WarningAlerts_OnInfo() {
    // OnChoice is __fastcall convention, ECX is oCInformationManager, EDX is oCInfoChoice* param.
    Ninja_MaxXPHelper_LogInfo("Ninja_MaxXPHelper_WarningAlerts_OnInfo");
    var oCInfo info; info = _^(EDX);
    _Ninja_MaxXPHelper_WarningAlerts_LostPickpocket(info.information);
    _Ninja_MaxXPHelper_WarningAlerts_ChapterOptimalInfo(info.information);
};

const int _Ninja_MaxXPHelper_WarningAlerts_ItemStatsHandled = FALSE;
func void _Ninja_MaxXPHelper_WarningAlerts_ShowItemStats() {
    _Ninja_MaxXPHelper_WarningAlerts_ItemStatsHandled = TRUE;
    const int listPtr = 0; listPtr = MEM_World.voblist_npcs;
    var zCListSort list; var C_Npc cnpc;
    const int goblinBerries = 0; goblinBerries = 0;
    const int goblinBerry = 0; goblinBerry = MEM_GetSymbolIndex("ITPL_DEX_HERB_01");
    const int swampherbs = 0; swampherbs = 0;
    const int swampherb = 0; swampherb = MEM_GetSymbolIndex("ITPL_SWAMPHERB");
    const int gil_pal_ = 0; gil_pal_ = MEM_GetSymbolIndex("GIL_PAL");
    const int gil_djg_ = 0; gil_djg_ = MEM_GetSymbolIndex("GIL_DJG");
    while (listPtr);
        list = _^(listPtr);
        listPtr = list.next;
        if !list.data { continue; };
        cnpc = _^(list.data);
        if !Hlp_IsValidNpc(cnpc) ||  Npc_IsPlayer(cnpc)  { continue; };
        if gil_pal_ > 0 && Npc_HasItems(cnpc, goblinBerry) && cnpc.guild == gil_pal_ && !(cnpc.flags & NPC_FLAG_IMMORTAL) {
            const int symbolPtr = 0; symbolPtr = MEM_GetSymbolByIndex(Hlp_GetInstanceID(cnpc));
            var zCPar_Symbol symbol; symbol = _^(symbolPtr);
            Ninja_MaxXPHelper_LogInfo(ConcatStrings("has goblin berry ", symbol.name));
            goblinBerries += 1;
        };
        if gil_djg_ > 0 && Npc_HasItems(cnpc, swampherb) && cnpc.guild == gil_djg_ && !(cnpc.flags & NPC_FLAG_IMMORTAL) {
            const int symbolPtr = 0; symbolPtr = MEM_GetSymbolByIndex(Hlp_GetInstanceID(cnpc));
            var zCPar_Symbol symbol; symbol = _^(symbolPtr);
            Ninja_MaxXPHelper_LogInfo(ConcatStrings("has swampherb ", symbol.name));
            swampherbs += 1;
        };

    end;
    Ninja_MaxXPHelper_TextAlerts_Create(
        ConcatStrings(Ninja_MaxXPHelper_LOC_WarningsBerryCount, IntToString(goblinBerries)), 
        Ninja_MaxXPHelper_SystemAlertDurationInMillis, 
        Ninja_MaxXPHelper_SystemNotificationsColor,
        TRUE
    );
    if swampherbs > 0 {
        Ninja_MaxXPHelper_TextAlerts_Create(
            ConcatStrings(Ninja_MaxXPHelper_LOC_Swampherbscount, IntToString(swampherbs)), 
            Ninja_MaxXPHelper_SystemAlertDurationInMillis, 
            Ninja_MaxXPHelper_SystemNotificationsColor,
            TRUE
        );  
    };
};

func void _Ninja_MaxXPHelper_WarningAlerts_XP_Mutations_Watchdog() {
    if !_Ninja_MaxXPHelper_WarningAlerts_ItemStatsHandled && MEM_KeyState(Ninja_MaxXPHelper_WarningAlertsItemStatsKey) == KEY_PRESSED {
        _Ninja_MaxXPHelper_WarningAlerts_ShowItemStats();
    } else {
        _Ninja_MaxXPHelper_WarningAlerts_ItemStatsHandled = FALSE;
    };
    if !Ninja_MaxXPHelper_ShouldRunHook() { return; };
    if _Ninja_MaxXPHelper_Last_B_GiveXP_XP != hero.exp {
        _Ninja_MaxXPHelper_InXPWatchdog = TRUE;
        Ninja_MaxXPHelper_LogInfo(ConcatStrings("Fixing XP to ", IntToString(hero.exp - _Ninja_MaxXPHelper_Last_B_GiveXP_XP)));
        _Ninja_MaxXPHelper_LogXPToCSV(hero.exp - _Ninja_MaxXPHelper_Last_B_GiveXP_XP, "XP Discrepancy detected", hero);
        _Ninja_MaxXPHelper_Last_B_GiveXP_XP = hero.exp;
        _Ninja_MaxXPHelper_InXPWatchdog = FALSE;
    };
};

func void Ninja_MaxXPHelper_WarningAlerts_Init() {
    _Ninja_MaxXPHelper_Last_B_GiveXP_XP = hero.exp;
    _Ninja_MaxXPHelper_WarningAlerts_ParseConfig();
    if !Ninja_MaxXPHelper_WarningAlerts_Init_Once || 
        Ninja_MaxXPHelper_LevelChanges == 0 {
        _Ninja_MaxXPHelper_OnLoad();
    };
    if !Ninja_MaxXPHelper_WarningAlerts_Init_Once {
        if GOTHIC_BASE_VERSION == 1 {
            HookDaedalusFuncS("B_GiveXP", "_Ninja_MaxXPHelper_B_GivePlayerXP_Hook");
        } else if GOTHIC_BASE_VERSION == 2 {
            HookDaedalusFuncS("B_GivePlayerXP", "_Ninja_MaxXPHelper_B_GivePlayerXP_Hook");
            HookDaedalusFuncS("B_CreateAmbientInv", "_Ninja_MaxXPHelper_B_CreateAmbientInv_Hook");
            HookEngineF(
                Ninja_MaxXPHelper_oCInformationManager_OnChoice, 
                7,
                _Ninja_MaxXPHelper_WarningAlerts_OnChoice
            );
            HookEngineF(
                Ninja_MaxXPHelper_oCInformationManager_OnInfo, 
                7,
                _Ninja_MaxXPHelper_WarningAlerts_OnInfo
            );
        };

        HookEngineF(oCSavegameManager__SetAndWriteSavegame, 5, _Ninja_MaxXPHelper_OnSave);
        HookEngineF(CGameManager__Read_Savegame, 7, _Ninja_MaxXPHelper_OnLoad);
        Ninja_MaxXPHelper_WarningAlerts_Init_Once = TRUE;
    };
    FF_ApplyOnceGT(_Ninja_MaxXPHelper_WarningAlerts_XP_Mutations_Watchdog);
    Ninja_MaxXPHelper_LevelChanges += 1;
};

