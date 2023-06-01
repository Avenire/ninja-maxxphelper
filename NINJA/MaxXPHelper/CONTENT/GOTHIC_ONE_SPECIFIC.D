const string Ninja_MaxXPHelper_DeadOnArrivalNPCDefaultList = "";
const string Ninja_MaxXPHelper_DeathAlertsSVM_Default = "Info_BaalLukor_ALTAR_13_05"; // the infamous "NOOOOO" ;)

func int Ninja_MaxXPHelper_VictoryXPReceived(var c_npc npc) {
    return npc.aivar[AIV_WASDEFEATEDBYSC];
};

func int Ninja_MaxXPHelper_WouldReceiveVictoryXP(var c_npc _self, var c_npc _other) {
    return (
        // You killed, yay.
        Npc_IsPlayer(_other) ||
        // Our party member claimed the kill.
        (C_NpcIsHuman(_other) && _other.aivar[AIV_PARTYMEMBER]) ||
        // Our summon claimed the kill.
        (C_NpcIsMonster(_other) && _other.aivar[AIV_MM_PARTYMEMBER])
    );
};

func int Ninja_MaxXPHelper_IsKnockable(var c_npc _self, var c_npc _other) {
    return C_NpcIsHuman(_other);
};

const int zRND_XD3D_D3DRS_ALPHATESTENABLE_OFFSET = 112;
const int oCGame_UpdatePlayerStatus = 6524816;