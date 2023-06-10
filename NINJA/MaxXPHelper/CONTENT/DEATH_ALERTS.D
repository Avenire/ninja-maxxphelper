const int _Ninja_MaxXPHelper_DeathAlerts_DeadOnArrivalNpc_HT = 0;
const int _Ninja_MaxXPHelper_DeathAlerts_B_MagicHurtNpc_Killed_To_RealKiller_HT = 0;
const int _Ninja_MaxXPHelper_DeathAlerts_AlertIdToTrackerId_HT = 0;
const int _Ninja_MaxXPHelper_DeathAlerts_LastSVM = 0;
const int _Ninja_MaxXPHelper_DeathAlerts_SVMThrottleInMillis = 10000;

func void Ninja_MaxXPHelper_DeathAlerts_InitDeadOnArrivalNPCList() {
    STRINT_SplitReset();
    var int count; count = STR_SplitCount(Ninja_MaxXPHelper_DeadOnArrivalNPCList, ";");
    Ninja_MaxXPHelper_HT_DestroyPtr(_Ninja_MaxXPHelper_DeathAlerts_DeadOnArrivalNpc_HT);
    _Ninja_MaxXPHelper_DeathAlerts_DeadOnArrivalNpc_HT = Ninja_MaxXPHelper_HT_Create();
    repeat(i, count); var int i;
        var string npcCode; npcCode = STRINT_SplitGet(i);
        var int instanceId; instanceId = MEM_GetSymbolIndex(npcCode);
        if Ninja_MaxXPHelper_HT_Get(
            _Ninja_MaxXPHelper_DeathAlerts_DeadOnArrivalNpc_HT,
            instanceId
        ) > 0 {
            continue;
        };
        if instanceId > -1 {
            Ninja_MaxXPHelper_HT_Insert(
                _Ninja_MaxXPHelper_DeathAlerts_DeadOnArrivalNpc_HT,
                TRUE,
                instanceId
            );
        };
    end;
};

func int _Ninja_MaxXPHelper_DeathAlerts_Handler_SkipDeadOnArrivalNPC(var c_npc _self) {
    Ninja_MaxXPHelper_LogInfo("_Ninja_MaxXPHelper_DeathAlerts_Handler_SkipDeadOnArrivalNPC");
    var int instanceId; instanceId = Hlp_GetInstanceID(_self);
    return Ninja_MaxXPHelper_HT_Get(_Ninja_MaxXPHelper_DeathAlerts_DeadOnArrivalNpc_HT, instanceId);
};

func void _Ninja_MaxXPHelper_DeathAlerts_AutoExpireTrackerOnAlertShown(var int alertHandle) {
    var int trackerHandle; trackerHandle = Ninja_MaxXPHelper_HT_Get(_Ninja_MaxXPHelper_DeathAlerts_AlertIdToTrackerId_HT, alertHandle);
    Ninja_MaxXPHelper_Trackers_SetAutoExpire(trackerHandle, _Ninja_MaxXPHelper_TextAlerts_Duration);
    if  STR_Len(Ninja_MaxXPHelper_DeathAlertsSVM) > 0 && 
        !Npc_IsDead(hero) && 
        TimerGT() - _Ninja_MaxXPHelper_DeathAlerts_LastSVM > _Ninja_MaxXPHelper_DeathAlerts_SVMThrottleInMillis {
        AI_OutputSVM_Overlay(hero,hero,Ninja_MaxXPHelper_DeathAlertsSVM);
        _Ninja_MaxXPHelper_DeathAlerts_LastSVM = TimerGT();
    };
};

