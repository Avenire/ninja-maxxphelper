func void Ninja_MaxXPHelper_Loop() 
{
    if (!Hlp_IsValidNpc(hero)) || (MEM_Game.pause_screen) 
    {
        return;
    };
    
    if MEM_KeyState(Ninja_MaxXPHelper_ToggleMortalNPCLocatorKeyCode) == KEY_PRESSED {
        Ninja_MaxXPHelper_MortalNPCLocatorOn = !Ninja_MaxXPHelper_MortalNPCLocatorOn;
    };
    if Ninja_MaxXPHelper_MortalNPCLocatorOn {
        Ninja_MaxXPHelper_MortalNPCLocator();
    };
    if Ninja_MaxXPHelper_ShowMissedXPOnNPCDeathAlerts {
        Ninja_MaxXPHelper_DrawDeadNPCSpheres();
    };
};

func void Ninja_MaxXPHelper_Init()
{
    MEM_InitAll();
    LeGo_MergeFlags(LeGo_HookEngine);
    const int once = 0;
    // todo: will it work after reloading in G2?
    Ninja_MaxXPHelper_ResetAlerts();
    if (!once) {
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
        // todo: use FF_ApplyGT
        HookEngineF(zCWorld__AdvanceClock, 10, Ninja_MaxXPHelper_Loop);
        HookDaedalusFuncS("ZS_Dead", "Ninja_MaxXPHelper_ZS_Dead_Hook");
        HookDaedalusFuncS("B_KillNpc", "Ninja_MaxXPHelper_B_KillNpc_Hook");
        
        once = 1;
        Ninja_MaxXPHelper_LogInfo("Initialized.");
    };
};
