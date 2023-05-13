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
