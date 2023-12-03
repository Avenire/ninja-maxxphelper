const int Ninja_MaxXPHelper_ThiefScanner_NPC_2_PickpocketInfo = 0;
const int Ninja_MaxXPHelper_ThiefScanner_PickpocketableNPCArray = 0;
const int Ninja_MaxXPHelper_ThiefScanner_PickpocketAlertsHT_Handle = 0;
const int Ninja_MaxXPHelper_ThiefScanner_NotPickpocktableOnLoadHT = 0;
const int _Ninja_MaxXPHelper_ThiefScanner_NextGlobalNpcPtr = 0;
const int _Ninja_MaxXPHelper_ThiefScanner_InitOnce = FALSE;
const int _Ninja_MaxXPHelper_ThiefScanner_NPC_IsInState_HookPtr = 0;
const int _Ninja_MaxXPHelper_ThiefScanner_HackIsState = FALSE;
const int _Ninja_MaxXPHelper_ThiefScanner_FakeIsInStateReturn = FALSE;

func int _Ninja_MaxXPHelper_ThiefScanner_CallCondition(var int condition, var C_NPC npc) {
    const int pickpocketable = 0; pickpocketable = FALSE;
    self = Hlp_GetNpc(npc);
    other = Hlp_GetNpc(hero);
    // Implicit returns are so stupid in Daedalus, default FALSE return val has to be pushed here because plenty of pickpokcet 
    // condition functions only return TRUE explicitly...
    pickpocketable; 
    MEM_CallByID(condition); // And here I am using implicit return, anyway...
};

func int _Ninja_MaxXPHelper_ThiefScanner_CanPickpocketNpc(var C_NPC npc, var int considerFailed) {
    const int instanceId = 0; instanceId = Hlp_GetInstanceID(npc);
    if considerFailed && Ninja_MaxXPHelper_HT_Has(Ninja_MaxXPHelper_ThiefScanner_PickpocketAlertsHT_Handle, instanceId) {
        return FALSE;
    };
    const int infoPtr = 0; infoPtr = Ninja_MaxXPHelper_HT_Get(Ninja_MaxXPHelper_ThiefScanner_NPC_2_PickpocketInfo, instanceId);
    if infoPtr {
        return npc.aivar[AIV_PlayerHasPickedMyPocket] == FALSE;
    } else {
        return FALSE;
    };
};

func int Ninja_MaxXPHelper_ThiefScanner_CanPickpocketNpc(var C_NPC npc) {
    return _Ninja_MaxXPHelper_ThiefScanner_CanPickpocketNpc(npc, TRUE);
};

const int Ninja_MaxXPHelper_ThiefScanner_SeemsEnough = 1; 
const int Ninja_MaxXPHelper_ThiefScanner_SeemsNotEnough = -1;
const int Ninja_MaxXPHelper_ThiefScanner_Unknown = 0;

