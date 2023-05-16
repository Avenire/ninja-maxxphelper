// It's a looooong list, see tools/g2notr_print_doa_npcs.py for how it was extracted; 
// Some NPCs here have level 0 so would likely be skipped anyway.
const string DefaultDeadOnArrivalNPCs = "Stoneguardian_Dead1;Stoneguardian_Dead2;Stoneguardian_Dead3;NOV_650_ToterNovize;NOV_651_ToterNovize;NOV_652_ToterNovize;NOV_653_ToterNovize;NOV_654_ToterNovize;NOV_655_ToterNovize;NOV_656_ToterNovize;DJG_730_ToterDrachenjaeger;DJG_731_ToterDrachenjaeger;DJG_732_ToterDrachenjaeger;DJG_733_ToterDrachenjaeger;DJG_734_ToterDrachenjaeger;DJG_735_ToterDrachenjaeger;DJG_736_ToterDrachenjaeger;DJG_737_ToterDrachenjaeger;DJG_738_ToterDrachenjaeger;DJG_739_ToterDrachenjaeger;DJG_740_ToterDrachenjaeger;PAL_297_Ritter;PAL_298_Ritter;YGiant_Bug_VinoRitual1;YGiant_Bug_VinoRitual2;BDT_10400_Addon_DeadBandit;BDT_10401_Addon_DeadBandit;VLK_4145_Waffenknecht;VLK_4146_Waffenknecht;VLK_4147_Waffenknecht;VLK_4101_Waffenknecht;VLK_4102_Waffenknecht;VLK_4103_Waffenknecht;VLK_4104_Waffenknecht;VLK_4105_Waffenknecht;Bruder;VLK_Leiche3;VLK_Leiche2;STRF_Leiche1;STRF_Leiche2;STRF_Leiche3;STRF_Leiche4;STRF_Leiche5;STRF_Leiche6;STRF_Leiche7;STRF_Leiche8;PAL_Leiche1;PAL_Leiche2;PAL_Leiche3;VLK_Leiche1;PAL_Leiche4;PAL_Leiche5;Olav;PIR_1370_Addon_Angus;PIR_1371_Addon_Hank;VLK_4304_Addon_William;NONE_Addon_114_Lance_ADW;STRF_1131_Addon_Sklave;STRF_1132_Addon_Sklave;STRF_1133_Addon_Sklave;STRF_1134_Addon_Sklave;STRF_1135_Addon_Sklave;STRF_1141_Addon_Sklave;STRF_1142_Addon_Sklave;STRF_1143_Addon_Sklave;STRF_1144_Addon_Sklave;BDT_10400_Addon_DeadBandit;BDT_10401_Addon_DeadBandit;Stoneguardian_MineDead1;Stoneguardian_MineDead2;Stoneguardian_MineDead3;Stoneguardian_MineDead4";

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