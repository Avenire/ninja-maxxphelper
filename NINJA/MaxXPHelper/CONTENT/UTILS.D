func void Ninja_MaxXPHelper_LogInfo(var string message) {
    MEM_Info(ConcatStrings("MaxXPHelper: " , message));
};

func int Ninja_MaxXPHelper_GetKeyOrDefault(var string optionKey, var string defaultKeyName) {
    var int keyCode;
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
        symb = _^(MEM_GetSymbol(defaultKeyName));
        keyCode = symb.content;
        MEM_SetGothOpt(Ninja_MaxXPHelper_SectionName, optionKey, defaultKeyName);
    };
    return keyCode;
};

func int Ninja_MaxXPHelper_GetFlagOrDefault(var string optionKey, var int defaultValue) {
    var int value; value = defaultValue;
    if MEM_GothOptExists(Ninja_MaxXPHelper_SectionName, optionKey) {
        value = STR_ToInt(
            MEM_GetGothOpt(
                Ninja_MaxXPHelper_SectionName, 
                optionKey
            )
        );
    } else {
        MEM_SetGothOpt(Ninja_MaxXPHelper_SectionName, optionKey, IntToString(value));
    };
    return value;
};

func string Ninja_MaxXPHelper_GetStrOptOrDefault(var string optionKey, var string defaultValue) {
    if MEM_GothOptExists(Ninja_MaxXPHelper_SectionName, optionKey) {
        defaultValue = MEM_GetGothOpt(Ninja_MaxXPHelper_SectionName, optionKey);
    } else {
        MEM_SetGothOpt(Ninja_MaxXPHelper_SectionName, optionKey, defaultValue);
        MEM_ApplyGothOpt();
    };
    return defaultValue;
};

func void Ninja_MaxXPHelper_PrintBinary(var int bitfield) {
    repeat(i, 32); var int i;
        if (bitfield & (1 << i)) {
            SB("1");
        } else {
            SB("0");
        };
    end;
};

func void Ninja_MaxXPHelper_HT_DestroyPtr(var int htPtr) {
    if !htPtr { return; };
    _HT_Destroy(htPtr);
};

func void Ninja_MaxXPHelper_oCNPCDebug(var oCNPC npc, var string prefix) {
        var int symbolPtr; symbolPtr = MEM_GetSymbolByIndex(Hlp_GetInstanceID(npc));
        var zCPar_Symbol symbol; symbol = _^(symbolPtr);
        const int pad = 30;
        var string shortName; shortName = STR_Prefix(symbol.name, pad);
        shortName = ConcatStrings(shortName, STR_Prefix("                               ", pad - STR_Len(shortName)));
        var int s; s = SB_New();
        SB(prefix);
        SB(" ");
        SB(shortName);
        SB(" oCNPC ");
        repeat(i, 5); var int i;
            var int val; val = MEM_ReadStatArr(npc.bitfield, i);
            Ninja_MaxXPHelper_PrintBinary(val);
            SB(" ");
        end;
        SB(" zCVob ");
        repeat(i, 5); var int i;
            //Ninja_MaxXPHelper_PrintBinary(MEM_ReadInt(_@(npc) + MEMINT_SwitchG1G2(1948, 1884) + i * 4));
            Ninja_MaxXPHelper_PrintBinary(MEM_ReadInt(_@(npc) + MEMINT_SwitchG1G2(228, 260) + i * 4));
            SB(" ");
        end;
        Ninja_MaxXPHelper_LogInfo(SB_ToString());
        SB_Clear();
        SB_Destroy();
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

func int Ninja_MaxXPHelper_GetColorOptOrDefault(var string optionKey, var int defaultValue) {
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

func int Ninja_MaxXPHelper_ShouldRunHook() {
    return !(
        !Hlp_IsValidNpc(hero) ||
        Npc_IsDead(hero) ||
        MEM_Game.pause_screen ||
        Timer_IsPaused()
    );
};

// Don't want handles from Hashtables to be persisted in Save Game file so
// workarounding that by calling Lego "private" hashtable API working on pointers
func int Ninja_MaxXPHelper_HT_Create() {
    return _HT_Create();
};

func int Ninja_MaxXPHelper_HT_Get(var int ptr, var int key) {
    return _HT_Get(ptr, key);
};

func void Ninja_MaxXPHelper_HT_Insert(var int ptr, var int value, var int key) {
    _HT_Insert(ptr, value, key);
};

func void Ninja_MaxXPHelper_HT_Remove(var int ptr, var int key) {
    _HT_Remove(ptr, key);
};

func void Ninja_MaxXPHelper_HT_ForEach(var int ptr, var func onEachFunc) {
    _HT_ForEach(ptr, onEachFunc);
};