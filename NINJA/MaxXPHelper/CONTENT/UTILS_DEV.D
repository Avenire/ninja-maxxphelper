// Bunch of code for tracing issues which should not ever be needed in release builds.
func string Ninja_MaxXPHelper_GetInstanceName(var oCNPC npc) {
    var int symbolPtr; symbolPtr = MEM_GetSymbolByIndex(Hlp_GetInstanceID(npc));
    if !symbolPtr {
        return "";
    };
    var zCPar_Symbol symbol; symbol = _^(symbolPtr);
    return symbol.name;
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
