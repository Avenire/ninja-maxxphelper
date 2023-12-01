
// Slightly modifies PrintS_Ext & gCPrintS_Alpha from LeGo (https://github.com/Lehona/LeGo/blob/dev/Interface.d)
const int _Ninja_MaxXPHelper_TextAlert_TextVirtualOffset = 0;
const int _Ninja_MaxXPHelper_TextAlert_TextHeight = 0;
const string _Ninja_MaxXPHelper_TextAlert_Font = "FONT_OLD_20_WHITE.tga";

func void _Ninja_MaxXPHelper_gCPrintS_Alpha(var int h, var int value) {
    var gCPrintS p; p = get(h);
    var zCViewText t; t = get(p.tv_Text);
    t.color = ChangeAlpha(t.color, value);
    if(_Ninja_MaxXPHelper_TextAlert_TextVirtualOffset > p.vr_Offs) {
        p.vr_Pos += (_Ninja_MaxXPHelper_TextAlert_TextVirtualOffset - p.vr_Offs) * _Ninja_MaxXPHelper_TextAlert_TextHeight;
        Anim8(p.a8_Movement, p.vr_Pos, PF_MoveYTime, A8_SlowEnd);
        p.vr_Offs = _Ninja_MaxXPHelper_TextAlert_TextVirtualOffset;
    };
};

func void Ninja_MaxXPHelper_PrintS_Ext(var string message, var int alertDuration, var int color) {
    if !_Ninja_MaxXPHelper_TextAlert_TextHeight {
        _Ninja_MaxXPHelper_TextAlert_TextHeight = Print_ToVirtual(Print_GetFontHeight(_Ninja_MaxXPHelper_TextAlert_Font), PS_Y);
    };
    const int h = 0; h = new(gCPrintS@);
    var gCPrintS p; p = get(h);
    const int v = 0; v = Anim8_NewExt(1, _Ninja_MaxXPHelper_gCPrintS_Alpha, h, false);
    Anim8_RemoveIfEmpty(v, true);
    Anim8_RemoveDataIfEmpty(v, true);
    Anim8 (v, 255, PF_FadeInTime,  A8_Constant);
    Anim8q(v, 0,   alertDuration - PF_FadeInTime - PF_FadeOutTime, A8_Wait);
    Anim8q(v, 0,   PF_FadeOutTime, A8_SlowStart);
    p.a8_Alpha = v;

    v = Anim8_NewExt(0, gCPrintS_Position, h, false);
    Anim8 (v, _Ninja_MaxXPHelper_TextAlert_TextHeight, PF_MoveYTime, A8_SlowEnd);
    p.a8_Movement = v;

    p.tv_Text = Print_Ext(-1, 0, message, _Ninja_MaxXPHelper_TextAlert_Font, color, -1);
    p.vr_Pos = _Ninja_MaxXPHelper_TextAlert_TextHeight;
    p.vr_Offs = _Ninja_MaxXPHelper_TextAlert_TextVirtualOffset;
    _Ninja_MaxXPHelper_TextAlert_TextVirtualOffset += 1;
};