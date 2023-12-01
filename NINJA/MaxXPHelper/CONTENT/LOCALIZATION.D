const string Ninja_MaxXPHelper_LOC_RIPPrefix = "RIP: ";
const string Ninja_MaxXPHelper_LOC_ScriptedDeathTip = "(Scripted Death)";
const string Ninja_MaxXPHelper_LOC_DoubleXPMeleeFinisherTip = "(Double XP Glitch - Lost Magic/Range Kill XP)";
const string Ninja_MaxXPHelper_LOC_DoubleXPNoZSUnconsciousXP = "(Double XP Glitch - Lost Victory XP)";
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

// https://github.com/szapp/Ninja/wiki/Inject-Changes#localization
func int Ninja_MaxXPHelper_GuessLocalization() { // Adjust the name!
    var int pan; pan = MEM_GetSymbol("MOBNAME_PAN");
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
    var int lang; lang = Ninja_MaxXPHelper_GuessLocalization();
    // todo
};