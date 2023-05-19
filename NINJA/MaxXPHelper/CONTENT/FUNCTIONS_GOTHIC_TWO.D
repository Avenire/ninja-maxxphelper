// It's a looooong list, see tools/g2notr_print_doa_npcs.py for how it was extracted; 
// Some NPCs here have level 0 so would likely be skipped anyway.
const string Ninja_MaxXPHelper_DeadOnArrivalNPCDefaultList = "VLK_4304_Addon_William;Stoneguardian_MineDead4;;VLK_4103_Waffenknecht;YGiant_Bug_VinoRitual1;PAL_297_Ritter;VLK_Leiche1;STRF_Leiche2;NOV_653_ToterNovize;Stoneguardian_MineDead2;STRF_1143_Addon_Sklave;NONE_Addon_114_Lance_ADW;STRF_1132_Addon_Sklave;DJG_731_ToterDrachenjaeger;VLK_4105_Waffenknecht;NOV_656_ToterNovize;YGiant_Bug_VinoRitual2;PAL_Leiche4;Stoneguardian_Dead3;STRF_1141_Addon_Sklave;STRF_Leiche7;STRF_1135_Addon_Sklave;Stoneguardian_MineDead3;PIR_1370_Addon_Angus;BDT_10401_Addon_DeadBandit;VLK_4147_Waffenknecht;STRF_Leiche8;DJG_738_ToterDrachenjaeger;DJG_730_ToterDrachenjaeger;NOV_654_ToterNovize;STRF_1142_Addon_Sklave;NOV_652_ToterNovize;VLK_Leiche2;VLK_4145_Waffenknecht;PIR_1371_Addon_Hank;Stoneguardian_Dead1;PAL_Leiche5;STRF_1144_Addon_Sklave;DJG_740_ToterDrachenjaeger;STRF_1131_Addon_Sklave;STRF_Leiche5;VLK_Leiche3;STRF_1134_Addon_Sklave;Stoneguardian_MineDead1;Bruder;DJG_739_ToterDrachenjaeger;STRF_Leiche3;VLK_4152_Olav;STRF_Leiche4;DJG_737_ToterDrachenjaeger;NOV_655_ToterNovize;PAL_298_Ritter;VLK_4104_Waffenknecht;DJG_735_ToterDrachenjaeger;STRF_Leiche1;STRF_Leiche6;Stoneguardian_Dead2;NOV_650_ToterNovize;DJG_734_ToterDrachenjaeger;BDT_10400_Addon_DeadBandit;VLK_4101_Waffenknecht;VLK_4102_Waffenknecht;PAL_Leiche3;DJG_732_ToterDrachenjaeger;PAL_Leiche1;VLK_4146_Waffenknecht;DJG_733_ToterDrachenjaeger;PAL_Leiche2;NOV_651_ToterNovize;DJG_736_ToterDrachenjaeger;STRF_1133_Addon_Sklave;";

func int Ninja_MaxXPHelper_VictoryXPReceived(var c_npc npc) {
    return npc.aivar[AIV_VictoryXPGiven];
};

func int Ninja_MaxXPHelper_WouldReceiveVictoryXP(var c_npc self, var c_npc other) {
    return ((Npc_IsPlayer(other) || (other.aivar[AIV_PARTYMEMBER] == TRUE)) && !Ninja_MaxXPHelper_VictoryXPReceived(self));
};

func int Ninja_MaxXPHelper_IsKnockable(var c_npc _self, var c_npc _other) {
    var c_npc selfBak; selfBak = Hlp_GetNpc (self);
    var c_npc otherBak; otherBak = Hlp_GetNpc (other);
    self = Hlp_GetNpc (selfBak);
    other = Hlp_GetNpc (other);
    var int res; res = C_DropUnconscious();
    self = Hlp_GetNpc (selfBak);
    self = Hlp_GetNpc (otherBak);
    return res;
};
