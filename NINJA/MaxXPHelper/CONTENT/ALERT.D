// Seems I can't use it to declare array size, bummer.
const int _Ninja_MaxXPHelper_DeadAlerts_DeadSpheresArrElementSize = 2;
// Too lazy to use actual class and allocate some list of instances.
const int _Ninja_MaxXPHelper_DeadSpheres[10] = {
    0, 0,
    0, 0,
    0, 0,
    0, 0,
    0, 0
};
const int _Ninja_MaxXPHelper_DeadAlerts_ActiveAlertsCount = 0;
const int _Ninja_MaxXPHelper_DeadAlerts_LastAlertTimestamp = 0;
const int _Ninja_MaxXPHelper_DeadAlerts_MaxAlerts = 5;

const int _Ninja_MaxXPHelper_DeadAlerts_AlertTimeInSeconds = 20;
const int _Ninja_MaxXPHelper_DeadAlerts_DeadSphereVisibilityInSeconds = 60;
const int _Ninja_MaxXPHelper_DeadAlerts_B_MagicHurtNpc_Killed_To_RealKiller_Hashtable = 0;
const int _Ninja_MaxXPHelper_DeadAlerts_DeadOnArrivalNpc_Hashtable = 0;

func void _Ninja_MaxXPHelper_AddDeadNPCSphere(var int npc) {
    var int idx; idx = _Ninja_MaxXPHelper_DeadAlerts_ActiveAlertsCount * _Ninja_MaxXPHelper_DeadAlerts_DeadSpheresArrElementSize;
    var int timestamp; timestamp = MEM_GetSystemTime();
    MEM_WriteIntArray(_@(_Ninja_MaxXPHelper_DeadSpheres), idx, npc);
    MEM_WriteIntArray(_@(_Ninja_MaxXPHelper_DeadSpheres), idx + 1, timestamp);
};

func int _Ninja_MaxXPHelper_Handler_SkipLevelZeroNPC(var c_npc self) {
    Ninja_MaxXPHelper_LogInfo("_Ninja_MaxXPHelper_Handler_SkipLevelZeroNPC");
    // Ignore NPCs like Mud or summons in G2.
    if !Ninja_MaxXPHelper_ConsiderLevelZeroNPC &&
        self.level <= 0 {
            return 1;
    };
    return 0;
};

func int _Ninja_MaxXPHelper_Handler_SkipPlayerDeath(var c_npc self) {
    Ninja_MaxXPHelper_LogInfo("_Ninja_MaxXPHelper_Handler_SkipPlayerDeath");
    return Npc_IsPlayer(self);
};

func int _Ninja_MaxXPHelper_Handler_SkipIfDefeatedAndNoDoubleXPMode(var c_npc self) {
    Ninja_MaxXPHelper_LogInfo("_Ninja_MaxXPHelper_Handler_SkipIfDefeatedAndNoDoubleXPMode");
    return !(Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch || !Ninja_MaxXPHelper_VictoryXPReceived(self));
};

func void _Ninja_MaxXPHelper_TriggerAlert(var c_npc npc, var string msg) {
    PrintScreen(
        msg, 
        -1,
        5 + _Ninja_MaxXPHelper_DeadAlerts_ActiveAlertsCount * 5,
        "FONT_OLD_20_WHITE.tga",
        _Ninja_MaxXPHelper_DeadAlerts_AlertTimeInSeconds
    );
    _Ninja_MaxXPHelper_AddDeadNPCSphere(_@(npc));
    _Ninja_MaxXPHelper_DeadAlerts_ActiveAlertsCount = _Ninja_MaxXPHelper_DeadAlerts_ActiveAlertsCount + 1;
    _Ninja_MaxXPHelper_DeadAlerts_LastAlertTimestamp = MEM_GetSystemTime();
};

