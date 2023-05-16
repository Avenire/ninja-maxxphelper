const string DefaultDeadOnArrivalNPCs = "";

func int Ninja_MaxXPHelper_VictoryXPReceived(var c_npc npc) {
    return npc.aivar[AIV_WASDEFEATEDBYSC];
};

func int Ninja_MaxXPHelper_WouldReceiveVictoryXP(var c_npc self, var c_npc other) {
    return (
        // You killed, yay.
        Npc_IsPlayer(other) ||
        // Our party member claimed the kill.
        (C_NpcIsHuman(other) && other.aivar[AIV_PARTYMEMBER]) ||
        // Our summon claimed the kill.
        (C_NpcIsMonster(other) && other.aivar[AIV_MM_PARTYMEMBER])
    );
};

func int Ninja_MaxXPHelper_IsKnockable(var c_npc _self, var c_npc _other) {
    return C_NpcIsHuman(self);
};