const string Ninja_MaxXPHelper_LOC_RIPPrefix = "RIP: ";
const string Ninja_MaxXPHelper_LOC_DoubleXPMeleeFinisherTip = "Double XP Glitch - Lost ZS_Dead XP";
const string Ninja_MaxXPHelper_LOC_WarnDoubleXPViolation = "used Double XP Glitch";
const string Ninja_MaxXPHelper_LOC_WarnKilledSummon = "killed summoned creature";
const string Ninja_MaxXPHelper_LOC_DoubleXPNoZSUnconsciousXP = "Double XP Glitch - Lost ZS_Unconscious XP";

const string Ninja_MaxXPHelper_LOC_LostVictoryXP = "Lost XP";
const string Ninja_MaxXPHelper_LOC_KilledBy = "killed by ";
const string Ninja_MaxXPHelper_LOC_XPNotRegisteredBug = "no XP received bug";

const string Ninja_MaxXPHelper_LOC_LocatorOn = "XPNPCLocator ON";
const string Ninja_MaxXPHelper_LOC_LocatorOff = "XPNPCLocator OFF";

const string Ninja_MaxXPHelper_LOC_TrackersUseZBufferOn = "Trackers Use Z Buffer ON";
const string Ninja_MaxXPHelper_LOC_TrackersUseZBufferOff = "Trackers Use Z Buffer OFF";

const string Ninja_MaxXPHelper_LOC_TrackersMaxRenderingEnabledOn = "Trackers Max Rendering Level On";
const string Ninja_MaxXPHelper_LOC_TrackersMaxRenderingEnabledOff = "Trackers Max Rendering Level Off";
const string Ninja_MaxXPHelper_LOC_ConsiderPickpocketingEnabled = "(Pickpocketing Enabled)";

const string Ninja_MaxXPHelper_LOC_PickpocketWarningOther = "Not Pickpocketable Anymore (Item Was Likely Looted)";
const string Ninja_MaxXPHelper_LOC_PickpocketWarningDeath = "Not Pickpocketable Anymore (NPC Died)";

const string Ninja_MaxXPHelper_LOC_PickpocketWarningOther = "Not Pickpocketable Anymore (Item Was Likely Looted)";
const string Ninja_MaxXPHelper_LOC_PickpocketWarningDeath = "Not Pickpocketable Anymore (NPC Died)";

const string Ninja_MaxXPHelper_LOC_XPLocatorModeAll = "XPLocator ON - all";
const string Ninja_MaxXPHelper_LOC_XPLocatorModePickpocket = "XPLocator ON - NPCs to pickpocket";
const string Ninja_MaxXPHelper_LOC_XPLocatorModeItems = "XPLocator ON - XP run relevant items";

const string Ninja_MaxXPHelper_LOC_XPLocatorModeNPCsToBeat = "XPLocator ON - NPCs to beat";

const string Ninja_MaxXPHelper_LOC_WarningsBerryCount = "Goblin Berries count scanned = ";
const string Ninja_MaxXPHelper_LOC_Swampherbscount = "Swamp herbs count scanned = ";

// https://github.com/szapp/Ninja/wiki/Inject-Changes#localization
func int Ninja_MaxXPHelper_GuessLocalization() { // Adjust the name!
    const int pan = 0; pan = MEM_GetSymbol("MOBNAME_PAN");
    if (pan) {
        var zCPar_Symbol panSymb; panSymb = _^(pan);
        var string panName; panName = MEM_ReadString(panSymb.content);
        if (Hlp_StrCmp(panName, "Pfanne")) { // DE (Windows 1252)
            return 1;
        } else if (Hlp_StrCmp(panName, "Patelnia")) { // PL (Windows 1250)
            return 2;
        } else if (Hlp_StrCmp(panName, "Сковорода")) { // RU (Windows 1251)
            return 3;
        };
    };
    return 0;
};

func void Ninja_MaxXPHelper_Localization_Init() {
    const int lang = 0; lang = Ninja_MaxXPHelper_GuessLocalization();
    // todo
};