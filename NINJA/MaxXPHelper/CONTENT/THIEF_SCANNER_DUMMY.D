// In Gothic 1 there's no info based pickpocketing for XP so implement dummies for public "API"
func int Ninja_MaxXPHelper_ThiefScanner_CanPickpocketNpc(var C_NPC npc) {
    return FALSE;
};

func void Ninja_MaxXPHelper_ThiefScanner_Init() {};
func int Ninja_MaxXPHelper_ThiefScanner_EnoughDexToPickpocket(var C_NPC npc) { return FALSE; };
const int Ninja_MaxXPHelper_ThiefScanner_SeemsEnough = 1; 
const int Ninja_MaxXPHelper_ThiefScanner_SeemsNotEnough = -1;
const int Ninja_MaxXPHelper_ThiefScanner_Unknown = 0;