func void _Ninja_MaxXPHelper_DeadAlerts_LoadDeadOnArrivalNpcs() {
    var string deadOnArrivalNPCs; deadOnArrivalNPCs = DefaultDeadOnArrivalNPCs;
    const string optionKey = "deadOnArrivalNPCs";
    if MEM_GothOptExists(Ninja_MaxXPHelper_SectionName, optionKey) {
        deadOnArrivalNPCs = MEM_GetGothOpt(Ninja_MaxXPHelper_SectionName, optionKey);
    } else {
        MEM_SetGothOpt(Ninja_MaxXPHelper_SectionName, optionKey, deadOnArrivalNPCs);
    };
    STRINT_SplitReset();
    var int count; count = STR_SplitCount(deadOnArrivalNPCs, ";");
    _Ninja_MaxXPHelper_DeadAlerts_DeadOnArrivalNpc_Hashtable = HT_Create();
    repeat(i, count); var int i;
        var string npcCode; npcCode = STRINT_SplitGet(i);
        var zCPar_Symbol npcSymbol; npcSymbol = _^(MEM_GetSymbol(npcCode));
        var c_npc npc; npc = _^(npcSymbol.content);
        if Hlp_IsValidNpc(npc) && !Npc_IsDead(npc) {
            HT_Insert(_Ninja_MaxXPHelper_DeadAlerts_DeadOnArrivalNpc_Hashtable, _@(npc), TRUE);
        };
    end;

};

// todo: localization
func int _Ninja_MaxXPHelper_Handler_NPCDiedAndWasNotBeatenBeforeAndDoubleXPGlitchOn(var c_npc _self, var c_npc _other) {
    Ninja_MaxXPHelper_LogInfo("_Ninja_MaxXPHelper_Handler_NPCDiedAndWasNotBeatenBeforeAndDoubleXPGlitchOn");
    // If we consider double XP glitch - human NPC died, hero didn't beat them, no matter who's the killer - we lose XP.
    if	Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch &&
        !Ninja_MaxXPHelper_VictoryXPReceived(_self) &&
        Ninja_MaxXPHelper_IsKnockable(_self, _other) {
            var int s; s = SB_New();
            SB("RIP: ");
            SB(_self.name);
            SB(", that died without claiming Victory XP first (missed double XP)");
            _Ninja_MaxXPHelper_TriggerAlert(_self, SB_ToString());
            SB_Clear();
            SB_Destroy();
            return 1;
    };
    return 0;
};

func int _Ninja_MaxXPHelper_Handler_SkipDeadOnArrivalNPC(var c_npc self) {
    Ninja_MaxXPHelper_LogInfo("_Ninja_MaxXPHelper_Handler_SkipDeadOnArrivalNPC");
    return !!HT_Get(_Ninja_MaxXPHelper_DeadAlerts_DeadOnArrivalNpc_Hashtable, _@(self));
};

// todo: localization
func int _Ninja_MaxXPHelper_Handler_NPCDiedAndPlayerCouldLoseXP(var c_npc self, var c_npc other) {
    Ninja_MaxXPHelper_LogInfo("_Ninja_MaxXPHelper_Handler_NPCDiedAndPlayerCouldLoseXP");
    var int B_MagicHurtNpc_actual_attacker; B_MagicHurtNpc_actual_attacker = HT_Get(
        _Ninja_MaxXPHelper_DeadAlerts_B_MagicHurtNpc_Killed_To_RealKiller_Hashtable, _@(self)
    );
    if B_MagicHurtNpc_actual_attacker {
        other = _^(B_MagicHurtNpc_actual_attacker);
    };
    var int playerGetsXP; playerGetsXP = Ninja_MaxXPHelper_WouldReceiveVictoryXP(self, other); 
    if  Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch && 
        playerGetsXP &&
        Npc_WasInState(self,ZS_UNCONSCIOUS) && 
        Npc_IsInFightMode(other,FMODE_MELEE) {
        var int s; s = SB_New();
        SB("RIP: ");
        SB(self.name);
        SB(", that died from melee finishing move (missed double XP)");
        _Ninja_MaxXPHelper_TriggerAlert(self, SB_ToString());
        SB_Clear();
        SB_Destroy();
        return 1;
    }
    else if !playerGetsXP {
        // Now XP was 99% sure lost so alert.
        var int s; s = SB_New();
        SB("RIP: ");
        SB(self.name);
        _Ninja_MaxXPHelper_TriggerAlert(self, SB_ToString());
        SB_Clear();
        SB_Destroy();
        return 1;
    };
    return 0;
};

func int _Ninja_MaxXPHelper_Handler_SkipIfNpcWasAlreadyDead(var c_npc self) {
    Ninja_MaxXPHelper_LogInfo("_Ninja_MaxXPHelper_Handler_SkipIfNpcWasAlreadyDead");
    // Sometimes NPC glitch and ZS_Dead gets called multiple time - for example Orc Scout in front of the entrance
    // to Orcish Cemetery in G1 CH3. If you enter and exit the cemetery, orc will fall dead again...
    return Npc_WasInState(self, ZS_Dead);
};

