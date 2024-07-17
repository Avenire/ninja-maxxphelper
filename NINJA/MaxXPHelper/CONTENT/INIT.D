func void Ninja_MaxXPHelper_SetOpts() {
    Ninja_MaxXPHelper_DeathAlertsSVM = Ninja_MaxXPHelper_GetStrOptOrSetDefault(
        "deathAlertsSVM",
        Ninja_MaxXPHelper_DeathAlertsSVM_Default
    );
    var string filename; filename = Ninja_MaxXPHelper_GetStrOptOrSetDefault(
        "deadOnArrivalNPCListPath",
        "system\maxxphelper_deadOnArrivalNPCList.txt"
    );
    Ninja_MaxXPHelper_DeadOnArrivalNPCList = Ninja_MaxXPHelper_ReadFileOrSetDefault(
        filename, 
        Ninja_MaxXPHelper_DeadOnArrivalNPCDefaultList
    );
    Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch = Ninja_MaxXPHelper_GetIntOptOrSetDefault(
        "considerG1DoubleXPGlitch",
        0
    );
    Ninja_MaxXPHelper_WarnG1DoubleXPGlitch = Ninja_MaxXPHelper_GetIntOptOrSetDefault(
        "warnG1DoubleXPGlitch",
        0
    );
    Ninja_MaxXPHelper_WarnSummonKill = Ninja_MaxXPHelper_GetIntOptOrSetDefault(
        "warnSummonKill",
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
    Ninja_MaxXPHelper_ToggleXPNPCLocatorKeyCode = Ninja_MaxXPHelper_GetKeyCodeOptOrSetDefault(
        "toggleXPNPCLocatorKey", 
        "KEY_V"
    );
    Ninja_MaxXPHelper_XPNPCLocatorNextModeKey = Ninja_MaxXPHelper_GetKeyCodeOptOrSetDefault(
        "XPNPCLocatorNextModeKey", 
        "KEY_RBRACKET"
    );
    Ninja_MaxXPHelper_XPNPCLocatorPreviousModeKey = Ninja_MaxXPHelper_GetKeyCodeOptOrSetDefault(
        "XPNPCLocatorPreviousModeKey", 
        "KEY_LBRACKET"
    );
    Ninja_MaxXPHelper_WarningAlertsItemStatsKey = Ninja_MaxXPHelper_GetKeyCodeOptOrSetDefault(
        "WarningAlertsItemStatsKey", 
        "" // "secret" feature, KEY_NUMPAD5
    );
    Ninja_MaxXPHelper_ToggleTrackersUseZBufferKeyCode = Ninja_MaxXPHelper_GetKeyCodeOptOrSetDefault(
        "toggleTrackersUseZBufferKey", 
        ""
    );
    Ninja_MaxXPHelper_ToggleTrackersMaxRenderingLevelKeyCode = Ninja_MaxXPHelper_GetKeyCodeOptOrSetDefault(
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
    Ninja_MaxXPHelper_PickpocketAlertsWarningColor = Ninja_MaxXPHelper_GetRGBColorOptOrSetDefault(
        "pickpocketAlertsWarningColor",
        RGBA(255, 95, 21, 255)
    );
    Ninja_MaxXPHelper_ConsiderPickpocketing = Ninja_MaxXPHelper_GetIntOptOrSetDefault(
        "considerPickpocketing",
        GOTHIC_BASE_VERSION == 2
    );
    Ninja_MaxXPHelper_PickpocketSeemsEnoughDexColor = Ninja_MaxXPHelper_GetRGBColorOptOrSetDefault(
        "pickpocketSeemsEnoughDexColor",
        RGBA(50, 255, 50, 255)
    );
    Ninja_MaxXPHelper_PickpocketSeemsNotEnoughDexColor = Ninja_MaxXPHelper_GetRGBColorOptOrSetDefault(
        "pickpocketSeemsNotEnoughDexColor",
        RGBA(255, 50, 50, 255)
    );
    Ninja_MaxXPHelper_PickpocketIndeterminableColor = Ninja_MaxXPHelper_GetRGBColorOptOrSetDefault(
        "pickpocketIndeterminableColor",
        RGBA(255, 95, 21, 255)
    );
    Ninja_MaxXPHelper_XPNPCLocatorHostileColor = Ninja_MaxXPHelper_GetRGBColorOptOrSetDefault(
        "locatorHostileNPCColor",
        RGBA(255, 50, 50, 255)
    );
    Ninja_MaxXPHelper_XPNPCLocatorNonHostileColor = Ninja_MaxXPHelper_GetRGBColorOptOrSetDefault(
        "locatorNonHostileNPCColor",
        COL_WHITE
    );
    Ninja_MaxXPHelper_IconSize = mkf(
        Ninja_MaxXPHelper_GetIntOptOrSetDefault(
            "locatorIconSize",
            50
        )
    );
    Ninja_MaxXPHelper_SystemAlertDurationInMillis = Ninja_MaxXPHelper_GetIntOptOrSetDefault(
        "systemNotificationDurationInMillis",
        2000
    );
    Ninja_MaxXPHelper_PickpocketBlacklist = Ninja_MaxXPHelper_GetStrOptOrSetDefault(
        "pickpocketBlacklist", 
        Ninja_MaxXPHelper_PickpocketBlacklist
    );
    Ninja_MaxXPHelper_PickpocketTrackersOnly = Ninja_MaxXPHelper_GetIntOptOrSetDefault(
        "showPickpocketTrackersOnly", 
        0
    );
    Ninja_MaxXPHelper_WarningAlerts_WarningsConfigFilePath = Ninja_MaxXPHelper_GetStrOptOrSetDefault(
        "warningsConfigFilePath", 
        "system/maxxphelper_warnings.cfg"
    );
};

func void Ninja_MaxXPHelper_Init()
{
    MEM_InitAll();
    LeGo_MergeFlags(LeGo_HookEngine | LeGo_FrameFunctions | LeGo_Interface | LeGo_PrintS | LeGo_Timer);  
    const int once = FALSE;
    if (!once) {
        // todo: use init menu.
        Ninja_MaxXPHelper_SetOpts();
        once = TRUE;
    };
    Ninja_MaxXPHelper_Localization_Init();
    Ninja_MaxXPHelper_TextAlerts_Init();
    Ninja_MaxXPHelper_Trackers_Init();
    Ninja_MaxXPHelper_ThiefScanner_Init();
    Ninja_MaxXPHelper_DeathAlerts_Init();
    Ninja_MaxXPHelper_ThiefScanner_Init();
    Ninja_MaxXPHelper_XPNPCLocator_Init();
    Ninja_MaxXPHelper_WarningAlerts_Init();
};