func int Ninja_MaxXPHelper_ThiefScanner_EnoughDexToPickpocket(var C_NPC npc) {
    // Assumes NPC can still be pickpocketed
    const int instanceId = 0; instanceId = Hlp_GetInstanceID(npc);
    if Ninja_MaxXPHelper_HT_Get(Ninja_MaxXPHelper_ThiefScanner_NotPickpocktableOnLoadHT, instanceId) ||
       _Ninja_MaxXPHelper_ThiefScanner_TheftDiff <= 0 {
        return Ninja_MaxXPHelper_ThiefScanner_Unknown;
    };
    if hero.attribute[ATR_DEXTERITY] <= 20 {
        // In vanilla G2 NotR scripts function C_Beklauen seems to be bugged. If required pickpocket dex is below 20 then it 
        // sets TheftDexGlob to 10. This global var is then checked B_Beklauen when pickpocket is attempted so 
        // hero with less than 20 dex can pickpocket such NPC. However, some NPCs don't use X_Beklauen script and their condition is
        // tested as expected so pickpocket would fail. I just make things simple and return "dunno" here. If anyone goes for pickpocketing they are 
        // going to end up with much more than 20 dex anyway so I don't bother handling this edge case in more sophisticated manner.
        return Ninja_MaxXPHelper_ThiefScanner_Unknown;
    };
    var c_npc selfBak; selfBak = Hlp_GetNpc(self);
    var c_npc otherBak; otherBak = Hlp_GetNpc(other);
    const int infoPtr = 0; infoPtr = Ninja_MaxXPHelper_HT_Get(Ninja_MaxXPHelper_ThiefScanner_NPC_2_PickpocketInfo, instanceId);
    if !infoPtr { return Ninja_MaxXPHelper_ThiefScanner_Unknown; };
    var oCInfo info; info = _^(infoPtr);
    const int heroPickpocket = 0; heroPickpocket = Npc_GetTalentSkill(hero, NPC_TALENT_PICKPOCKET);
    const int heroDex = 0; heroDex = hero.attribute[ATR_DEXTERITY];
    Npc_SetTalentSkill(hero, NPC_TALENT_PICKPOCKET, TRUE);
    hero.attribute[ATR_DEXTERITY] = hero.attribute[ATR_DEXTERITY] - Theftdiff;
    // C_Beklauen does side effects if NPC is in ZS_Talk state so pretend they aren't.
    _Ninja_MaxXPHelper_ThiefScanner_HackIsState = TRUE;
    _Ninja_MaxXPHelper_ThiefScanner_FakeIsInStateReturn = FALSE;
    const int pickpocketable = 0; pickpocketable = _Ninja_MaxXPHelper_ThiefScanner_CallCondition(info.conditions, npc);
    _Ninja_MaxXPHelper_ThiefScanner_HackIsState = FALSE;
    if pickpocketable {
        pickpocketable = Ninja_MaxXPHelper_ThiefScanner_SeemsEnough;
    } else {
        pickpocketable = Ninja_MaxXPHelper_ThiefScanner_SeemsNotEnough;
    };
    Npc_SetTalentSkill(hero, NPC_TALENT_PICKPOCKET, heroPickpocket);
    hero.attribute[ATR_DEXTERITY] = heroDex;
    self = Hlp_GetNpc(selfBak);
    other = Hlp_GetNpc(otherBak);
    return pickpocketable;
};

const int _Ninja_MaxXPHelper_ThiefScanner_FullyScanned = FALSE;

