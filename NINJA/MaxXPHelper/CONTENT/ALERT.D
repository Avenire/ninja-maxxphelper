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

func void _Ninja_MaxXPHelper_AddDeadNPCSphere(var int npc) {
    var int idx; idx = _Ninja_MaxXPHelper_DeadAlerts_ActiveAlertsCount * _Ninja_MaxXPHelper_DeadAlerts_DeadSpheresArrElementSize;
    var int timestamp; timestamp = MEM_GetSystemTime();
    MEM_WriteIntArray(_@(_Ninja_MaxXPHelper_DeadSpheres), idx, npc);
    MEM_WriteIntArray(_@(_Ninja_MaxXPHelper_DeadSpheres), idx + 1, timestamp);
};

func int _Ninja_MaxXPHelper_HandleSkipLevelZeroNPC(var c_npc self) {
    // Ignore NPCs like Mud.
    if !Ninja_MaxXPHelper_ConsiderLevelZeroNPC &&
        self.level <= 0 {
            return 1;
    };
    return 0;
};

// todo: localization
func int _Ninja_MaxXPHelper_HandleNPCDiedAndWasNotBeatenBeforeAndDoubleXPGlitchOn(var c_npc self) {
    // If we consider double XP glitch - human NPC died, hero didn't beat them, no matter who's the killer - we lose XP.
    if	Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch &&
        !Npc_IsPlayer(self) &&
        !self.aivar[AIV_WASDEFEATEDBYSC] && 
        C_NpcIsHuman(self) {
            var int s; s = SB_New();
            SB("RIP ");
            SB(self.name);
            SB(" who died without getting knocked down first.");
            PrintScreen(
                SB_ToString(), 
                -1,
                5 + _Ninja_MaxXPHelper_DeadAlerts_ActiveAlertsCount * 5,
                "FONT_OLD_20_WHITE.tga",
                _Ninja_MaxXPHelper_DeadAlerts_AlertTimeInSeconds
            );
            SB_Clear();
            SB_Destroy();
            _Ninja_MaxXPHelper_AddDeadNPCSphere(_@(self));
            _Ninja_MaxXPHelper_DeadAlerts_ActiveAlertsCount = _Ninja_MaxXPHelper_DeadAlerts_ActiveAlertsCount + 1;
            _Ninja_MaxXPHelper_DeadAlerts_LastAlertTimestamp = MEM_GetSystemTime();
            return 1;
    };
    return 0;
};

// todo: localization
func int _Ninja_MaxXPHelper_HandleNPCDiedAndPlayerCouldLoseXP(var c_npc self, var c_npc other) {
    if !(
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
        if 
            // No G1 double XP glitch, so we need to check if NPC was beaten before.
            (Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch || !self.aivar[AIV_WASDEFEATEDBYSC]) {
            // Now XP was 99% sure lost so alert.
            var int s; s = SB_New();
            SB("RIP ");
            SB(self.name);
            PrintScreen(
                SB_ToString(), 
                -1,
                5 + _Ninja_MaxXPHelper_DeadAlerts_ActiveAlertsCount * 5,
                "FONT_OLD_20_WHITE.tga",
                _Ninja_MaxXPHelper_DeadAlerts_AlertTimeInSeconds
            );
            SB_Clear();
            SB_Destroy();
            _Ninja_MaxXPHelper_AddDeadNPCSphere(_@(self));
            _Ninja_MaxXPHelper_DeadAlerts_ActiveAlertsCount = _Ninja_MaxXPHelper_DeadAlerts_ActiveAlertsCount + 1;
            _Ninja_MaxXPHelper_DeadAlerts_LastAlertTimestamp = MEM_GetSystemTime();
            return 1;
        };
    };
    return 0;
};

