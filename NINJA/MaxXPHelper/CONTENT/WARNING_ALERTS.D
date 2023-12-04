const int Ninja_MaxXPHelper_WarningAlerts_ItemSpawnHT_Handle = 0;
const int Ninja_MaxXPHelper_WarningAlerts_LostPickpocketHT_Handle = 0;
const int Ninja_MaxXPHelper_WarningAlerts_RequiredInfoHT_Handle = 0;
const int Ninja_MaxXPHelper_WarningAlerts_ChapterOptimalInfoHT_Handle = 0;
class Ninja_MaxXPHelper_Entry {
    var string argument;
};
instance Ninja_MaxXPHelper_Entry@(Ninja_MaxXPHelper_Entry) {
};
func void _Ninja_MaxXPHelper_B_CreateAmbientInv_Hook(var C_NPC slf) {
    PassArgumentN(slf);
    ContinueCall();
    if !Ninja_MaxXPHelper_ShouldRunHook() {
        return;
    };
    const int ht = 0; ht = Ninja_MaxXPHelper_WarningAlerts_ItemSpawnHT_Handle;
    const int instanceId = 0; instanceId = Hlp_GetInstanceID(slf);
    if !ht { return; };
    if !Ninja_MaxXPHelper_HT_Has(ht, instanceId) { return; };
    Ninja_MaxXPHelper_LogInfo(ConcatStrings("_Ninja_MaxXPHelper_B_CreateAmbientInv_Hook: ", slf.name));
    const int itemId = 0; itemId = Ninja_MaxXPHelper_HT_Get(ht, instanceId);
    if itemId < 0 { return; };
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
        SB_Clear();
        SB_Destroy();
    };
};

func void _Ninja_MaxXPHelper_WarningAlerts_Handler_REQUIRED_ITEM_SPAWN() {
    const string npcCode = ""; npcCode = STRINT_SplitGet(1);
    const string itemCode = ""; itemCode = STRINT_SplitGet(2);
    const int npcId = 0; npcId = MEM_GetSymbolIndex(npcCode);
    const int itemId = 0; itemId = MEM_GetSymbolIndex(itemCode);
    Ninja_MaxXPHelper_LogInfo(ConcatStrings(npcCode, IntToString(npcId)));
    Ninja_MaxXPHelper_LogInfo(ConcatStrings(itemCode, IntToString(itemId)));
    var C_NPC npc; npc = Hlp_GetNpc(npcId);
    Ninja_MaxXPHelper_HT_InsertOrChange(
        Ninja_MaxXPHelper_WarningAlerts_ItemSpawnHT_Handle,
        npcId,
        itemId
    );  
};

func void Ninja_MaxXPHelper_WarningAlerts_OnNPCDeath(var C_NPC npc) {
    const int instanceId = 0; instanceId = Hlp_GetInstanceID(npc);
    const int ht = 0; ht = Ninja_MaxXPHelper_WarningAlerts_RequiredInfoHT_Handle;
    if !Ninja_MaxXPHelper_HT_Has(ht, instanceId) { return; };
    STRINT_SplitReset();
    var Ninja_MaxXPHelper_Entry entry; entry = get(Ninja_MaxXPHelper_HT_Get(ht, instanceId));
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
    Ninja_MaxXPHelper_HT_Remove(ht, instanceId);
};