func int _Ninja_MaxXPHelper_Handler_SkipIfThrottled() {
    Ninja_MaxXPHelper_LogInfo("_Ninja_MaxXPHelper_Handler_SkipIfThrottled");
    // Reset if last alert alredy expired (not perfect but whatever, you'd need to reload after seeing the first alert anyway...)
    if MEM_GetSystemTime() - _Ninja_MaxXPHelper_DeadAlerts_LastAlertTimestamp > _Ninja_MaxXPHelper_DeadAlerts_AlertTimeInSeconds * 1000 {
        _Ninja_MaxXPHelper_DeadAlerts_ActiveAlertsCount = 0;
    };
    // Some throttling as it looks weird if some story genocide happens (like Gothic 1's CH4 beggining)
    if _Ninja_MaxXPHelper_DeadAlerts_ActiveAlertsCount >= _Ninja_MaxXPHelper_DeadAlerts_MaxAlerts {
        return 1;
    };
    return 0;
};

// todo: localization
func int _Ninja_MaxXPHelper_Handler_StoryScriptedDeath(var int npcInstance) {
    Ninja_MaxXPHelper_LogInfo("_Ninja_MaxXPHelper_Handler_StoryScriptedDeath");
    var oCNPC npc; npc = Hlp_GetNpc(npcInstance);
    var c_npc cnpc; cnpc = Hlp_GetNpc(npcInstance);
    // todo: handle G2 cases where mortal NPCs travel worlds between chapters (Diego CH2->CH3, Gorn CH2, CH3, CH4...)
    if  // testing note: Should be false only for off-screen kill? Would need to check range otherwise.
        !npc.percActive && 
        // Skip immortal NPC
        !( cnpc.flags & NPC_FLAG_IMMORTAL) {
        Ninja_MaxXPHelper_LogInfo(ConcatStrings("_Ninja_MaxXPHelper_Handler_StoryScriptedDeath active ", npc.name));
        var int s; s = SB_New();
        SB("RIP: ");
        SB(npc.name);
        SB(", that died off-screen by game script B_KillNpc");
        _Ninja_MaxXPHelper_TriggerAlert(cnpc, SB_ToString());
        SB_Clear();
        SB_Destroy();
        return 1;
    };
    return 0;
};

// todo: hook B_MagicHurtNpc because apparently it's relevant for double XP glitch
func void Ninja_MaxXPHelper_ZS_Dead_Hook() {
    var int handled; handled = !Ninja_MaxXPHelper_ShowMissedXPOnNPCDeathAlerts;
    if !handled {
        handled = _Ninja_MaxXPHelper_Handler_SkipPlayerDeath(self);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_Handler_SkipIfThrottled();
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_Handler_SkipIfDefeatedAndNoDoubleXPMode(self);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_Handler_SkipIfNpcWasAlreadyDead(self);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_Handler_SkipLevelZeroNPC(self);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_Handler_SkipDeadOnArrivalNPC(self);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_Handler_NPCDiedAndWasNotBeatenBeforeAndDoubleXPGlitchOn(self, other);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_Handler_NPCDiedAndPlayerCouldLoseXP(self, other);
    };
    ContinueCall();
};

// todo: localization
func void Ninja_MaxXPHelper_B_KillNpc_Hook(var int npcInstance) {
    var int handled; handled = !Ninja_MaxXPHelper_ShowMissedXPOnNPCDeathAlerts;
    var c_npc cnpc; cnpc = Hlp_GetNpc(npcInstance);
    Ninja_MaxXPHelper_LogInfo(ConcatStrings("B_KillNpc ", cnpc.name));
    if !handled {
        // Should never happen?
        handled = _Ninja_MaxXPHelper_Handler_SkipPlayerDeath(cnpc);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_Handler_SkipIfThrottled();
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_Handler_SkipIfDefeatedAndNoDoubleXPMode(cnpc);
    };
    if !handled {
        //handled = _Ninja_MaxXPHelper_Handler_SkipIfNpcWasAlreadyDead(cnpc);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_Handler_SkipLevelZeroNPC(cnpc);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_Handler_SkipDeadOnArrivalNPC(cnpc);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_Handler_StoryScriptedDeath(npcInstance);
    };
    PassArgumentI(npcInstance);
    ContinueCall();
};