func void _Ninja_MaxXPHelper_DeathAlerts_TriggerAlert(var c_npc cnpc, var string msg) {
    var int alertHandle; alertHandle = Ninja_MaxXPHelper_TextAlerts_Create(
        msg,  _Ninja_MaxXPHelper_TextAlerts_Duration, Ninja_MaxXPHelper_DeathAlertsFailColor, FALSE
    );
    
    var oCNPC npc; npc = Hlp_GetNpc(cnpc);
    if Ninja_MaxXPHelper_IsNpcSpawned(npc) {
        var int h; h = Ninja_MaxXPHelper_Trackers_Create();
        Ninja_MaxXPHelper_HT_Insert(_Ninja_MaxXPHelper_DeathAlerts_AlertIdToTrackerId_HT, h, alertHandle);
        Ninja_MaxXPHelper_TextAlerts_SetOnShowFunc(alertHandle, _Ninja_MaxXPHelper_DeathAlerts_AutoExpireTrackerOnAlertShown);
        var int x; x = npc._zCVob_trafoObjToWorld[3];
        var int y; y = npc._zCVob_trafoObjToWorld[7];
        var int z; z = npc._zCVob_trafoObjToWorld[11];
        Ninja_MaxXPHelper_Trackers_Show(
            h,
            x, y, z,
            Ninja_MaxXPHelper_DeathAlertsFailColor, 
            Ninja_MaxXPHelper_Trackers_MaxPriority,
            "MAXXPHELPER_DEATH_ALERT.tga",
            mulf(Ninja_MaxXPHelper_IconSize, FLOATHALF),
            0
        );
    };
};
const int Ninja_MaxXPHelper_DeathAlerts_Init_Once = 0;
func void Ninja_MaxXPHelper_DeathAlerts_Init() {
    _Ninja_MaxXPHelper_DeathAlerts_LastSVM = 0;
    Ninja_MaxXPHelper_HT_DestroyPtr(_Ninja_MaxXPHelper_DeathAlerts_AlertIdToTrackerId_HT);
    Ninja_MaxXPHelper_HT_DestroyPtr(_Ninja_MaxXPHelper_DeathAlerts_B_MagicHurtNpc_Killed_To_RealKiller_HT);
    Ninja_MaxXPHelper_HT_DestroyPtr(_Ninja_MaxXPHelper_DeathAlerts_AlertIdToTrackerId_HT);

    _Ninja_MaxXPHelper_DeathAlerts_AlertIdToTrackerId_HT = Ninja_MaxXPHelper_HT_Create();
    _Ninja_MaxXPHelper_DeathAlerts_B_MagicHurtNpc_Killed_To_RealKiller_HT = Ninja_MaxXPHelper_HT_Create();
    _Ninja_MaxXPHelper_DeathAlerts_AlertIdToTrackerId_HT = Ninja_MaxXPHelper_HT_Create();

    Ninja_MaxXPHelper_DeathAlerts_InitDeadOnArrivalNPCList();
    if !Ninja_MaxXPHelper_DeathAlerts_Init_Once {
        HookDaedalusFuncS("ZS_Dead", "Ninja_MaxXPHelper_ZS_Dead_Hook");
        HookDaedalusFuncS("B_RemoveNpc", "Ninja_MaxXPHelper_B_RemoveNpc_Hook");
        HookDaedalusFuncS("B_KillNpc", "Ninja_MaxXPHelper_B_KillNpc_Hook");
        HookDaedalusFuncS("B_MagicHurtNpc", "Ninja_MaxXPHelper_B_MagicHurtNpc_Hook");
        Ninja_MaxXPHelper_DeathAlerts_Init_Once = 1;
    };
};

func int _Ninja_MaxXPHelper_DeathAlerts_Handler_SkipLevelZeroNPC(var c_npc _self) {
    Ninja_MaxXPHelper_LogInfo("_Ninja_MaxXPHelper_DeathAlerts_Handler_SkipLevelZeroNPC");
    // Ignore NPCs like Mud or summons in G2.
    return (
        !Ninja_MaxXPHelper_ConsiderLevelZeroNPC &&
        _self.level <= 0
    );
};

func int _Ninja_MaxXPHelper_DeathAlerts_Handler_SkipPlayerDeath(var c_npc _self) {
    Ninja_MaxXPHelper_LogInfo("_Ninja_MaxXPHelper_DeathAlerts_Handler_SkipPlayerDeath");
    return Npc_IsPlayer(_self);
};

func int _Ninja_MaxXPHelper_DeathAlerts_Handler_SkipIfDefeatedAndNoDoubleXPMode(var c_npc _self) {
    Ninja_MaxXPHelper_LogInfo("_Ninja_MaxXPHelper_DeathAlerts_Handler_SkipIfDefeatedAndNoDoubleXPMode");
    return !(Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch || !Ninja_MaxXPHelper_VictoryXPReceived(_self));
};

func int _Ninja_MaxXPHelper_DeathAlerts_Handler_NPCDiedAndWasNotBeatenBeforeAndDoubleXPGlitchOn(var c_npc _self, var c_npc _other) {
    Ninja_MaxXPHelper_LogInfo("_Ninja_MaxXPHelper_DeathAlerts_Handler_NPCDiedAndWasNotBeatenBeforeAndDoubleXPGlitchOn");
    // If we consider double XP glitch - human NPC died, hero didn't beat them, no matter who's the killer - we lose XP.
    if	Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch &&
        !Ninja_MaxXPHelper_VictoryXPReceived(_self) &&
        Ninja_MaxXPHelper_IsKnockable(_other, _self) {
            var int s; s = SB_New();
            SB(Ninja_MaxXPHelper_LOC_RIPPrefix);
            SB(_self.name);
            SB(" ");
            SB(Ninja_MaxXPHelper_LOC_DoubleXPNoZSUnconsciousXP);
            _Ninja_MaxXPHelper_DeathAlerts_TriggerAlert(_self, SB_ToString());
            SB_Clear();
            SB_Destroy();
            return TRUE;
    };
    return FALSE;
};

