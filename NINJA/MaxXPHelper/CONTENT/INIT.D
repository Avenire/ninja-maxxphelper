

func int Ninja_MaxXPHelper_GetSymbolUnsafe(var string symbol) {
    var zCPar_Symbol npcSymbol; npcSymbol = _^(MEM_GetSymbol(symbol));
    return npcSymbol.content;
};
func void Ninja_MaxXPHelper_Init()
{
    MEM_InitAll();
    LeGo_MergeFlags(LeGo_HookEngine | LeGo_PermMem | LeGo_FrameFunctions | LeGo_Interface | LeGo_PrintS | LeGo_Timer | LeGo_Draw3D);
    
    const int once = 0;
    
    if (!once) {
        
        Ninja_MaxXPHelper_DeadOnArrivalNPCList = Ninja_MaxXPHelper_GetStrOptOrDefault(
            "deadOnArrivalNPCList", 
            Ninja_MaxXPHelper_DeadOnArrivalNPCList
        );
        Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch = Ninja_MaxXPHelper_GetFlagOrDefault(
            "considerG1DoubleXPGlitch",
            GOTHIC_BASE_VERSION == 1 // Double XP makes sense only in G1, set it to true only there.
        );
        Ninja_MaxXPHelper_ConsiderLevelZeroNPC = Ninja_MaxXPHelper_GetFlagOrDefault(
            "considerLevelZeroNPC",
            0 // Skip NPCs like Mud which wouldn't yield any XP in base game anyway.
        );
        Ninja_MaxXPHelper_ShowMissedXPOnNPCDeathAlerts = Ninja_MaxXPHelper_GetFlagOrDefault(
            "showMissedXPOnNPCDeathAlerts",
            1
        );
        Ninja_MaxXPHelper_ToggleMortalNPCLocatorKeyCode = Ninja_MaxXPHelper_GetKeyOrDefault(
            "toggleMortalNPCLocatorKey", 
            "KEY_V"
        );
        once = 1;

        Ninja_MaxXPHelper_LogInfo("Initialized.");
    };
    Ninja_MaxXPHelper_Localization_Init();
    Ninja_MaxXPHelper_TextAlerts_Init();
    Ninja_MaxXPHelper_DeathAlerts_Init();
    Ninja_MaxXPHelper_MortalNPCLocator_Init();
};
