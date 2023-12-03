const int Ninja_MaxXPHelper_WarningAlerts_ItemSpawnHT_Handle = 0;
const int Ninja_MaxXPHelper_WarningAlerts_LostPickpocketHT_Handle = 0;
const int Ninja_MaxXPHelper_WarningAlerts_RequiredInfoHT_Handle = 0;
class Ninja_MaxXPHelper_Entry {
    var string commaSeparatedNPCs;
};
instance Ninja_MaxXPHelper_Entry@(Ninja_MaxXPHelper_Entry) {
    commaSeparatedNPCs = "";
};
func void Ninja_MaxXPHelper_B_CreateAmbientInv_Hook(var C_NPC slf) {
    PassArgumentN(slf);
    ContinueCall();
    const int instanceId = 0; instanceId = Hlp_GetInstanceID(slf);
    const int itemMaybe = 0; itemMaybe = Ninja_MaxXPHelper_HT_Get(
        Ninja_MaxXPHelper_WarningAlerts_ItemSpawnHT_Handle, instanceId
    );
    if itemMaybe {
        var C_Item item; item = _^(itemMaybe);
        if Npc_HasItems(slf, item) == 0 {
            Ninja_MaxXPHelper_TextAlerts_Create(
                ConcatStrings(slf.name, " spawned without required item"),  
                Ninja_MaxXPHelper_DeathAlertTextDurationInMillis, 
                Ninja_MaxXPHelper_PickpocketAlertsWarningColor, 
                FALSE
            );  
        };
    };
};

func void _Ninja_MaxXPHelper_WarningAlerts_Handler_REQUIRED_ITEM_SPAWN() {
    
    const string npcCode = ""; npcCode = STRINT_SplitGet(1);
    const string itemCode = ""; itemCode = STRINT_SplitGet(2);
    const int npcId = 0; npcId = MEM_GetSymbolIndex(npcCode);
    const int itemId = 0; itemId = MEM_GetSymbolIndex(itemCode);
    var C_Item itm; itm = _^(itemId);
    var C_NPC npc; npc = Hlp_GetNpc(npcId);
    if Hlp_IsValidNpc(npc) && HLP_IsValidItem(itm) {
        Ninja_MaxXPHelper_HT_InsertOrChange(
            Ninja_MaxXPHelper_WarningAlerts_ItemSpawnHT_Handle,
            npcId,
            itemId
        );  
    };
};

func void Ninja_MaxXPHelper_WarningAlerts_OnNPCDeath(var C_NPC npc) {

};

func void _Ninja_MaxXPHelper_WarningAlerts_Handler_PICKPOCKET_LOST_OnChoice() {
    const string onChoiceFunctionCode = ""; onChoiceFunctionCode = STRINT_SplitGet(1);
    const string npcsCodes = ""; npcsCodes = STRINT_SplitGet(2);
    const int onChoice = 0; onChoice = MEM_GetSymbolIndex(onChoiceFunctionCode);
    if onChoice > 0 {
        const int handle = 0; handle = new(Ninja_MaxXPHelper_Entry@);
        var Ninja_MaxXPHelper_Entry entry; entry = get(handle);
        entry.commaSeparatedNPCs = npcsCodes;
        Ninja_MaxXPHelper_HT_InsertOrChange(
            Ninja_MaxXPHelper_WarningAlerts_LostPickpocketHT_Handle,
            onChoice,
            handle
        );
    };
};

func void _Ninja_MaxXPHelper_WarningAlerts_Handler_REQUIRED_INFO() {

};
func void Ninja_MaxXPHelper_WarningAlerts_ParseCSV() {
    Ninja_MaxXPHelper_HT_ClearAndCreate(_@(Ninja_MaxXPHelper_WarningAlerts_ItemSpawnHT_Handle), 0);
    Ninja_MaxXPHelper_HT_ClearAndCreate(_@(Ninja_MaxXPHelper_WarningAlerts_LostPickpocketHT_Handle), 0);
    Ninja_MaxXPHelper_HT_ClearAndCreate(_@(Ninja_MaxXPHelper_WarningAlerts_RequiredInfoHT_Handle), 0);    
    var int streamPtr; streamPtr = Ninja_MaxXPHelper_OpenFileStreamForReading("system\maxxphelper_warnings.csv");
    if streamPtr {
        const int gotoLabel = 0; gotoLabel = MEM_StackPos.position;
        if !Ninja_MaxXPHelper_EOF(streamPtr) {
            STRINT_SplitReset();
            
            const string line = ""; line = Ninja_MaxXPHelper_TextLine(streamPtr);
            const int count = 0; count = STR_SplitCount(line, ";");
            Ninja_MaxXPHelper_LogInfo(type);
                Ninja_MaxXPHelper_LogInfo(IntToString(handler));
            if count > 0 {
                const string type = ""; type = STRINT_SplitGet(0);
                const int handler = 0; handler = MEM_GetSymbolIndex(ConcatStrings("_Ninja_MaxXPHelper_WarningAlerts_Handler_", type));
                if handler > 0 {
                    MEM_CallByID(handler);
                };
            };
            MEM_StackPos.position = gotoLabel;
        };

        Ninja_MaxXPHelper_CloseFileStream(streamPtr);
    };
    while (TRUE);
        break;
    end;
};
class Ninja_MaxXPHelper_WarningAlerts_MaybeoCInfoChoice {
    var string text;
    var int function;
};
func void Ninja_MaxXPHelper_WarningAlerts_OnChoice() {
    // OnChoice is __fastcall convention, ECX is oCInformationManager, EDX is oCInfoChoice* param.
    var Ninja_MaxXPHelper_WarningAlerts_MaybeoCInfoChoice choice; choice = _^(EDX);
    if Ninja_MaxXPHelper_HT_Has(Ninja_MaxXPHelper_WarningAlerts_LostPickpocketHT_Handle, choice.function) {
        var Ninja_MaxXPHelper_Entry entry; entry = get(
            Ninja_MaxXPHelper_HT_Get(Ninja_MaxXPHelper_WarningAlerts_LostPickpocketHT_Handle, choice.function)
        );
        STRINT_SplitReset();
        const int count = 0; count = STR_SplitCount(entry.commaSeparatedNPCs, ",");
        repeat(i, count); const int i = 0;
            const string npcCode = ""; npcCode = STRINT_SplitGet(i);
            const int npcInstanceId = 0; npcInstanceId = MEM_GetSymbolIndex(npcCode);
            if npcInstanceId > 0 {
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
            };
            
        end;
    };
};
const int Ninja_MaxXPHelper_oCInformationManager_OnChoice = 6695328; // todo g1
const int Ninja_MaxXPHelper_WarningAlerts_Init_Once = FALSE;
func void Ninja_MaxXPHelper_WarningAlerts_Init() {
    Ninja_MaxXPHelper_WarningAlerts_ParseCSV();
    if !Ninja_MaxXPHelper_WarningAlerts_Init_Once {
        //HookDaedalusFuncS("B_CreateAmbientInv", "Ninja_MaxXPHelper_B_CreateAmbientInv_Hook");
        HookEngineF(
            Ninja_MaxXPHelper_oCInformationManager_OnChoice, 
            7, // first instruction is just 2 bytes, second is 5. To hook a jump we need at least 5 bytes so here we must take 2 instructions.
            Ninja_MaxXPHelper_WarningAlerts_OnChoice
        );
        Ninja_MaxXPHelper_WarningAlerts_Init_Once = TRUE;
    };
};