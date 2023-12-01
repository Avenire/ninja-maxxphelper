const int Ninja_MaxXPHelper_ThiefScanner_NPC_2_PickpocketInfo = 0;
const int Ninja_MaxXPHelper_ThiefScanner_PickpocketableNPCArray = 0;
var int Ninja_MaxXPHelper_ThiefScanner_PickpocketAlertsHT_Handle;
const int Ninja_MaxXPHelper_ThiefScanner_NotPickpocktableOnLoadHT = 0;
const int _Ninja_MaxXPHelper_ThiefScanner_NextGlobalNpcPtr = 0;
const int _Ninja_MaxXPHelper_ThiefScanner_InitOnce = FALSE;
const int _Ninja_MaxXPHelper_ThiefScanner_NPC_IsInState_HookPtr = 0;
const int _Ninja_MaxXPHelper_ThiefScanner_HackIsState = FALSE;
const int _Ninja_MaxXPHelper_ThiefScanner_FakeIsInStateReturn = TRUE;

func int _Ninja_MaxXPHelper_ThiefScanner_CallCondition(var int condition, var C_NPC npc) {
    var int pickpocketable; pickpocketable = FALSE;
    self = Hlp_GetNpc(npc);
    other = Hlp_GetNpc(hero);
    // Implicit returns are so stupid in Daedalus, default FALSE return val has to be pushed here because plenty of pickpokcet 
    // condition functions only return TRUE explicitly...
    pickpocketable; 
    MEM_CallByID(condition); // And here I am using implicit return, anyway...
};