func void Ninja_MaxXPHelper_ThiefScanner_OnNPCDeath(var C_Npc npc) {
    
    if !Ninja_MaxXPHelper_ThiefScanner_CanPickpocketNpc(npc) { return; };
    const int color = 0; color = Ninja_MaxXPHelper_DeathAlertsFailColor;
    const string msg = ""; msg = Ninja_MaxXPHelper_LOC_PickpocketWarningDeath;
    const int s = 0; s = SB_New();
    SB(npc.name);
    SB(" - ");
    SB(msg);
    Ninja_MaxXPHelper_TextAlerts_Create(
        SB_ToString(),  
        Ninja_MaxXPHelper_DeathAlertTextDurationInMillis, 
        color, 
        FALSE
    );
    SB_Clear();
    SB_Destroy();
    Ninja_MaxXPHelper_HT_Insert(Ninja_MaxXPHelper_ThiefScanner_PickpocketAlertsHT_Handle, TRUE, Hlp_GetInstanceID(npc));
    Ninja_MaxXPHelper_WarningAlerts_OnLostPickpocket(npc);
};
func void _Ninja_MaxXPHelper_ThiefScanner_RefreshLoop() {
    if !Ninja_MaxXPHelper_ShouldRunHook() {
        return;
    };

    if !Ninja_MaxXPHelper_ConsiderPickpocketing { return; };
    const int size = 0; size = MEM_ArraySize(Ninja_MaxXPHelper_ThiefScanner_PickpocketableNPCArray);
    const int idx = 0; 
    if !_Ninja_MaxXPHelper_ThiefScanner_FullyScanned {
        idx = 0;
    };
    var c_npc selfBak; selfBak = Hlp_GetNpc(self);
    var c_npc otherBak; otherBak = Hlp_GetNpc(other);
    const int heroPickpocket = 0; heroPickpocket = Npc_GetTalentSkill(hero, NPC_TALENT_PICKPOCKET);
    const int heroDex = 0; heroDex = hero.attribute[ATR_DEXTERITY];
    Npc_SetTalentSkill(hero, NPC_TALENT_PICKPOCKET, TRUE);
    hero.attribute[ATR_DEXTERITY] = 9999;
    const int processed = 0; processed = 0;
    while (TRUE);
        if idx >= size {
            _Ninja_MaxXPHelper_ThiefScanner_FullyScanned = TRUE;
            idx = 0;
        };
        if _Ninja_MaxXPHelper_ThiefScanner_FullyScanned &&
            processed >= Ninja_MaxXPHelper_XPNPCLocator_MaxNPCToProcessEachFrameBeforeYield {
            break;
        };
        const int instanceId = 0; instanceId = MEM_ArrayRead(Ninja_MaxXPHelper_ThiefScanner_PickpocketableNPCArray, idx);
        idx = idx + 1;
        processed = processed + 1;

        var C_NPC npc; npc = Hlp_GetNpc(instanceId);
        if Hlp_IsValidNpc(npc) && _Ninja_MaxXPHelper_ThiefScanner_CanPickpocketNpc(npc, FALSE) {
            const int instanceId = 0; instanceId = Hlp_GetInstanceID(npc);
            // Magic time
            const int infoPtr = 0; infoPtr = Ninja_MaxXPHelper_HT_Get(Ninja_MaxXPHelper_ThiefScanner_NPC_2_PickpocketInfo, instanceId);
            var oCInfo info; info = _^(infoPtr);
            const int isDead = 0; isDead = Npc_IsDead(npc);
            const int pickpocketable = 0; pickpocketable = !isDead;
            if pickpocketable {
                // C_Beklauen does side effects if NPC is in ZS_Talk state so pretend they aren't.
                _Ninja_MaxXPHelper_ThiefScanner_HackIsState = TRUE;
                _Ninja_MaxXPHelper_ThiefScanner_FakeIsInStateReturn = FALSE;
                const int pickpocketable = 0; pickpocketable = _Ninja_MaxXPHelper_ThiefScanner_CallCondition(info.conditions, npc);
                _Ninja_MaxXPHelper_ThiefScanner_HackIsState = FALSE;
            };
            // If we're checking NPC for the first time then remember if they are pickpocketable at this point (they might become later).
            if !_Ninja_MaxXPHelper_ThiefScanner_FullyScanned {
                Ninja_MaxXPHelper_HT_InsertOrChange(Ninja_MaxXPHelper_ThiefScanner_NotPickpocktableOnLoadHT, instanceId, !pickpocketable);
                continue;
            };
            // Skip if NPC just become pickpocketable (since last scan).
            if  pickpocketable && 
                Ninja_MaxXPHelper_HT_Get(Ninja_MaxXPHelper_ThiefScanner_NotPickpocktableOnLoadHT, instanceId) {
                Ninja_MaxXPHelper_HT_InsertOrChange(Ninja_MaxXPHelper_ThiefScanner_NotPickpocktableOnLoadHT, instanceId, FALSE);
                if Ninja_MaxXPHelper_HT_Has(Ninja_MaxXPHelper_ThiefScanner_PickpocketAlertsHT_Handle, instanceId) {
                    Ninja_MaxXPHelper_HT_Remove(Ninja_MaxXPHelper_ThiefScanner_PickpocketAlertsHT_Handle, instanceId);
                };
                continue;
            };
            // Skip if NPC is alive and wasn't observed to be pickpocketable since last load or was failure was already alerted.
            if (
                (!isDead && Ninja_MaxXPHelper_HT_Get(Ninja_MaxXPHelper_ThiefScanner_NotPickpocktableOnLoadHT, instanceId)) ||
                Ninja_MaxXPHelper_HT_Has(Ninja_MaxXPHelper_ThiefScanner_PickpocketAlertsHT_Handle, instanceId) ||
                pickpocketable
            ) {
                continue;
            };
            const int color = 0;
            var string msg; msg = "";
            if isDead {
                color = Ninja_MaxXPHelper_DeathAlertsFailColor;
                msg = Ninja_MaxXPHelper_LOC_PickpocketWarningDeath;
            } else {
                color = Ninja_MaxXPHelper_PickpocketAlertsWarningColor;
                msg = Ninja_MaxXPHelper_LOC_PickpocketWarningOther;
                const int s = 0; s = MEM_GetSymbol("NpcObsessedByDMT");
                if (s) {
                    var zCPar_Symbol _NpcObsessedByDMT; _NpcObsessedByDMT = _^(s);
                    if _NpcObsessedByDMT.content {
                        continue; 
                    };
                };
            };
            if STR_Len(msg) {
                const int s = 0; s = SB_New();
                SB(npc.name);
                SB(" - ");
                SB(msg);
                Ninja_MaxXPHelper_TextAlerts_Create(
                    SB_ToString(),  
                    Ninja_MaxXPHelper_DeathAlertTextDurationInMillis, 
                    color, 
                    FALSE
                );
                SB_Clear();
                SB_Destroy();
                Ninja_MaxXPHelper_HT_Insert(Ninja_MaxXPHelper_ThiefScanner_PickpocketAlertsHT_Handle, TRUE, instanceId);
                Ninja_MaxXPHelper_WarningAlerts_OnLostPickpocket(npc);
            };
        };
    end;
    self = Hlp_GetNpc(selfBak);
    other = Hlp_GetNpc(otherBak);
    hero.attribute[ATR_DEXTERITY] = heroDex;
    Npc_SetTalentSkill(hero, NPC_TALENT_PICKPOCKET, heroPickpocket);
};

