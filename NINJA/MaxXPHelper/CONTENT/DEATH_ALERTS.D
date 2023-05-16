const int _Ninja_MaxXPHelper_DeathAlerts_B_MagicHurtNpc_Killed_To_RealKiller_Hashtable = -1;
const int _Ninja_MaxXPHelper_DeathAlerts_DeadOnArrivalNpc_Hashtable = -1;

func void Ninja_MaxXPHelper_DeathAlerts_Init() {
    Ninja_MaxXPHelper_LogInfo("Ninja_MaxXPHelper_DeathAlerts_Init");
    _Ninja_MaxXPHelper_DeathAlerts_B_MagicHurtNpc_Killed_To_RealKiller_Hashtable = HT_Create();
    STRINT_SplitReset();
    var int count; count = STR_SplitCount(Ninja_MaxXPHelper_DeadOnArrivalNPCList, ";");
    _Ninja_MaxXPHelper_DeathAlerts_DeadOnArrivalNpc_Hashtable = HT_Create();
    repeat(i, count); var int i;
        var string npcCode; npcCode = STRINT_SplitGet(i);
        var zCPar_Symbol npcSymbol; npcSymbol = _^(MEM_GetSymbol(npcCode));
        var c_npc npc; npc = _^(npcSymbol.content);
        if Hlp_IsValidNpc(npc) && !Npc_IsDead(npc) {
            HT_Insert(_Ninja_MaxXPHelper_DeathAlerts_DeadOnArrivalNpc_Hashtable, _@(npc), TRUE);
        };
    end;
    const int once = 0;
    if !once {
        HookDaedalusFuncS("ZS_Dead", "Ninja_MaxXPHelper_ZS_Dead_Hook");
        HookDaedalusFuncS("B_RemoveNpc", "Ninja_MaxXPHelper_B_RemoveNpc_Hook");
        HookDaedalusFuncS("B_KillNpc", "Ninja_MaxXPHelper_B_KillNpc_Hook");
        HookDaedalusFuncS("B_MagicHurtNpc", "Ninja_MaxXPHelper_B_MagicHurtNpc_Hook");
        once = 1;
    };
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
    Ninja_MaxXPHelper_AddTextAlert(
        msg,  _Ninja_MaxXPHelper_TextAlerts_Duration, _Ninja_MaxXPHelper_TextAlerts_Color
    );
    Ninja_MaxXPHelper_MortalNPCLocator_AttachExpiringSphereToNpc(npc, _Ninja_MaxXPHelper_TextAlerts_Duration);
};

func int _Ninja_MaxXPHelper_Handler_NPCDiedAndWasNotBeatenBeforeAndDoubleXPGlitchOn(var c_npc _self, var c_npc _other) {
    Ninja_MaxXPHelper_LogInfo("_Ninja_MaxXPHelper_Handler_NPCDiedAndWasNotBeatenBeforeAndDoubleXPGlitchOn");
    // If we consider double XP glitch - human NPC died, hero didn't beat them, no matter who's the killer - we lose XP.
    if	Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch &&
        !Ninja_MaxXPHelper_VictoryXPReceived(_self) &&
        Ninja_MaxXPHelper_IsKnockable(_self, _other) {
            var int s; s = SB_New();
            SB(Ninja_MaxXPHelper_LOC_RIPPrefix);
            SB(_self.name);
            SB(" ");
            SB(Ninja_MaxXPHelper_LOC_DoubleXPNoZSUnconsciousXP);
            _Ninja_MaxXPHelper_TriggerAlert(_self, SB_ToString());
            SB_Clear();
            SB_Destroy();
            return 1;
    };
    return 0;
};

func int _Ninja_MaxXPHelper_Handler_SkipDeadOnArrivalNPC(var c_npc self) {
    Ninja_MaxXPHelper_LogInfo("_Ninja_MaxXPHelper_Handler_SkipDeadOnArrivalNPC");
    return !!HT_Get(_Ninja_MaxXPHelper_DeathAlerts_DeadOnArrivalNpc_Hashtable, _@(self));
};

