const int Ninja_MaxXPHelper_MortalNPCLocator_Enabled = 0;

// todo: cache list so NPCs are not looped over every frame.
func void _Ninja_MaxXPHelper_MortalNPCLocator_Refresh()
{   
    // todo use icarus exposed member
    var int listPtr; listPtr = +(MEM_ReadInt (_@ (MEM_World) + MEMINT_SwitchG1G2 (25196, 25220)));
    var zCListSort list;
    var int waypointNamePtr; 
    while (listPtr);
		list = _^ (listPtr);
        listPtr = list.next;
        if !list.data {
            continue;
        };
        var c_npc slf; slf = _^ (list.data);
        if !( 
            (slf.flags & NPC_FLAG_IMMORTAL) || 
            Npc_IsDead(slf) || 
            Npc_IsPlayer(slf) ||
            (!Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch && Ninja_MaxXPHelper_VictoryXPReceived(slf)) ||
            (!Ninja_MaxXPHelper_ConsiderLevelZeroNPC && slf.level <= 0)
        ) 
        {
            var int color; color = Ninja_MaxXPHelper_SphereColorNotBeaten;
            if Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch && Ninja_MaxXPHelper_VictoryXPReceived(slf) {
                color = Ninja_MaxXPHelper_SphereColorConsiderG1DoubleXPGlitch;
            };
            var oCNPC npc; npc = _^(list.data);
            Ninja_MaxXPHelper_DrawNPCSphere(npc, color, Ninja_MaxXPHelper_SphereRadius);
        };
	end;
};

func void _Ninja_MaxXPHelper_InputLoop() 
{    
    if MEM_KeyState(Ninja_MaxXPHelper_ToggleMortalNPCLocatorKeyCode) == KEY_PRESSED {
        Ninja_MaxXPHelper_MortalNPCLocator_Enabled = !Ninja_MaxXPHelper_MortalNPCLocator_Enabled;
    };
};

func void _Ninja_MaxXPHelper_RenderLoop() 
{
    if Ninja_MaxXPHelper_MortalNPCLocator_Enabled {
        _Ninja_MaxXPHelper_MortalNPCLocator_Refresh();
    };
    if Ninja_MaxXPHelper_ShowMissedXPOnNPCDeathAlerts {
        // todo reimplement
    };
};

func void Ninja_MaxXPHelper_MortalNPCLocator_Init() {
    FF_ApplyExtGT(_Ninja_MaxXPHelper_InputLoop, 0, -1);
    FF_ApplyExtGT(_Ninja_MaxXPHelper_RenderLoop, 100, -1);
};