const int _Ninja_MaxXPHelper_ThiefScanner_TheftDiff = 0;
func void _Ninja_MaxXPHelper_ThiefScanner_InitTheftDiff() {
    const int symbolPtr = 0; symbolPtr = MEM_GetSymbol("Theftdiff");
    if symbolPtr {
         var zCPar_Symbol s; s = _^(symbolPtr);
         _Ninja_MaxXPHelper_ThiefScanner_TheftDiff = s.content;
    };
};

func int _Ninja_MaxXPHelper_ThiefScanner_CreateBlacklistHT() {
    const int blacklist = 0; blacklist = Ninja_MaxXPHelper_HT_Create();
    STRINT_SplitReset();
    const int count = 0; count = STR_SplitCount(Ninja_MaxXPHelper_PickpocketBlacklist, ";");
    repeat(i, count); const int i = 0;
        var string npcCode; npcCode = STRINT_SplitGet(i);
        const int instanceId = 0; instanceId = MEM_GetSymbolIndex(npcCode);
        Ninja_MaxXPHelper_HT_InsertOrChange(blacklist, instanceId, TRUE);
    end;
    return blacklist;
};

func void _Ninja_MaxXPHelper_ThiefScanner_InsertIntoPickpocketableNPCArray(var int npc, var int value) {
    MEM_ArrayInsert(Ninja_MaxXPHelper_ThiefScanner_PickpocketableNPCArray, npc);
};

func int _Ninja_MaxXPHelper_ThiefScanner_Handle_C_Beklauen(var int codePtr) {
    const int C_Beklauen_content = 0;
    if !C_Beklauen_content {
        var zCPar_Symbol symbol; symbol = _^(MEM_GetSymbol("C_Beklauen"));
        C_Beklauen_content = symbol.content;
    };
    const int pushInt_dex_maybe = 0; pushInt_dex_maybe = MEM_ReadByte(codePtr);
    const int pushInt_gold_maybe = 0; pushInt_gold_maybe = MEM_ReadByte(codePtr + 5);
    const int callFunc_maybe = 0; callFunc_maybe = MEM_ReadByte(codePtr + 10);
    const int C_Beklauen_content_maybe = 0; C_Beklauen_content_maybe = MEM_ReadInt(codePtr + 11);
    if (
        pushInt_dex_maybe == zPAR_TOK_PUSHINT &&
        pushInt_gold_maybe == zPAR_TOK_PUSHINT &&
        callFunc_maybe == zPAR_TOK_CALL &&
        C_Beklauen_content_maybe == C_Beklauen_content
    ) {
        return MEM_ReadInt(codePtr + 1); // dex required
    };
    return FALSE;
};