func int _Ninja_MaxXPHelper_Handler_NPCDiedAndPlayerCouldLoseXP(var c_npc self, var c_npc other) {
    Ninja_MaxXPHelper_LogInfo("_Ninja_MaxXPHelper_Handler_NPCDiedAndPlayerCouldLoseXP");
    var int B_MagicHurtNpc_actual_attacker; B_MagicHurtNpc_actual_attacker = HT_Get(
        _Ninja_MaxXPHelper_DeathAlerts_B_MagicHurtNpc_Killed_To_RealKiller_Hashtable,
        _@(self)
    );
    if B_MagicHurtNpc_actual_attacker {
        other = _^(B_MagicHurtNpc_actual_attacker);
    };
    Ninja_MaxXPHelper_LogInfo(ConcatStrings("_Ninja_MaxXPHelper_Handler_NPCDiedAndPlayerCouldLoseXP other=", other.name));
    var int playerGetsXP; playerGetsXP = Ninja_MaxXPHelper_WouldReceiveVictoryXP(self, other); 
    if  Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch && 
        playerGetsXP &&
        Npc_WasInState(self,ZS_UNCONSCIOUS) && 
        Npc_IsInFightMode(other,FMODE_MELEE) {
        var int s; s = SB_New();
        SB(Ninja_MaxXPHelper_LOC_RIPPrefix);
        SB(self.name);
        SB(" ");
        SB(Ninja_MaxXPHelper_LOC_DoubleXPMeleeFinisherTip);
        _Ninja_MaxXPHelper_TriggerAlert(self, SB_ToString());
        SB_Clear();
        SB_Destroy();
        return 1;
    }
    else if !playerGetsXP {
        // Now XP was 99% sure lost so alert.
        var int s; s = SB_New();
        SB(Ninja_MaxXPHelper_LOC_RIPPrefix);
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
        SB(Ninja_MaxXPHelper_LOC_RIPPrefix);
        SB(npc.name);
        SB(" ");
        SB(Ninja_MaxXPHelper_LOC_ScriptedDeathTip);
        _Ninja_MaxXPHelper_TriggerAlert(cnpc, SB_ToString());
        SB_Clear();
        SB_Destroy();
        return 1;
    };
    return 0;
};

func void Ninja_MaxXPHelper_ZS_Dead_Hook() {
    var int handled; handled = !Ninja_MaxXPHelper_ShowMissedXPOnNPCDeathAlerts;
    if !handled {
        handled = _Ninja_MaxXPHelper_Handler_SkipPlayerDeath(self);
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

func void Ninja_MaxXPHelper_B_KillNpc_Hook(var int npcInstance) {
    var int handled; handled = !Ninja_MaxXPHelper_ShowMissedXPOnNPCDeathAlerts;
    var c_npc cnpc; cnpc = Hlp_GetNpc(npcInstance);
    Ninja_MaxXPHelper_LogInfo(ConcatStrings("B_KillNpc ", cnpc.name));
    if !handled {
        // Should never happen?
        handled = _Ninja_MaxXPHelper_Handler_SkipPlayerDeath(cnpc);
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

func void Ninja_MaxXPHelper_B_MagicHurtNpc_Hook(var C_NPC attacker, var int damage) {
    PassArgumentN(attacker);
    PassArgumentI(damage);
    ContinueCall();
    if Npc_IsDead(self) {
        // Death XP of NPC killed by DOT stun spell like pyrokinesis could also happen in B_MagicHurtNpc.
        // ZS_Dead might be called after this script with invalid (empty) NPC set as killer ("other" variable) which 
        // would trigger false positive alert.
        // To reproduce - spawn character helper, beat him, when he's up finish him off with a single cast of pyrokinesis.
        HT_Insert(_Ninja_MaxXPHelper_DeathAlerts_B_MagicHurtNpc_Killed_To_RealKiller_Hashtable, _@(attacker), _@(self));
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