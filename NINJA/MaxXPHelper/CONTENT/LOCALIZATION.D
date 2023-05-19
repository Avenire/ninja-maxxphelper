const string Ninja_MaxXPHelper_LOC_RIPPrefix = "RIP: ";
const string Ninja_MaxXPHelper_LOC_ScriptedDeathTip = "(Scripted Death)";
const string Ninja_MaxXPHelper_LOC_DoubleXPMeleeFinisherTip = "(Double XP Glitch - Lost Magic/Range Kill XP)";
const string Ninja_MaxXPHelper_LOC_DoubleXPNoZSUnconsciousXP = "(Double XP Glitch - Lost Victory XP)";
const string Ninja_MaxXPHelper_LOC_LocatorOn = "Locator ON";
const string Ninja_MaxXPHelper_LOC_LocatorOff = "Locator OFF";


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