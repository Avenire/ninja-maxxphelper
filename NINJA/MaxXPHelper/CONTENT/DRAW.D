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