func void _Ninja_MaxXPHelper_WarningAlerts_Handler_PICKPOCKET_LOST_OnChoice() {
    const string onChoiceFunctionCode = ""; onChoiceFunctionCode = STRINT_SplitGet(1);
    const string npcsCodes = ""; npcsCodes = STRINT_SplitGet(2);
    const int onChoice = 0; onChoice = MEM_GetSymbolIndex(onChoiceFunctionCode);
    if onChoice > 0 {
        const int handle = 0; handle = new(Ninja_MaxXPHelper_Entry@);
        var Ninja_MaxXPHelper_Entry entry; entry = get(handle);
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
    const int handle = 0; handle = new(Ninja_MaxXPHelper_Entry@);
    var Ninja_MaxXPHelper_Entry entry; entry = get(handle);
    entry.argument = STRINT_SplitGet(2);
    Ninja_MaxXPHelper_HT_InsertOrChange(
        Ninja_MaxXPHelper_WarningAlerts_RequiredInfoHT_Handle,
        instanceId,
        handle
    );
};

func void _Ninja_MaxXPHelper_WarningAlerts_Handler_REQUIRED_INFO_BEFORE_DEAD() {
    const string npcCode = ""; npcCode = STRINT_SplitGet(1);
    const string infosCodes = ""; infosCodes = STRINT_SplitGet(2);
    const int npcId = 0; npcId = MEM_GetSymbolIndex(npcCode);
    var C_NPC npc; npc = Hlp_GetNpc(npcId);
    if Hlp_IsValidNpc(npc) {
        const int handle = 0; handle = new(Ninja_MaxXPHelper_Entry@);
        var Ninja_MaxXPHelper_Entry entry; entry = get(handle);
        entry.argument = infosCodes;
        Ninja_MaxXPHelper_HT_InsertOrChange(
            Ninja_MaxXPHelper_WarningAlerts_RequiredInfoHT_Handle,
            npcId,
            handle
        );
    };
};

func void _Ninja_MaxXPHelper_WarningAlerts_ParseCSV() {
    Ninja_MaxXPHelper_HT_ClearAndCreate(_@(Ninja_MaxXPHelper_WarningAlerts_ItemSpawnHT_Handle), 0);
    Ninja_MaxXPHelper_HT_ClearAndCreate(_@(Ninja_MaxXPHelper_WarningAlerts_LostPickpocketHT_Handle), 0);
    Ninja_MaxXPHelper_HT_ClearAndCreate(_@(Ninja_MaxXPHelper_WarningAlerts_RequiredInfoHT_Handle), 0);
    Ninja_MaxXPHelper_HT_ClearAndCreate(_@(Ninja_MaxXPHelper_WarningAlerts_ChapterOptimalInfoHT_Handle), 0);
       
    var int streamPtr; streamPtr = Ninja_MaxXPHelper_OpenFileStreamForReading("system\maxxphelper_warnings.csv");
    if streamPtr {
        const int gotoLabel = 0; gotoLabel = MEM_StackPos.position;
        if !Ninja_MaxXPHelper_EOF(streamPtr) {
            STRINT_SplitReset();
            const string line = ""; line = Ninja_MaxXPHelper_TextLine(streamPtr);
            const int count = 0; count = STR_SplitCount(line, ";");
            if count > 0 {
                const string type = ""; type = STRINT_SplitGet(0);
                Ninja_MaxXPHelper_LogInfo(ConcatStrings("Warning type=", type));
                const int handler = 0; handler = MEM_GetSymbolIndex(ConcatStrings("_Ninja_MaxXPHelper_WarningAlerts_Handler_", type));
                if handler < 0 { continue; };
                MEM_CallByID(handler);
            };
            MEM_StackPos.position = gotoLabel;
        };
        Ninja_MaxXPHelper_CloseFileStream(streamPtr);
    };
};

func void _Ninja_MaxXPHelper_WarningAlerts_OnChoice_LostPickpocket(var oCInfoChoice choice) {
    const int ht = 0; ht = Ninja_MaxXPHelper_WarningAlerts_LostPickpocketHT_Handle;
    if Ninja_MaxXPHelper_HT_Has(ht, choice.Function) { return; };
    var Ninja_MaxXPHelper_Entry entry; entry = get(
        Ninja_MaxXPHelper_HT_Get(ht, choice.Function)
    );
    STRINT_SplitReset();
    const int count = 0; count = STR_SplitCount(entry.argument, ",");
    repeat(i, count); const int i = 0;
        const string npcCode = ""; npcCode = STRINT_SplitGet(i);
        const int npcInstanceId = 0; npcInstanceId = MEM_GetSymbolIndex(npcCode);
        if instanceId < 0 { continue; };
        var C_NPC npc; npc = Hlp_GetNpc(npcInstanceId);
        if Hlp_IsValidNpc(npc) {
            if Ninja_MaxXPHelper_ThiefScanner_HasPlayerPickedPocket(npc) {
                Ninja_MaxXPHelper_TextAlerts_Create(
                    ConcatStrings(npc.name, " is no longer pickpocketable"),  
                    Ninja_MaxXPHelper_DeathAlertTextDurationInMillis, 
                    Ninja_MaxXPHelper_PickpocketAlertsWarningColor, 
                    FALSE
                );  
            };
        };
    end;
};

func void _Ninja_MaxXPHelper_WarningAlerts_OnChoice_ChapterOptimalInfo(var oCInfoChoice choice) {
    const int ht = 0; ht = Ninja_MaxXPHelper_WarningAlerts_ChapterOptimalInfoHT_Handle;
    const int instanceId = 0; instanceId = choice.Function;
    if Ninja_MaxXPHelper_HT_Has(ht, instanceId) { return; };
    var Ninja_MaxXPHelper_Entry entry; entry = get(
        Ninja_MaxXPHelper_HT_Get(ht, instanceId)
    );
    const int chapter = 0; chapter = STR_ToInt(entry.argument);
    if Kapitel >= chapter { return; }; // todo: on next chapter, check if any dialogs were missed (won't work for choices) tho?
    const int s = 0; s = SB_New();
    const int symbolPtr = 0; symbolPtr = MEM_GetSymbolByIndex();
    var zCPar_Symbol symbol; symbol = _^(symbolPtr);
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

func void Ninja_MaxXPHelper_WarningAlerts_OnChoice() {
    // OnChoice is __fastcall convention, ECX is oCInformationManager, EDX is oCInfoChoice* param.
    var oCInfoChoice choice; choice = _^(EDX);
    _Ninja_MaxXPHelper_WarningAlerts_OnChoice_LostPickpocket(choice);
    _Ninja_MaxXPHelper_WarningAlerts_OnChoice_ChapterOptimalInfo(choice);
};

const int Ninja_MaxXPHelper_oCInformationManager_OnChoice = 6695328; // todo g1
const int Ninja_MaxXPHelper_WarningAlerts_Init_Once = FALSE;
func void Ninja_MaxXPHelper_WarningAlerts_Init() {
    _Ninja_MaxXPHelper_WarningAlerts_ParseCSV();
    if !Ninja_MaxXPHelper_WarningAlerts_Init_Once {
        HookDaedalusFuncS("B_CreateAmbientInv", "_Ninja_MaxXPHelper_B_CreateAmbientInv_Hook");
        HookEngineF(
            Ninja_MaxXPHelper_oCInformationManager_OnChoice, 
            7, // first instruction is just 2 bytes, second is 5. To hook a jump we need at least 5 bytes so here we must take 2 instructions.
            Ninja_MaxXPHelper_WarningAlerts_OnChoice
        );
        Ninja_MaxXPHelper_WarningAlerts_Init_Once = TRUE;
    };
};