func int _Ninja_MaxXPHelper_ThiefScanner_ParseCodeUntilReturn(var int functionIdx) {
    const int symPtr = 0; symPtr = MEM_GetSymbolByIndex(functionIdx);
    var zCPar_Symbol symbol; symbol = _^(symPtr);
    const int codePtr = 0; codePtr = MEM_ReadInt(ContentParserAddress + zCParser_stack_offset) + symbol.content;

    const int hasItemsFound = 0;
    const int pushedInt = 0;
    const int command = 0;
    const int probablyTheDex = -1;
    const int arg = 0;
    const int isPickpocketInfo = 0;
    const int pushUnexpectedSymbolEncountered = -1; // For cases where condition checks variables other than skill check, dex check or item check
    pushUnexpectedSymbolEncountered = FALSE; 
    probablyTheDex = -1;
    hasItemsFound = FALSE;
    isPickpocketInfo = FALSE;
    pushedInt = -1;
    const int Npc_HasItems_idx = FALSE;

    if !Npc_HasItems_idx {
        Npc_HasItems_idx = MEM_GetSymbolIndex("Npc_HasItems");
    };
    const int C_NPC_attribute_idx = 0;
    if !C_NPC_attribute_idx {
        C_NPC_attribute_idx = MEM_GetSymbolIndex("C_NPC.ATTRIBUTE");
    };
    const int C_NPC_AIVAR_idx = 0;
    if !C_NPC_AIVAR_idx {
        C_NPC_AIVAR_idx = MEM_GetSymbolIndex("C_NPC.AIVAR");
    };
    const int C_Beklauen_content = 0;
    if !C_Beklauen_content {
        symbol = _^(MEM_GetSymbol("C_Beklauen"));
        C_Beklauen_content = symbol.content;
    };
    const int pushDexterityEncountered = 0;
    pushDexterityEncountered = FALSE;
    const int gotoLabel = 0; gotoLabel = MEM_StackPos.position;
    command = MEM_ReadByte(codePtr);
    if command == 15 || command == 16 || command == 17 || command == 18 {
        // Reset context on comparison command
        if pushDexterityEncountered && probablyTheDex == -1 {
            probablyTheDex = pushedInt;
        };
        pushedInt = -1;
        codePtr = codePtr + 1;
    } else if command == 60 {
        // First return opcode met, exit parsing
        if isPickpocketInfo {
            var string x; x = symbol.name;
            x = ConcatStrings(x, "@");
            x = ConcatStrings(x, IntToString(codePtr));
            // Ninja_MaxXPHelper_LogInfo(x);
            symbol = _^(symPtr);
            // Ninja_MaxXPHelper_LogInfo(ConcatStrings("probablyTheDex=", IntToString(probablyTheDex)));
            // Ninja_MaxXPHelper_LogInfo(ConcatStrings("hasItemsFound=", IntToString(hasItemsFound)));
            return probablyTheDex;
        };
        return -1;
    } else if command == 61 || command == 62 {
        arg = MEM_ReadInt(codePtr + 1);
        if arg == Npc_HasItems_idx {
            hasItemsFound = TRUE;
        } else if arg == C_Beklauen_content {
            isPickpocketInfo = TRUE;
            probablyTheDex = pushedInt;
        } else {
        };
        codePtr = codePtr + 5;
    } else if command == 64 {
        if pushedInt < 0 {
            pushedInt = MEM_ReadInt(codePtr + 1);
        };
        // push int, skip opcode + int arg
        codePtr = codePtr + 5;
    } else if command == 65 {
        arg = MEM_ReadInt(codePtr + 1);
        codePtr = codePtr + 5;
    } else if command == 66 || command == 67 || command == 75 || command == 76 || command == 80 {
        codePtr = codePtr + 5;
    } else if command == 245 {
        arg = MEM_ReadInt(codePtr + 1);
        // G2 NotR symbol offset (?) for attributes array
        if arg == C_NPC_attribute_idx {
            arg = MEM_ReadByte(codePtr + 5);
            if arg == ATR_DEXTERITY {
                pushDexterityEncountered = TRUE;
            };
        } else if arg == C_NPC_AIVAR_idx {
            arg = MEM_ReadByte(codePtr + 5);
            if arg == AIV_PlayerHasPickedMyPocket {
                isPickpocketInfo = TRUE;
            };
        };
        // skip opcode, int, byte
        codePtr = codePtr + 6;
    } else {
        codePtr = codePtr + 1;
    };
    MEM_StackPos.position = gotoLabel;
};