func int _Ninja_MaxXPHelper_DeathAlerts_Handler_NPCDiedAndPlayerCouldLoseXP(var c_npc _self, var c_npc _other) {
    Ninja_MaxXPHelper_LogInfo("_Ninja_MaxXPHelper_DeathAlerts_Handler_NPCDiedAndPlayerCouldLoseXP");
    var int B_MagicHurtNpc_actual_attacker; B_MagicHurtNpc_actual_attacker = Ninja_MaxXPHelper_HT_Get(
        _Ninja_MaxXPHelper_DeathAlerts_B_MagicHurtNpc_Killed_To_RealKiller_HT,
        _@(_self)
    );
    if B_MagicHurtNpc_actual_attacker {
        _other = _^(B_MagicHurtNpc_actual_attacker);
    };
    Ninja_MaxXPHelper_LogInfo(ConcatStrings("_Ninja_MaxXPHelper_DeathAlerts_Handler_NPCDiedAndPlayerCouldLoseXP other=", _other.name));
    var int playerGetsXP; playerGetsXP = Ninja_MaxXPHelper_WouldReceiveVictoryXP(_self, _other); 
    if  Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch && 
        playerGetsXP &&
        Npc_WasInState(_self, ZS_UNCONSCIOUS) && 
        Npc_IsInFightMode(_other, FMODE_MELEE) {
        var int s; s = SB_New();
        SB(Ninja_MaxXPHelper_LOC_RIPPrefix);
        SB(_self.name);
        SB(" ");
        SB(Ninja_MaxXPHelper_LOC_DoubleXPMeleeFinisherTip);
        _Ninja_MaxXPHelper_DeathAlerts_TriggerAlert(_self, SB_ToString());
        SB_Clear();
        SB_Destroy();
        return TRUE;
    }
    else if !playerGetsXP {
        // Now XP was 99% sure lost so alert.
        var int s; s = SB_New();
        SB(Ninja_MaxXPHelper_LOC_RIPPrefix);
        SB(_self.name);
        _Ninja_MaxXPHelper_DeathAlerts_TriggerAlert(_self, SB_ToString());
        SB_Clear();
        SB_Destroy();
        return TRUE;
    };
    return FALSE;
};

func int _Ninja_MaxXPHelper_DeathAlerts_Handler_SkipIfNpcWasAlreadyDead(var c_npc _self) {
    Ninja_MaxXPHelper_LogInfo("_Ninja_MaxXPHelper_DeathAlerts_Handler_SkipIfNpcWasAlreadyDead");
    // Sometimes NPC glitch and ZS_Dead gets called multiple time - for example Orc Scout in front of the entrance
    // to Orcish Cemetery in G1 CH3. If you enter and exit the cemetery, orc will fall dead again...
    return Npc_WasInState(_self, ZS_Dead);
};

func int _Ninja_MaxXPHelper_DeathAlerts_Handler_StoryScriptedDeath(var int npcInstance) {
    Ninja_MaxXPHelper_LogInfo("_Ninja_MaxXPHelper_DeathAlerts_Handler_StoryScriptedDeath");
    var oCNPC npc; npc = Hlp_GetNpc(npcInstance);
    var c_npc cnpc; cnpc = Hlp_GetNpc(npcInstance);
    // todo: handle G2 cases where mortal NPCs travel worlds between chapters (Diego CH2->CH3, Gorn CH2, CH3, CH4...)
    if  // testing note: Should be false only for off-screen kill? Would need to check range otherwise.
        !npc.percActive && 
        // Skip immortal NPC
        !( cnpc.flags & NPC_FLAG_IMMORTAL) {
        Ninja_MaxXPHelper_LogInfo(ConcatStrings("_Ninja_MaxXPHelper_DeathAlerts_Handler_StoryScriptedDeath active ", npc.name));
        var int s; s = SB_New();
        SB(Ninja_MaxXPHelper_LOC_RIPPrefix);
        SB(npc.name);
        SB(" ");
        SB(Ninja_MaxXPHelper_LOC_ScriptedDeathTip);
        _Ninja_MaxXPHelper_DeathAlerts_TriggerAlert(cnpc, SB_ToString());
        SB_Clear();
        SB_Destroy();
        return TRUE;
    };
    return FALSE;
};

