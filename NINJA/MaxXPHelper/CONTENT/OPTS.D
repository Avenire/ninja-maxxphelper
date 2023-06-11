const string Ninja_MaxXPHelper_SectionName = "MaxXPHelper-V1";
const string Ninja_MaxXPHelper_TrackersUseZBuffer_OptKey = "trackersUseZBuffer";

const int Ninja_MaxXPHelper_ToggleXPNPCLocatorKeyCode = 0;
const int Ninja_MaxXPHelper_ToggleTrackersMaxRenderingLevelKeyCode = 0;
const int Ninja_MaxXPHelper_TrackersUseZBuffer = 0;
const int Ninja_MaxXPHelper_ToggleTrackersUseZBufferKeyCode = 0;
const int Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch = 0;
const int Ninja_MaxXPHelper_ConsiderLevelZeroNPC = 0;
const int Ninja_MaxXPHelper_ShowDeathAlerts = 0;
const string Ninja_MaxXPHelper_DeadOnArrivalNPCList = "";
const string Ninja_MaxXPHelper_DeathAlertsSVM = "";
const int Ninja_MaxXPHelper_TrackersRenderingLevel = 5;
const int Ninja_MaxXPHelper_ShowTrackerOnDeathAlert = 1;
const int Ninja_MaxXPHelper_DeathAlertTrackerDurationInMillis = 5000;
const int Ninja_MaxXPHelper_DeathAlertTextDurationInMillis = 5000;

const int Ninja_MaxXPHelper_DeathAlertsFailColor = 0;
const int Ninja_MaxXPHelper_SystemNotificationsColor = 0;
const int Ninja_MaxXPHelper_PickpocketAlertsWarningColor = 0;
const int Ninja_MaxXPHelper_ConsiderPickpocketing = 0;


func int Ninja_MaxXPHelper_GetKeyCodeOptOrSetDefault(var string optionKey, var string defaultKeyName) {
    var int keyCode; keyCode = 0;
    var zCPar_Symbol symb;
    if MEM_GothOptExists(Ninja_MaxXPHelper_SectionName, optionKey) {
        var string configuredKey; configuredKey = MEM_GetGothOpt(Ninja_MaxXPHelper_SectionName, optionKey);
        var int symbolPtr; symbolPtr = MEM_GetSymbol(configuredKey);
        if symbolPtr {
            symb = _^(symbolPtr);
            if symb.content && 
                (
                    (symb.content >= KEY_ESCAPE && symb.content <= KEY_MEDIASELECT) ||
                    (symb.content >= MOUSE_BUTTONLEFT && symb.content <= MOUSE_XBUTTON5)
                ) {
                keyCode = symb.content;
            };
        };  
    };
    if !keyCode {
        if STR_Len(defaultKeyName) {
            symb = _^(MEM_GetSymbol(defaultKeyName));
            keyCode = symb.content;
        };
        MEM_SetGothOpt(Ninja_MaxXPHelper_SectionName, optionKey, defaultKeyName);
    };
    if keyCode {
        MEM_SetKey(ConcatStrings(Ninja_MaxXPHelper_SectionName, optionKey), keyCode);
    };
    return keyCode;
};

func void Ninja_MaxXPHelper_SetIntOpt(var string optionKey, var int value) {
    MEM_SetGothOpt(Ninja_MaxXPHelper_SectionName, optionKey, IntToString(value));
};

func int Ninja_MaxXPHelper_GetIntOptOrSetDefault(var string optionKey, var int defaultValue) {
    var int value; value = defaultValue;
    if MEM_GothOptExists(Ninja_MaxXPHelper_SectionName, optionKey) {
        value = STR_ToInt(
            MEM_GetGothOpt(
                Ninja_MaxXPHelper_SectionName, 
                optionKey
            )
        );
    } else {
        Ninja_MaxXPHelper_SetIntOpt(optionKey, value);
    };
    return value;
};

func string Ninja_MaxXPHelper_GetStrOptOrSetDefault(var string optionKey, var string defaultValue) {
    if MEM_GothOptExists(Ninja_MaxXPHelper_SectionName, optionKey) {
        defaultValue = MEM_GetGothOpt(Ninja_MaxXPHelper_SectionName, optionKey);
    } else {
        MEM_SetGothOpt(Ninja_MaxXPHelper_SectionName, optionKey, defaultValue);
        MEM_ApplyGothOpt();
    };
    return defaultValue;
};

func int Ninja_MaxXPHelper_GetRGBColorOptOrSetDefault(var string optionKey, var int defaultValue) {
    if MEM_GothOptExists(Ninja_MaxXPHelper_SectionName, optionKey) {
        var string colorHex; colorHex = MEM_GetGothOpt(Ninja_MaxXPHelper_SectionName, optionKey);
        var int colorHexLen; colorHexLen = STR_Len(colorHex);        
        // #RRGGBB is 7 chars
        if  colorHexLen == 7 && 
            STR_GetCharAt(colorHex, 0) == STR_ToChar("#") {
            SB("#");
            SB(IntToString(STR_GetCharAt(colorHex, 1)));
            SB(" ");
            SB(
                IntToString(MEMINT_HexCharToInt(STR_GetCharAt(colorHex, 1)))
            );
            SB_Clear();
            SB_Destroy();
            return RGBA(
                MEMINT_HexCharToInt(STR_GetCharAt(colorHex, 1)) << 4 | MEMINT_HexCharToInt(STR_GetCharAt(colorHex, 2)),
                MEMINT_HexCharToInt(STR_GetCharAt(colorHex, 3)) << 4 | MEMINT_HexCharToInt(STR_GetCharAt(colorHex, 4)),
                MEMINT_HexCharToInt(STR_GetCharAt(colorHex, 5)) << 4 | MEMINT_HexCharToInt(STR_GetCharAt(colorHex, 6)),
                Ninja_MaxXPHelper_ColorMaxInt
            );
        };
    };
    var int s; s = SB_New();
    SB("#");
    SB(MEMINT_ByteToKeyHex(defaultValue>>16));
    SB(MEMINT_ByteToKeyHex(defaultValue>>8));
    SB(MEMINT_ByteToKeyHex(defaultValue));
    MEM_SetGothOpt(Ninja_MaxXPHelper_SectionName, optionKey, SB_ToString());
    SB_Clear();
    SB_Destroy();
    return ChangeAlpha(defaultValue, Ninja_MaxXPHelper_ColorMaxInt);
};

func string Ninja_MaxXPHelper_ReadFileOrSetDefault(var string filename, var string default) {
    var string value; value = default;
    if BR_OpenFile(filename)
    { 
        value = BR_TextLine();
        BR_Close();           
    } else if BW_NewFile(filename) 
    { 
        BW_Text(default);
        BW_NextLine();
        BW_Close();
    };
    return value;
};
