const string Ninja_MaxXPHelper_DeadOnArrivalNPCDefaultList = "";
const string Ninja_MaxXPHelper_DeathAlertsSVM_Default = "Info_BaalLukor_ALTAR_13_05";
const string Ninja_MaxXPHelper_PickpocketBlacklist = "";
const string  Ninja_MaxXPHelper_GuildIcons = "GIL_GOLEM;GIL_ORCDOG;GIL_SEPERATOR_ORC;GIL_UNDEADORC;GIL_BDT;GIL_GARGOYLE;GIL_GOBBO_SKELETON;GIL_SHADOWBEAST_SKELETON;GIL_DRAGON;GIL_GIANT_RAT;GIL_MEATBUG;GIL_SHEEP;GIL_LURKER;GIL_GIANT_BUG;GIL_SWAMPGOLEM;GIL_Stoneguardian;GIL_WARAN;GIL_HARPY;GIL_GOBBO;GIL_WOLF;GIL_SWAMPSHARK;GIL_MINECRAWLER;GIL_MOLERAT;GIL_BLOODFLY;GIL_ORC;GIL_DRACONIAN;GIL_ZOMBIE;GIL_TROLL;GIL_SCAVENGER;GIL_DEMON;GIL_DMT;GIL_SNAPPER;GIL_SKELETON_MAGE;GIL_SKELETON;GIL_SHADOWBEAST;";
const string  Ninja_MaxXPHelper_SpeciesIdIcons = "ID_SKELETONMAGE;ID_HARPIE;ID_WISP;ID_ICEGOLEM;ID_ORCBITER;ID_BLATTCRAWLER;ID_SWAMPDRONE;ID_RAZOR;ID_BLOODHOUND;ID_KEILER;ID_STONEGOLEM;ID_FIREGOLEM;ID_WARG;ID_FIREWARAN;ID_DRAGONSNAPPER;";

func int Ninja_MaxXPHelper_NormalizedGuild(var int guild) {
    if guild >= GIL_SEPERATOR_ORC && guild < GIL_MAX {
        return GIL_SEPERATOR_ORC;
    };
    return guild;
};
const int CurrentLevel = 0; // todo
const int XP_PER_VICTORY =  XP_PER_LEVEL_DEAD;
func int Ninja_MaxXPHelper_VictoryXPReceived(var c_npc npc) {
    return npc.aivar[AIV_WASDEFEATEDBYSC];
};

func int Ninja_MaxXPHelper_WouldReceiveVictoryXP(var c_npc _self, var c_npc _other) {
    return (
        // Player killed.
        Npc_IsPlayer(_other) ||
        // Our party member claimed the kill.
        (C_NpcIsHuman(_other) && _other.aivar[AIV_PARTYMEMBER]) ||
        // Our summon claimed the kill.
        (C_NpcIsMonster(_other) && _other.aivar[AIV_MM_PARTYMEMBER])
    );
};

func int Ninja_MaxXPHelper_IsSummon(var c_npc npc) {
    return (C_NpcIsMonster(npc) && npc.aivar[AIV_MM_PARTYMEMBER]);
};

func int Ninja_MaxXPHelper_IsKnockable(var c_npc attackerNpc, var c_npc victimNpc) {
    var c_npc selfBak; selfBak = Hlp_GetNpc (self);
    // The original G1 C_NpcIsHuman impl calls PrintDebugNpc internally and  assumes a valid self instance exists...
    self = Hlp_GetNpc(victimNpc);
    const int isHuman = FALSE; isHuman = C_NpcIsHuman(victimNpc);
    self = Hlp_GetNpc (selfBak);
    return isHuman;
};

const int zRND_XD3D_D3DRS_ALPHATESTENABLE_OFFSET = 112;
const int oCGame_UpdatePlayerStatus = 6524816;
const int Ninja_MaxXPHelper_oCInformationManager_OnChoice = 7527536;
const int Ninja_MaxXPHelper_oCInformationManager_OnInfo = 7525728;


func int Ninja_MaxXPHelper_ThiefScanner_HasPlayerPickedPocket(var C_NPC npc) {
    return FALSE;
};