// todo: cache list so NPCs are not looped over every frame.
func void Ninja_MaxXPHelper_MortalNPCLocator()
{   
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
        var zCVob vob; vob = _^(list.data);
        var oCNPC npc; npc = _^(list.data);
        if !( 
            (slf.flags & NPC_FLAG_IMMORTAL) || 
            Npc_IsDead(slf) || 
            Npc_IsPlayer(slf) ||
            (!Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch && slf.aivar[AIV_WASDEFEATEDBYSC]) ||
            (!Ninja_MaxXPHelper_ConsiderLevelZeroNPC && slf.level <= 0)
        ) 
        {
            var int color; color = Ninja_MaxXPHelper_SphereColorNotBeaten;
            if Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch && slf.aivar[AIV_WASDEFEATEDBYSC] {
                color = Ninja_MaxXPHelper_SphereColorConsiderG1DoubleXPGlitch;
            };
            var int x; x = npc._zCVob_trafoObjToWorld[3];
            var int y; y = npc._zCVob_trafoObjToWorld[7];
            var int z; z = npc._zCVob_trafoObjToWorld[11];

            if (vob.bitfield[0] & zCVob_bitfield4_dontWriteIntoArchive) == 0 {
                color = Ninja_MaxXPHelper_SphereColorNotLoadedIntoGameYet;
                const int call = 0;
                waypointNamePtr = _@s(npc.wpname);
                if (CALL_Begin(call))
                {
                    CALL__fastcall (_@(MEM_World.wayNet), _@(waypointNamePtr), MEMINT_SwitchG1G2(7366448, 8061744));
                    call = CALL_End();  
                };
                var int waypointPointer; waypointPointer = CALL_RetValAsInt();
                if waypointPointer {
                    var zCWaypoint wp; wp = _^(waypointPointer);
                    x = wp.pos[0];
                    y = wp.pos[1];
                    z = wp.pos[2];
                } else {
                    color = 0;
                };
            };
            if color {
                Ninja_MaxXPHelper_DrawSphere(
                    x, y, z, color, 
                    Ninja_MaxXPHelper_SphereRadius
                );
            };
        };
	end;
};