func void _Ninja_MaxXPHelper_ThiefScanner_LoadPickpocketInfos() {
    const int blacklist = 0; 
    blacklist = _Ninja_MaxXPHelper_ThiefScanner_CreateBlacklistHT();
    const string pickpocketSuffix = "_PICKPOCKET";
    const string altPickpocketSuffix = "_PICKME"; // Cassia...
    const int pickpocketSuffixLen = 0; pickpocketSuffixLen = STR_Len(pickpocketSuffix);
    const int listPtr = 0; listPtr = _@(MEM_InfoMan.infoList_compare);
    const int dex = 0;
    while (listPtr);
        var zCListSort list; list = _^(listPtr);
        listPtr = list.next;
        if list.data {            
            var oCInfo info; info = _^(list.data);
            if Ninja_MaxXPHelper_HT_Has(blacklist, info.npc) { continue; };
            dex = _Ninja_MaxXPHelper_ThiefScanner_ParseCodeUntilReturn(info.conditions);
            if dex > 0 {
                var string newDescription; newDescription = ConcatStrings(" (", IntToString(dex));
                newDescription = ConcatStrings(newDescription, ")");
                if !Ninja_MaxXPHelper_EndsWith(info.description, newDescription) {
                    info.description = ConcatStrings(info.description, newDescription);
                };
            };
            if Ninja_MaxXPHelper_EndsWith(info.name, altPickpocketSuffix) {
                Ninja_MaxXPHelper_HT_InsertOrChange(Ninja_MaxXPHelper_ThiefScanner_NPC_2_PickpocketInfo, info.npc, _@(info));
                continue;
            };
            if  Ninja_MaxXPHelper_EndsWith(info.name, pickpocketSuffix) && 
                !Ninja_MaxXPHelper_HT_Has(Ninja_MaxXPHelper_ThiefScanner_NPC_2_PickpocketInfo, info.npc) {
                Ninja_MaxXPHelper_HT_Insert(Ninja_MaxXPHelper_ThiefScanner_NPC_2_PickpocketInfo, _@(info), info.npc);
                continue;
            };
        };
    end;
    Ninja_MaxXPHelper_HT_Destroy(blacklist);
    Ninja_MaxXPHelper_HT_ForEach(
        Ninja_MaxXPHelper_ThiefScanner_NPC_2_PickpocketInfo,
        _Ninja_MaxXPHelper_ThiefScanner_InsertIntoPickpocketableNPCArray
    );
};