func int _Ninja_MaxXPHelper_ThiefScanner_CanPickpocketNpc(var C_NPC npc, var int considerFailed) {
    var int instanceId; instanceId = Hlp_GetInstanceID(npc);
    if considerFailed && HT_Has(Ninja_MaxXPHelper_ThiefScanner_PickpocketAlertsHT_Handle, instanceId) {
        return FALSE;
    };
    var int infoPtr; infoPtr = Ninja_MaxXPHelper_HT_Get(Ninja_MaxXPHelper_ThiefScanner_NPC_2_PickpocketInfo, instanceId);
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
    var int instanceId; instanceId = Hlp_GetInstanceID(npc);
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
    var int infoPtr; infoPtr = Ninja_MaxXPHelper_HT_Get(Ninja_MaxXPHelper_ThiefScanner_NPC_2_PickpocketInfo, instanceId);
    if !infoPtr { return Ninja_MaxXPHelper_ThiefScanner_Unknown; };
    var oCInfo info; info = _^(infoPtr);
    var int heroPickpocket; heroPickpocket = Npc_GetTalentSkill(hero, NPC_TALENT_PICKPOCKET);
    var int heroDex; heroDex = hero.attribute[ATR_DEXTERITY];
    Npc_SetTalentSkill(hero, NPC_TALENT_PICKPOCKET, TRUE);
    hero.attribute[ATR_DEXTERITY] = hero.attribute[ATR_DEXTERITY] - Theftdiff;
    _Ninja_MaxXPHelper_ThiefScanner_HackIsState = TRUE;
    _Ninja_MaxXPHelper_ThiefScanner_FakeIsInStateReturn = TRUE;
    var int pickpocketable; pickpocketable = _Ninja_MaxXPHelper_ThiefScanner_CallCondition(info.conditions, npc);
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

// why it returns true when I hack state even though permkap is not tru
func void Ninja_MaxXPHelper_ThiefScanner_Tezt() {
    var c_npc selfBak; selfBak = Hlp_GetNpc(self);


    var c_npc otherBak; otherBak = Hlp_GetNpc(other);
    self = Hlp_GetNpc(BAU_944_Ehnim);
    other = Hlp_GetNpc(hero);
    var int f;
    Ninja_MaxXPHelper_LogInfo(ConcatStrings("DIA_Ehnim_STREIT5_noPerm ", inttostring(DIA_Ehnim_STREIT5_noPerm)));
    _Ninja_MaxXPHelper_ThiefScanner_HackIsState = TRUE;
    _Ninja_MaxXPHelper_ThiefScanner_FakeIsInStateReturn = TRUE;
    f = FALSE;
    f;
    f = DIA_Ehnim_PERMKAP1_Condition();
    _Ninja_MaxXPHelper_ThiefScanner_HackIsState = FALSE;
    
    if f {
        Ninja_MaxXPHelper_LogInfo(ConcatStrings("Oh no it iz tru ", inttostring(f)));
    };
    self = Hlp_GetNpc(selfBak);
    other = Hlp_GetNpc(otherBak);
    
};
const int _Ninja_MaxXPHelper_ThiefScanner_FullyScanned = FALSE;
func void _Ninja_MaxXPHelper_ThiefScanner_RefreshLoop() {
    if !Ninja_MaxXPHelper_ShouldRunHook() {
        return;
    };

    if MEM_KeyState(KEY_Y) == KEY_PRESSED {
        Ninja_MaxXPHelper_ThiefScanner_Tezt();
    };

    if !Ninja_MaxXPHelper_ConsiderPickpocketing { return; };
    var int size; size = MEM_ArraySize(Ninja_MaxXPHelper_ThiefScanner_PickpocketableNPCArray);
    var int idx; 
    if !_Ninja_MaxXPHelper_ThiefScanner_FullyScanned {
        idx = 0;
    };
    var c_npc selfBak; selfBak = Hlp_GetNpc(self);
    var c_npc otherBak; otherBak = Hlp_GetNpc(other);
    var int heroPickpocket; heroPickpocket = Npc_GetTalentSkill(hero, NPC_TALENT_PICKPOCKET);
    var int heroDex; heroDex = hero.attribute[ATR_DEXTERITY];
    Npc_SetTalentSkill(hero, NPC_TALENT_PICKPOCKET, TRUE);
    hero.attribute[ATR_DEXTERITY] = 9999;
    var int processed; processed = 0;
    while (TRUE);
        if idx >= size {
            _Ninja_MaxXPHelper_ThiefScanner_FullyScanned = TRUE;
            idx = 0;
        };
        if _Ninja_MaxXPHelper_ThiefScanner_FullyScanned &&
            processed >= Ninja_MaxXPHelper_XPNPCLocator_MaxNPCToProcessEachFrameBeforeYield {
            break;
        };
        var int instanceId; instanceId = MEM_ArrayRead(Ninja_MaxXPHelper_ThiefScanner_PickpocketableNPCArray, idx);
        idx = idx + 1;
        processed = processed + 1;

        var C_NPC npc; npc = Hlp_GetNpc(instanceId);
        if Hlp_IsValidNpc(npc) && _Ninja_MaxXPHelper_ThiefScanner_CanPickpocketNpc(npc, FALSE) {
            var int instanceId; instanceId = Hlp_GetInstanceID(npc);
            // Magic time
            var int infoPtr; infoPtr = Ninja_MaxXPHelper_HT_Get(Ninja_MaxXPHelper_ThiefScanner_NPC_2_PickpocketInfo, instanceId);
            var oCInfo info; info = _^(infoPtr);
            var int isDead; isDead = Npc_IsDead(npc);
            var int pickpocketable; pickpocketable = !isDead;
            if pickpocketable {
                pickpocketable = _Ninja_MaxXPHelper_ThiefScanner_CallCondition(info.conditions, npc);
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
                HT_Remove(Ninja_MaxXPHelper_ThiefScanner_PickpocketAlertsHT_Handle, instanceId);
                continue;
            };
            // Skip if NPC is alive and wasn't observed to be pickpocketable since last load or was failure was already alerted.
            if (
                (!isDead && Ninja_MaxXPHelper_HT_Get(Ninja_MaxXPHelper_ThiefScanner_NotPickpocktableOnLoadHT, instanceId)) ||
                HT_Has(Ninja_MaxXPHelper_ThiefScanner_PickpocketAlertsHT_Handle, instanceId) ||
                pickpocketable
            ) {
                continue;
            };
            var int color;
            var string msg; msg = "";
            if isDead {
                color = Ninja_MaxXPHelper_DeathAlertsFailColor;
                msg = Ninja_MaxXPHelper_LOC_PickpocketWarningDeath;
            } else {
                color = Ninja_MaxXPHelper_PickpocketAlertsWarningColor;
                msg = Ninja_MaxXPHelper_LOC_PickpocketWarningOther;
            };
            if STR_Len(msg) {
                var int s; s = SB_New();
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
                HT_Insert(Ninja_MaxXPHelper_ThiefScanner_PickpocketAlertsHT_Handle, TRUE, instanceId);
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
    var int symbolPtr; symbolPtr = MEM_GetSymbol("Theftdiff");
    if symbolPtr {
         var zCPar_Symbol s; s = _^(symbolPtr);
         _Ninja_MaxXPHelper_ThiefScanner_TheftDiff = s.content;
    };
};

func int _Ninja_MaxXPHelper_ThiefScanner_CreateBlacklistHT() {
    var int blacklist; blacklist = Ninja_MaxXPHelper_HT_Create();
    STRINT_SplitReset();
    var int count; count = STR_SplitCount(Ninja_MaxXPHelper_PickpocketBlacklist, ";");
    repeat(i, count); var int i;
        var string npcCode; npcCode = STRINT_SplitGet(i);
        var int instanceId; instanceId = MEM_GetSymbolIndex(npcCode);
        Ninja_MaxXPHelper_HT_InsertOrChange(blacklist, instanceId, TRUE);
    end;
    return blacklist;
};

func void _Ninja_MaxXPHelper_ThiefScanner_InsertIntoPickpocketableNPCArray(var int npc, var int value) {
    MEM_ArrayInsert(Ninja_MaxXPHelper_ThiefScanner_PickpocketableNPCArray, npc);
};
func void _Ninja_MaxXPHelper_ThiefScanner_LoadPickpocketInfos() {
    var int blacklist; 
    blacklist = _Ninja_MaxXPHelper_ThiefScanner_CreateBlacklistHT();
    const string pickpocketSuffix = "_PICKPOCKET";
    const string altPickpocketSuffix = "_PICKME"; // Cassia...
    var int pickpocketSuffixLen; pickpocketSuffixLen = STR_Len(pickpocketSuffix);
    var int listPtr; listPtr = _@(MEM_InfoMan.infoList_compare);
    while (listPtr);
        var zCListSort list; list = _^(listPtr);
        listPtr = list.next;
        if list.data {            
            var oCInfo info; info = _^(list.data);
            if Ninja_MaxXPHelper_HT_Has(blacklist, info.npc) { continue; };
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
    var int originalPtr; originalPtr = symbol.content;
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
    if !HLP_IsValidHandle(Ninja_MaxXPHelper_ThiefScanner_PickpocketAlertsHT_Handle) {
        Ninja_MaxXPHelper_ThiefScanner_PickpocketAlertsHT_Handle = HT_Create();
    };
    if Ninja_MaxXPHelper_ThiefScanner_PickpocketableNPCArray {
        MEM_ArrayFree(Ninja_MaxXPHelper_ThiefScanner_PickpocketableNPCArray);
    };
    Ninja_MaxXPHelper_ThiefScanner_PickpocketableNPCArray = MEM_ArrayCreate();
    _Ninja_MaxXPHelper_ThiefScanner_InitTheftDiff();
    Ninja_MaxXPHelper_HT_ClearAndCreate(_@(Ninja_MaxXPHelper_ThiefScanner_NotPickpocktableOnLoadHT), 0);
    Ninja_MaxXPHelper_HT_ClearAndCreate(_@(Ninja_MaxXPHelper_ThiefScanner_NPC_2_PickpocketInfo), 0);
    _Ninja_MaxXPHelper_ThiefScanner_LoadPickpocketInfos();
    
    _Ninja_MaxXPHelper_ThiefScanner_Hook_NPC_IsInState_External();
    FF_ApplyOnceGT(_Ninja_MaxXPHelper_ThiefScanner_RefreshLoop);
    //HookDaedalusFuncS("DIA_Ehnim_PERMKAP1_Condition", "DIA_Ehnim_PERMKAP1_Condition_");
};
