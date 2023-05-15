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

func void _Ninja_MaxXPHelper_AddDeadNPCSphere(var int npc) {
    var int idx; idx = _Ninja_MaxXPHelper_DeadAlerts_ActiveAlertsCount * _Ninja_MaxXPHelper_DeadAlerts_DeadSpheresArrElementSize;
    var int timestamp; timestamp = MEM_GetSystemTime();
    MEM_WriteIntArray(_@(_Ninja_MaxXPHelper_DeadSpheres), idx, npc);
    MEM_WriteIntArray(_@(_Ninja_MaxXPHelper_DeadSpheres), idx + 1, timestamp);
};

func int _Ninja_MaxXPHelper_Handler_SkipLevelZeroNPC(var c_npc self) {
    // Ignore NPCs like Mud.
    if !Ninja_MaxXPHelper_ConsiderLevelZeroNPC &&
        self.level <= 0 {
            return 1;
    };
    return 0;
};

func int _Ninja_MaxXPHelper_Handler_SkipIfDefeatedAndNoDoubleXPMode(var c_npc self) {
    return !(Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch || !self.aivar[AIV_WASDEFEATEDBYSC]);
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

// todo: localization
func int _Ninja_MaxXPHelper_Handler_NPCDiedAndWasNotBeatenBeforeAndDoubleXPGlitchOn(var c_npc self) {
    // If we consider double XP glitch - human NPC died, hero didn't beat them, no matter who's the killer - we lose XP.
    if	Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch &&
        !Npc_IsPlayer(self) &&
        !self.aivar[AIV_WASDEFEATEDBYSC] && 
        C_NpcIsHuman(self) {
            var int s; s = SB_New();
            SB("RIP: ");
            SB(self.name);
            SB(" died without getting beaten first (no double XP)");
            _Ninja_MaxXPHelper_TriggerAlert(self, SB_ToString());
            SB_Clear();
            SB_Destroy();
            return 1;
    };
    return 0;
};

// todo: localization
func int _Ninja_MaxXPHelper_Handler_NPCDiedAndPlayerCouldLoseXP(var c_npc self, var c_npc other) {
    var int playerGetsXP; playerGetsXP = 0; 
    var int B_MagicHurtNpc_actual_attacker; B_MagicHurtNpc_actual_attacker = HT_Get(
        _Ninja_MaxXPHelper_DeadAlerts_B_MagicHurtNpc_Killed_To_RealKiller_Hashtable, _@(self)
    );
    if B_MagicHurtNpc_actual_attacker {
        other = _^(B_MagicHurtNpc_actual_attacker);
    };

    if (
        // You died, loser.
        Npc_IsPlayer(self) ||
        // You killed, yay.
        Npc_IsPlayer(other) ||
        // Our party member claimed the kill.
        (C_NpcIsHuman(other) && other.aivar[AIV_PARTYMEMBER]) ||
        // Our summon claimed the kill.
        (C_NpcIsMonster(other) && other.aivar[AIV_MM_PARTYMEMBER]) ||
        // Our summon got killed and it's not Gothic 1 so no XP.
        (GOTHIC_BASE_VERSION != 1 && C_NpcIsMonster(self) && self.aivar[AIV_MM_PARTYMEMBER])
        
    ) {
        playerGetsXP = 1;
    };
    if  Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch && 
        playerGetsXP &&
        Npc_WasInState(self,ZS_UNCONSCIOUS) && 
        Npc_HasReadiedMeleeWeapon(other) {
        var int s; s = SB_New();
        SB("RIP: ");
        SB(self.name);
        SB(" died from finishing move (no double XP)");
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
    // Sometimes NPC glitch and ZS_Dead gets called multiple time - for example Orc Scout in front of the entrance
    // to Orcish Cemetery in G1 CH3. If you enter and exit the cemetery, orc will fall dead again...
    return Npc_WasInState(self, ZS_Dead);
};

func int _Ninja_MaxXPHelper_Handler_SkipIfThrottled() {
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
    var oCNPC npc; npc = Hlp_GetNpc(npcInstance);
    var c_npc cnpc; cnpc = Hlp_GetNpc(npcInstance);
    // todo: handle G2 cases where mortal NPCs travel worlds between chapters (Diego CH2->CH3, Gorn CH2, CH3, CH4...)
    if  // testing note: Should be false only for off-screen kill? Would need to check range otherwise.
        !npc.percActive && 
        // Skip immortal NPC
        !( cnpc.flags & NPC_FLAG_IMMORTAL) {
        var int s; s = SB_New();
        SB("RIP: ");
        SB(npc.name);
        SB(" who got killed off-screen by game scripts");
        _Ninja_MaxXPHelper_TriggerAlert(self, SB_ToString());
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
        handled = _Ninja_MaxXPHelper_Handler_NPCDiedAndWasNotBeatenBeforeAndDoubleXPGlitchOn(self);
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
    if !handled {
        handled = _Ninja_MaxXPHelper_Handler_SkipIfThrottled();
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_Handler_SkipIfDefeatedAndNoDoubleXPMode(self);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_Handler_SkipIfNpcWasAlreadyDead(cnpc);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_Handler_SkipLevelZeroNPC(cnpc);
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
            var int x; x = npc._zCVob_trafoObjToWorld[3];
            var int y; y = npc._zCVob_trafoObjToWorld[7];
            var int z; z = npc._zCVob_trafoObjToWorld[11];
            Ninja_MaxXPHelper_DrawSphere(
                x, y, z, 
                Ninja_MaxXPHelper_SphereColorDeathAlert, 
                Ninja_MaxXPHelper_SphereRadius
            );
        };
    end;
};

func void _Ninja_MaxXPHelper_ClearHashTableKey(var int key, var int _) {
    HT_Remove(_Ninja_MaxXPHelper_DeadAlerts_B_MagicHurtNpc_Killed_To_RealKiller_Hashtable,key);   
};

func void Ninja_MaxXPHelper_ResetAlerts() {
    if !_Ninja_MaxXPHelper_DeadAlerts_B_MagicHurtNpc_Killed_To_RealKiller_Hashtable {
        _Ninja_MaxXPHelper_DeadAlerts_B_MagicHurtNpc_Killed_To_RealKiller_Hashtable = HT_Create();
    } else {
        HT_ForEach(_Ninja_MaxXPHelper_DeadAlerts_B_MagicHurtNpc_Killed_To_RealKiller_Hashtable, _Ninja_MaxXPHelper_ClearHashTableKey);
    };
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