func int _Ninja_MaxXPHelper_HandleSkipIfNpcWasAlreadyDead(var c_npc self) {
    // Sometimes NPC glitch and ZS_Dead gets called multiple time - for example Orc Scout in front of the entrance
    // to Orcish Cemetery in G1 CH3. If you enter and exit the cemetery, orc will fall dead again...
    return Npc_WasInState(self, ZS_Dead);
};

func int _Ninja_MaxXPHelper_HandleSkipIfThrottled() {
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

func int _Ninja_MaxXPHelper_HandleStoryScriptedDeath(var int npcInstance) {
    var oCNPC npc; npc = Hlp_GetNpc(npcInstance);
    var c_npc cnpc; cnpc = Hlp_GetNpc(npcInstance);
    if  // testing note: Should be false only for off-screen kill? Would need to check range otherwise.
        !npc.percActive && 
        // Skip immortal NPC
        !( cnpc.flags & NPC_FLAG_IMMORTAL) {
        if 
            Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch || 
            !cnpc.aivar[AIV_WASDEFEATEDBYSC] {
                var int s; s = SB_New();
                SB("RIP ");
                SB(npc.name);
                SB(" who got killed off-screen by game scripts");
                PrintScreen(
                    SB_ToString(), 
                    -1,
                    5 + _Ninja_MaxXPHelper_DeadAlerts_ActiveAlertsCount * 5,
                    "FONT_OLD_20_WHITE.tga",
                    _Ninja_MaxXPHelper_DeadAlerts_AlertTimeInSeconds
                );
                SB_Clear();
                SB_Destroy();
                _Ninja_MaxXPHelper_AddDeadNPCSphere(_@(npc));
                _Ninja_MaxXPHelper_DeadAlerts_ActiveAlertsCount = _Ninja_MaxXPHelper_DeadAlerts_ActiveAlertsCount + 1;
                _Ninja_MaxXPHelper_DeadAlerts_LastAlertTimestamp = MEM_GetSystemTime();
                return 1;
        };
    };
    return 0;
};

// todo: hook B_MagicHurtNpc because apparently it's relevant for double XP glitch
func void Ninja_MaxXPHelper_ZS_Dead_Hook() {
    var int handled; handled = !Ninja_MaxXPHelper_ShowMissedXPOnNPCDeathAlerts;
    if !handled {
        handled = _Ninja_MaxXPHelper_HandleSkipIfThrottled();
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_HandleSkipIfNpcWasAlreadyDead(self);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_HandleSkipLevelZeroNPC(self);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_HandleNPCDiedAndWasNotBeatenBeforeAndDoubleXPGlitchOn(self);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_HandleNPCDiedAndPlayerCouldLoseXP(self, other);
    };
    ContinueCall();
};

// todo: localization
func void Ninja_MaxXPHelper_B_KillNpc_Hook(var int npcInstance) {
    var int handled; handled = !Ninja_MaxXPHelper_ShowMissedXPOnNPCDeathAlerts;
    var c_npc cnpc; cnpc = Hlp_GetNpc(npcInstance);
    if !handled {
        handled = _Ninja_MaxXPHelper_HandleSkipIfThrottled();
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_HandleSkipIfNpcWasAlreadyDead(cnpc);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_HandleSkipLevelZeroNPC(cnpc);
    };
    if !handled {
        handled = _Ninja_MaxXPHelper_HandleStoryScriptedDeath(npcInstance);
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

func void Ninja_MaxXPHelper_ResetAlerts() {
    repeat(i, _Ninja_MaxXPHelper_DeadAlerts_ActiveAlertsCount); var int i;
        var int idx; idx = i * _Ninja_MaxXPHelper_DeadAlerts_DeadSpheresArrElementSize;
        MEM_WriteIntArray(_@(_Ninja_MaxXPHelper_DeadSpheres), idx, 0);
        MEM_WriteIntArray(_@(_Ninja_MaxXPHelper_DeadSpheres), idx + 1, 0);
    end;
    _Ninja_MaxXPHelper_DeadAlerts_ActiveAlertsCount = 0;
};