// Oh boy, this got nasty. HookDaedalus function doesn't work for externals
// so all is left is play with the assembly myself.
func void _Ninja_MaxXPHelper_ThiefScanner_Hook_NPC_IsInState_External() {
    var zCPar_Symbol symbol; symbol = _^(MEM_GetSymbol("Npc_IsInState"));
    const int originalPtr = 0; originalPtr = symbol.content;
    // todo: make sure this is still external func symbol?
    if _Ninja_MaxXPHelper_ThiefScanner_NPC_IsInState_HookPtr && 
        originalPtr == _Ninja_MaxXPHelper_ThiefScanner_NPC_IsInState_HookPtr {
        return;
    };
    ASM_Open(128);
    // Jump original ptr if not mocking
    // Save EAX
    ASM_1(ASMINT_OP_PushEAX);
    // Move the mocking on/off flag  to EAX
    ASM_1(ASMINT_OP_movMemToEAX); ASM_4(_@(_Ninja_MaxXPHelper_ThiefScanner_HackIsState)); // todo move just byte
    // Check if mocking flag is on
    // Compare AL == 0 60 == 0x3c == cmp AL imm8 https://www.felixcloutier.com/x86/cmp
    ASM_1(60); ASM_1(0); 
    // Restore EAX in case we jump to original func and do conditional jump.
    ASM_1(ASMINT_OP_popEAX); 
    ASM_2(33807); ASM_4(originalPtr - (ASM_Here() + 4)); // JZ (0f 84 rel32)
    
    // Save EAX again.
    ASM_1(ASMINT_OP_PushEAX);
    // zCParser* __cdecl zCParser::GetParser(void)
    ASM_1(ASMINT_OP_call); ASM_4(7921344 - (ASM_Here() + 4)); // Get parser
    // Call void __thiscall zCParser::SetReturn(zCParser* this, int return)
    //  Save ECX and then store the zCParser* instance
    ASM_1(ASMINT_OP_PushECX);
    ASM_2(ASMINT_OP_movEAXtoECX);
    
    // Move the mock result to EAX and push.
    ASM_1(ASMINT_OP_movMemToEAX); ASM_4(_@(_Ninja_MaxXPHelper_ThiefScanner_FakeIsInStateReturn));
    ASM_1(ASMINT_OP_PushEAX);
    ASM_1(ASMINT_OP_call); ASM_4(7997792 - (ASM_Here() + 4)); // Call, todo const for G2 address
    // Restore the registers this tampered with.
    ASM_1(ASMINT_OP_PopEAX);
    ASM_1(ASMINT_OP_PopECX);
    
    _Ninja_MaxXPHelper_ThiefScanner_NPC_IsInState_HookPtr = ASM_Close();
    symbol.content = _Ninja_MaxXPHelper_ThiefScanner_NPC_IsInState_HookPtr;
};


func void Ninja_MaxXPHelper_ThiefScanner_Init() {
    _Ninja_MaxXPHelper_ThiefScanner_FullyScanned = FALSE;
    _Ninja_MaxXPHelper_ThiefScanner_NextGlobalNpcPtr = 0;
    if Ninja_MaxXPHelper_ThiefScanner_PickpocketableNPCArray {
        MEM_ArrayFree(Ninja_MaxXPHelper_ThiefScanner_PickpocketableNPCArray);
    };
    Ninja_MaxXPHelper_ThiefScanner_PickpocketableNPCArray = MEM_ArrayCreate();
    _Ninja_MaxXPHelper_ThiefScanner_InitTheftDiff();
    Ninja_MaxXPHelper_HT_ClearAndCreate(_@(Ninja_MaxXPHelper_ThiefScanner_PickpocketAlertsHT_Handle), 0);
    Ninja_MaxXPHelper_HT_ClearAndCreate(_@(Ninja_MaxXPHelper_ThiefScanner_NotPickpocktableOnLoadHT), 0);
    Ninja_MaxXPHelper_HT_ClearAndCreate(_@(Ninja_MaxXPHelper_ThiefScanner_NPC_2_PickpocketInfo), 0);
    _Ninja_MaxXPHelper_ThiefScanner_LoadPickpocketInfos();
    
    _Ninja_MaxXPHelper_ThiefScanner_Hook_NPC_IsInState_External();
    FF_ApplyOnceGT(_Ninja_MaxXPHelper_ThiefScanner_RefreshLoop);
};
