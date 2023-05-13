// Too lazy to use actual class and allocate some list of instances.
const int _Ninja_MaxXPHelper_DeadAlerts_CircularListIndex = 0;
const int _Ninja_MaxXPHelper_DeadAlerts_CircularListMaxSize = 5;
// Seems I can't use it to declare array size, bummer.
const int _Ninja_MaxXPHelper_DeadAlerts_CircularListElementSize = 2;
const int Ninja_MaxXPHelper_Dead[10] = {
    0, 0,
    0, 0,
    0, 0,
    0, 0,
    0, 0
};

func void _Ninja_MaxXPHelper_AddDeadNPCSphere(var int npc) {
    var int idx; idx = _Ninja_MaxXPHelper_DeadAlerts_CircularListIndex * _Ninja_MaxXPHelper_DeadAlerts_CircularListElementSize;
    var int timestamp; timestamp = MEM_GetSystemTime();
    Ninja_MaxXPHelper_LogInfo(
        ConcatStrings(ConcatStrings("NPC ", IntToString(npc)), ConcatStrings(", Time of Death ", IntToString(timestamp)))
    );
    MEM_WriteIntArray(_@(Ninja_MaxXPHelper_Dead), idx, npc);
    MEM_WriteIntArray(_@(Ninja_MaxXPHelper_Dead), idx + 1, timestamp);
    var int next; next = _Ninja_MaxXPHelper_DeadAlerts_CircularListIndex + 1;
    _Ninja_MaxXPHelper_DeadAlerts_CircularListIndex = next % _Ninja_MaxXPHelper_DeadAlerts_CircularListMaxSize;
};

func void Ninja_MaxXPHelper_DrawDeadNPCSpheres() {
    repeat(i, _Ninja_MaxXPHelper_DeadAlerts_CircularListMaxSize); var int i;
        var int idx; idx = i * _Ninja_MaxXPHelper_DeadAlerts_CircularListElementSize;
        var int npcPtr; npcPtr = MEM_ReadStatArr(_@(Ninja_MaxXPHelper_Dead), idx);
        var int timestamp; timestamp = MEM_ReadIntArray(_@(Ninja_MaxXPHelper_Dead), idx + 1);
        if npcPtr && (MEM_GetSystemTime() - timestamp) < 60*1000 {
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

func void Ninja_MaxXPHelper_ClearAlerts() {
    repeat(i, _Ninja_MaxXPHelper_DeadAlerts_CircularListMaxSize); var int i;
        var int idx; idx = i * _Ninja_MaxXPHelper_DeadAlerts_CircularListElementSize;
        MEM_WriteIntArray(_@(Ninja_MaxXPHelper_Dead), idx, 0);
        MEM_WriteIntArray(_@(Ninja_MaxXPHelper_Dead), idx + 1, 0);
    end;
};

// todo: localization
// todo: hook B_KillNPC to detect story related deaths (not sure if can be done foolproof)
// todo: hook B_MagicHurtNpc because apparently it's relevant for double XP glitch
func void Ninja_MaxXPHelper_ZS_Dead_Hook() {
    // Ignore NPCs like Mud.
    if !Ninja_MaxXPHelper_ConsiderLevelZeroNPC &&
        self.level <= 0 {
            ContinueCall();
            return;
    };
    // If we consider double XP glitch - human NPC died, hero didn't beat them, no matter who's the killer - we lose XP.
    if	Ninja_MaxXPHelper_ShowMissedXPOnNPCDeathAlerts && 
        Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch &&
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
                -1 + _Ninja_MaxXPHelper_DeadAlerts_CircularListIndex * 15,
                "FONT_OLD_20_WHITE.tga",
                5
            );
            SB_Clear();
            SB_Destroy();
            _Ninja_MaxXPHelper_AddDeadNPCSphere(_@(self));
            ContinueCall();
            return;
    };

    ContinueCall();
    if Ninja_MaxXPHelper_ShowMissedXPOnNPCDeathAlerts && 
    // Exclude obvious cases where no XP was lost
    !(
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
            // Once should be enough.
            !Npc_WasInState(self, ZS_Dead) || 
            // No G1 double XP glitch, so we need to check if NPC was beaten before.
            (!Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch && !self.aivar[AIV_WASDEFEATEDBYSC]) {
            // Now XP was 99% sure lost so alert.
            var int s; s = SB_New();
            SB("RIP ");
            SB(self.name);
            PrintScreen(
                SB_ToString(), 
                -1,
                -1 + _Ninja_MaxXPHelper_DeadAlerts_CircularListIndex * 15,
                "FONT_OLD_20_WHITE.tga",
                5
            );
            SB_Clear();
            SB_Destroy();
            _Ninja_MaxXPHelper_AddDeadNPCSphere(_@(self));
        };
    };
};