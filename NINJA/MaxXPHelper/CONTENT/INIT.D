func void Ninja_MaxXPHelper_Init()
{
    MEM_InitAll();
    LeGo_MergeFlags(LeGo_HookEngine | LeGo_PermMem | LeGo_FrameFunctions | LeGo_Interface | LeGo_PrintS | LeGo_Timer);
    
    const int once = 0;
    
    if (!once) {
        Ninja_MaxXPHelper_DeathAlertsSVM = Ninja_MaxXPHelper_GetStrOptOrDefault(
            "deathAlertsSVM",
            Ninja_MaxXPHelper_DeathAlertsSVM_Default
        );
        var string filename; filename = Ninja_MaxXPHelper_GetStrOptOrDefault(
            "deadOnArrivalNPCListPath",
            "system\deadOnArrivalNPCList.txt"
        );
        Ninja_MaxXPHelper_DeadOnArrivalNPCList = Ninja_MaxXPHelper_ReadFileOrSetDefault(
            filename, 
            Ninja_MaxXPHelper_DeadOnArrivalNPCDefaultList
        );

        Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch = Ninja_MaxXPHelper_GetFlagOrDefault(
            "considerG1DoubleXPGlitch",
            0
        );
        Ninja_MaxXPHelper_ConsiderLevelZeroNPC = Ninja_MaxXPHelper_GetFlagOrDefault(
            "considerLevelZeroNPC",
            0 // Skip NPCs like Mud which wouldn't yield any XP in base game anyway.
        );
        Ninja_MaxXPHelper_ShowMissedXPOnNPCDeathAlerts = Ninja_MaxXPHelper_GetFlagOrDefault(
            "showMissedXPOnNPCDeathAlerts",
            1
        );
        Ninja_MaxXPHelper_ToggleXPNPCLocatorKeyCode = Ninja_MaxXPHelper_GetKeyOrDefault(
            "toggleXPNPCLocatorKey", 
            "KEY_V"
        );
        Ninja_MaxXPHelper_DeathAlertsFailColor = Ninja_MaxXPHelper_GetColorOptOrDefault(
            "deathAlertsFailColor",
            RGBA(255, 50, 50, 0)
        );
        // todo: expose as OPTS?
        Ninja_MaxXPHelper_IconSize = mkf(Ninja_MaxXPHelper_IconSize);
        Ninja_MaxXPHelper_MinIconSize = mkf(Ninja_MaxXPHelper_MinIconSize);
        Ninja_MaxXPHelper_IconFadingNearbyDistance = mkf(Ninja_MaxXPHelper_IconFadingNearbyDistance);
        Ninja_MaxXPHelper_ColorMaxFloat = mkf(Ninja_MaxXPHelper_ColorMaxFloat);
        once = 1;
    };
    Ninja_MaxXPHelper_Localization_Init();
    Ninja_MaxXPHelper_TextAlerts_Init();
    Ninja_MaxXPHelper_Trackers_Init();
    Ninja_MaxXPHelper_DeathAlerts_Init();
    Ninja_MaxXPHelper_XPNPCLocator_Init();
};