func void Ninja_MaxXPHelper_DrawDeadNPCSpheres() {
    repeat(i, _Ninja_MaxXPHelper_DeadAlerts_ActiveAlertsCount); var int i;
        var int idx; idx = i * _Ninja_MaxXPHelper_DeadAlerts_DeadSpheresArrElementSize;
        var int npcPtr; npcPtr = MEM_ReadStatArr(_@(_Ninja_MaxXPHelper_DeadSpheres), idx);
        var int timestamp; timestamp = MEM_ReadIntArray(_@(_Ninja_MaxXPHelper_DeadSpheres), idx + 1);
        if npcPtr && (MEM_GetSystemTime() - timestamp) < _Ninja_MaxXPHelper_DeadAlerts_DeadSphereVisibilityInSeconds*1000 {
            var oCNPC npc; npc = _^(npcPtr);
            Ninja_MaxXPHelper_DrawNPCSphere(npc, Ninja_MaxXPHelper_SphereColorDeathAlert, Ninja_MaxXPHelper_SphereRadius);
        };
    end;
};

func void _Ninja_MaxXPHelper_ClearHashTableKey(var int key, var int _) {
    HT_Remove(_Ninja_MaxXPHelper_DeadAlerts_B_MagicHurtNpc_Killed_To_RealKiller_Hashtable,key);   
};

func void Ninja_MaxXPHelper_ResetAlerts() {
    _Ninja_MaxXPHelper_DeadAlerts_LoadDeadOnArrivalNpcs();
    _Ninja_MaxXPHelper_DeadAlerts_B_MagicHurtNpc_Killed_To_RealKiller_Hashtable = HT_Create();
    repeat(i, _Ninja_MaxXPHelper_DeadAlerts_ActiveAlertsCount); var int i;
        var int idx; idx = i * _Ninja_MaxXPHelper_DeadAlerts_DeadSpheresArrElementSize;
        MEM_WriteIntArray(_@(_Ninja_MaxXPHelper_DeadSpheres), idx, 0);
        MEM_WriteIntArray(_@(_Ninja_MaxXPHelper_DeadSpheres), idx + 1, 0);
    end;
    _Ninja_MaxXPHelper_DeadAlerts_ActiveAlertsCount = 0;
};

func void Ninja_MaxXPHelper_B_MagicHurtNpc_Hook(var C_NPC attacker, var int damage) {
    PassArgumentN(attacker);
    PassArgumentI(damage);
    ContinueCall();
    if Npc_IsDead(self) {
        // Death XP of NPC killed by DOT stun spell like pyrokinesis could also happen in B_MagicHurtNpc.
        // ZS_Dead might be called after this script with invalid (empty) NPC set as killer ("other" variable) which 
        // would trigger false positive alert.
        // To reproduce - spawn character helper, beat him, when he's up finish him off with a single cast of pyrokinesis.
        HT_Insert(_Ninja_MaxXPHelper_DeadAlerts_B_MagicHurtNpc_Killed_To_RealKiller_Hashtable, _@(attacker), _@(self));
    };
};

func void Ninja_MaxXPHelper_B_RemoveNpc_Hook(var int npcInstance) {
    var c_npc cnpc; cnpc = Hlp_GetNpc(npcInstance);
    Ninja_MaxXPHelper_LogInfo(ConcatStrings("B_RemoveNpc: ", cnpc.name));
    var int handled; handled = !Ninja_MaxXPHelper_ShowMissedXPOnNPCDeathAlerts;
    if !handled {
        Ninja_MaxXPHelper_LogInfo("_Ninja_MaxXPHelper_Handler_SkipPlayerDeath");
        handled = _Ninja_MaxXPHelper_Handler_SkipPlayerDeath(cnpc);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_Handler_SkipIfThrottled();
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_Handler_SkipIfDefeatedAndNoDoubleXPMode(cnpc);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_Handler_SkipIfNpcWasAlreadyDead(cnpc);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_Handler_SkipLevelZeroNPC(cnpc);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_Handler_SkipDeadOnArrivalNPC(cnpc);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_Handler_StoryScriptedDeath(npcInstance);
    };
    PassArgumentI(npcInstance);
    ContinueCall();
};