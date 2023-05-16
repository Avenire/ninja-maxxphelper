// Rendering code borrowed from 
// https://forum.worldofplayers.de/forum/threads/1577038-Patch-Item-Locator
func void Ninja_MaxXPHelper_DrawSphere(var int x, var int y, var int z, var int color, var int radius)
{
    var int sphere[4]; 
    sphere[0] = x;
    sphere[1] = y;
    sphere[2] = z;
    sphere[3] = mkf(radius);

    const int cPtr = 0;
    const int sPtr = 0;
    const int call = 0;
    if (CALL_Begin(call))
    {
        cPtr = _@(color);
        sPtr = _@(sphere);
        CALL_IntParam(_@(cPtr));
        CALL__thiscall(_@(sPtr), zTBSphere3D__Draw);
        call = CALL_End();
    };
};

const int _Ninja_MaxXPHelper_DrawNPCSphere_call = 0;
const int _Ninja_MaxXPHelper_DrawNPCSphere_waypointNamePtr = 0;
func void Ninja_MaxXPHelper_DrawNPCSphere(var oCNPC npc, var int color, var int radius) {
        var int x; x = npc._zCVob_trafoObjToWorld[3];
        var int y; y = npc._zCVob_trafoObjToWorld[7];
        var int z; z = npc._zCVob_trafoObjToWorld[11];
        var int ok; ok = TRUE;
        // Note: Should be bitfield at index 4 according to the constant but this worked in testing.
        if npc._zCVob_bitfield[0] & zCVob_bitfield4_dontWriteIntoArchive {
            // NPC not physically placed in the world, try using waypoint location instead.
            _Ninja_MaxXPHelper_DrawNPCSphere_waypointNamePtr = _@s(npc.wpname);
            if (CALL_Begin(_Ninja_MaxXPHelper_DrawNPCSphere_call))
            {
                CALL__fastcall (_@(MEM_World.wayNet), _@(_Ninja_MaxXPHelper_DrawNPCSphere_waypointNamePtr), MEMINT_SwitchG1G2(7366448, 8061744));
                _Ninja_MaxXPHelper_DrawNPCSphere_call = CALL_End();  
            };
            var int waypointPointer; waypointPointer = CALL_RetValAsInt();
            if waypointPointer {
                    var zCWaypoint wp; wp = _^(waypointPointer);
                    x = wp.pos[0];
                    y = wp.pos[1];
                    z = wp.pos[2];
            } else {
                ok = FALSE;
            };
        };
        Ninja_MaxXPHelper_DrawSphere(x, y, z, color, Ninja_MaxXPHelper_SphereRadius);
};
