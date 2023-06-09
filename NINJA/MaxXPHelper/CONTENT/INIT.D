func void Ninja_MaxXPHelper_Init()
{
    MEM_InitAll();
    LeGo_MergeFlags(LeGo_HookEngine | LeGo_FrameFunctions | LeGo_Interface | LeGo_PrintS | LeGo_Timer);
    
    const int once = 0;
    if (!once) {
        // todo: use init menu.
        Ninja_MaxXPHelper_DeathAlertsSVM = Ninja_MaxXPHelper_GetStrOptOrSetDefault(
            "deathAlertsSVM",
            Ninja_MaxXPHelper_DeathAlertsSVM_Default
        );
        var string filename; filename = Ninja_MaxXPHelper_GetStrOptOrSetDefault(
            "deadOnArrivalNPCListPath",
            "system\deadOnArrivalNPCList.txt"
        );
        Ninja_MaxXPHelper_DeadOnArrivalNPCList = Ninja_MaxXPHelper_ReadFileOrSetDefault(
            filename, 
            Ninja_MaxXPHelper_DeadOnArrivalNPCDefaultList
        );

        Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch = Ninja_MaxXPHelper_GetIntOptOrSetDefault(
            "considerG1DoubleXPGlitch",
            0
        );
        Ninja_MaxXPHelper_ConsiderLevelZeroNPC = Ninja_MaxXPHelper_GetIntOptOrSetDefault(
            "considerLevelZeroNPC",
            0 // Skip NPCs like Mud which wouldn't yield any XP in base game anyway.
        );
        Ninja_MaxXPHelper_ShowDeathAlerts = Ninja_MaxXPHelper_GetIntOptOrSetDefault(
            "showDeathAlerts",
            1
        );
        Ninja_MaxXPHelper_ToggleXPNPCLocatorKeyCode = Ninja_MaxXPHelper_GetKeyCodeOrSetDefault(
            "toggleXPNPCLocatorKey", 
            "KEY_V"
        );
        Ninja_MaxXPHelper_ToggleTrackersUseZBufferKeyCode = Ninja_MaxXPHelper_GetKeyCodeOrSetDefault(
            "toggleTrackersUseZBufferKey", 
            ""
        );
        Ninja_MaxXPHelper_ToggleTrackersMaxRenderingLevelKeyCode = Ninja_MaxXPHelper_GetKeyCodeOrSetDefault(
            "toggleTrackersMaxRenderingLevelKey", 
            ""
        );
        Ninja_MaxXPHelper_TrackersUseZBuffer = Ninja_MaxXPHelper_GetIntOptOrSetDefault(
            Ninja_MaxXPHelper_TrackersUseZBuffer_OptKey,
            0
        );
        Ninja_MaxXPHelper_TrackersRenderingLevel = Ninja_MaxXPHelper_GetIntOptOrSetDefault(
            "trackersRenderingLevel",
            5
        );
        Ninja_MaxXPHelper_ShowTrackerOnDeathAlert = Ninja_MaxXPHelper_GetIntOptOrSetDefault(
            "showTrackerOnDeathAlert",
            1
        );
        Ninja_MaxXPHelper_DeathAlertTrackerDurationInMillis = Ninja_MaxXPHelper_GetIntOptOrSetDefault(
            "deathAlertTrackerDurationInMillis",
            Ninja_MaxXPHelper_DeathAlertTrackerDurationInMillis
        );
        Ninja_MaxXPHelper_DeathAlertTextDurationInMillis = Ninja_MaxXPHelper_GetIntOptOrSetDefault(
            "deathAlertTextDurationInMillis",
            Ninja_MaxXPHelper_DeathAlertTextDurationInMillis
        );
        Ninja_MaxXPHelper_DeathAlertsFailColor = Ninja_MaxXPHelper_GetRGBColorOptOrSetDefault(
            "deathAlertsFailColor",
            RGBA(255, 50, 50, 255)
        );
        Ninja_MaxXPHelper_SystemNotificationsColor = Ninja_MaxXPHelper_GetRGBColorOptOrSetDefault(
            "systemNotificationsColor",
            RGBA(50, 255, 50, 255)
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