func void Ninja_MaxXPHelper_ZS_Dead_Hook() {
    if !Ninja_MaxXPHelper_ShouldRunHook() {
        return;
    };
    var c_npc _self; _self = Hlp_GetNpc (self);
    var c_npc _other; _other = Hlp_GetNpc (other);
    Ninja_MaxXPHelper_LogInfo(ConcatStrings("ZS_Dead killed ", _self.name));
    Ninja_MaxXPHelper_LogInfo(ConcatStrings("ZS_Dead killer ", _other.name));
    var int handled; handled = !Ninja_MaxXPHelper_ShowMissedXPOnNPCDeathAlerts;
    if !handled {
        handled = _Ninja_MaxXPHelper_DeathAlerts_Handler_SkipPlayerDeath(_self);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_DeathAlerts_Handler_SkipIfDefeatedAndNoDoubleXPMode(_self);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_DeathAlerts_Handler_SkipIfNpcWasAlreadyDead(_self);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_DeathAlerts_Handler_SkipLevelZeroNPC(_self);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_DeathAlerts_Handler_SkipDeadOnArrivalNPC(_self);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_DeathAlerts_Handler_NPCDiedAndWasNotBeatenBeforeAndDoubleXPGlitchOn(_self, _other);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_DeathAlerts_Handler_NPCDiedAndPlayerCouldLoseXP(_self, _other);
    };
    ContinueCall();
};

func void Ninja_MaxXPHelper_B_KillNpc_Hook(var int npcInstance) {
    if !Ninja_MaxXPHelper_ShouldRunHook() {
        return;
    };
    var int handled; handled = !Ninja_MaxXPHelper_ShowMissedXPOnNPCDeathAlerts;
    var c_npc cnpc; cnpc = Hlp_GetNpc(npcInstance);
    Ninja_MaxXPHelper_LogInfo(ConcatStrings("B_KillNpc ", cnpc.name));
    if !handled {
        // Should never happen?
        handled = _Ninja_MaxXPHelper_DeathAlerts_Handler_SkipPlayerDeath(cnpc);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_DeathAlerts_Handler_SkipIfDefeatedAndNoDoubleXPMode(cnpc);
    };
    if !handled {
        //handled = _Ninja_MaxXPHelper_DeathAlerts_Handler_SkipIfNpcWasAlreadyDead(cnpc);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_DeathAlerts_Handler_SkipLevelZeroNPC(cnpc);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_DeathAlerts_Handler_SkipDeadOnArrivalNPC(cnpc);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_DeathAlerts_Handler_StoryScriptedDeath(npcInstance);
    };
    PassArgumentI(npcInstance);
    ContinueCall();
};

func void Ninja_MaxXPHelper_B_MagicHurtNpc_Hook(var C_NPC attacker, var int damage) {
    if !Ninja_MaxXPHelper_ShouldRunHook() {
        return;
    };
    PassArgumentN(attacker);
    PassArgumentI(damage);
    ContinueCall();
    if Npc_IsDead(self) {
        // Death XP of NPC killed by DOT stun spell like pyrokinesis could also happen in B_MagicHurtNpc.
        // ZS_Dead might be called after this script with invalid (empty) NPC set as killer ("other" variable) which 
        // would trigger false positive alert.
        // To reproduce - spawn character helper, beat him, when he's up finish him off with a single cast of pyrokinesis.
        Ninja_MaxXPHelper_HT_Insert(_Ninja_MaxXPHelper_DeathAlerts_B_MagicHurtNpc_Killed_To_RealKiller_HT, _@(attacker), _@(self));
    };
};

func void Ninja_MaxXPHelper_B_RemoveNpc_Hook(var int npcInstance) {
    if !Ninja_MaxXPHelper_ShouldRunHook() {
        return;
    };
    var c_npc cnpc; cnpc = Hlp_GetNpc(npcInstance);
    Ninja_MaxXPHelper_LogInfo(ConcatStrings("B_RemoveNpc: ", cnpc.name));
    var int handled; handled = !Ninja_MaxXPHelper_ShowMissedXPOnNPCDeathAlerts;
    if !handled {
        Ninja_MaxXPHelper_LogInfo("_Ninja_MaxXPHelper_DeathAlerts_Handler_SkipPlayerDeath");
        handled = _Ninja_MaxXPHelper_DeathAlerts_Handler_SkipPlayerDeath(cnpc);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_DeathAlerts_Handler_SkipIfDefeatedAndNoDoubleXPMode(cnpc);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_DeathAlerts_Handler_SkipIfNpcWasAlreadyDead(cnpc);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_DeathAlerts_Handler_SkipLevelZeroNPC(cnpc);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_DeathAlerts_Handler_SkipDeadOnArrivalNPC(cnpc);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_DeathAlerts_Handler_StoryScriptedDeath(npcInstance);
    };
    PassArgumentI(npcInstance);
    ContinueCall();
};