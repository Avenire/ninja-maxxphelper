const int _Ninja_MaxXPHelper_DeathAlerts_DeadOnArrivalNpc_HT = 0;
const int _Ninja_MaxXPHelper_DeathAlerts_B_MagicHurtNpc_Killed_To_RealKiller_HT = 0;
const int _Ninja_MaxXPHelper_DeathAlerts_RemovedNPCs_HT = 0;
const int _Ninja_MaxXPHelper_DeathAlerts_AlertIdToTrackerId_HT = 0;
const int _Ninja_MaxXPHelper_DeathAlerts_LastSVM = 0;
const int _Ninja_MaxXPHelper_DeathAlerts_B_DeathXPHack_HT = 0;
const int _Ninja_MaxXPHelper_DeathAlerts_DoDie_Queue = -1;
const int _Ninja_MaxXPHelper_DeathAlerts_SVMThrottleInMillis = 10000;

class _Ninja_MaxXPHelper_OnDeadEvent {
    const int victimPtr = 0;
    const int timeOfDeath = 0;

    var string cause;
    const int wasImmortal = FALSE;
};
instance _Ninja_MaxXPHelper_OnDeadEvent@(_Ninja_MaxXPHelper_OnDeadEvent);

func void Ninja_MaxXPHelper_DeathAlerts_InitDeadOnArrivalNPCList() {
    STRINT_SplitReset();
    const int count = 0; count = STR_SplitCount(Ninja_MaxXPHelper_DeadOnArrivalNPCList, ";");
    Ninja_MaxXPHelper_HT_Destroy(_Ninja_MaxXPHelper_DeathAlerts_DeadOnArrivalNpc_HT);
    _Ninja_MaxXPHelper_DeathAlerts_DeadOnArrivalNpc_HT = Ninja_MaxXPHelper_HT_Create();
    repeat(i, count); const int i = 0;
        const string npcCode = ""; npcCode = STRINT_SplitGet(i);
        const int instanceId = 0; instanceId = MEM_GetSymbolIndex(npcCode);
        if Ninja_MaxXPHelper_HT_Get(
            _Ninja_MaxXPHelper_DeathAlerts_DeadOnArrivalNpc_HT,
            instanceId
        ) > 0 {
            continue;
        };
        if instanceId > -1 {
            Ninja_MaxXPHelper_HT_Insert(
                _Ninja_MaxXPHelper_DeathAlerts_DeadOnArrivalNpc_HT,
                TRUE,
                instanceId
            );
        };
    end;
};



func void _Ninja_MaxXPHelper_DeathAlerts_AutoExpireTrackerOnAlertShown(var int alertHandle) {
    const int trackerHandle = 0; trackerHandle = Ninja_MaxXPHelper_HT_Get(_Ninja_MaxXPHelper_DeathAlerts_AlertIdToTrackerId_HT, alertHandle);
    Ninja_MaxXPHelper_Trackers_SetAutoExpire(trackerHandle, Ninja_MaxXPHelper_DeathAlertTrackerDurationInMillis);
    if  STR_Len(Ninja_MaxXPHelper_DeathAlertsSVM) > 0 && 
        !Npc_IsDead(hero) && 
        TimerGT() - _Ninja_MaxXPHelper_DeathAlerts_LastSVM > _Ninja_MaxXPHelper_DeathAlerts_SVMThrottleInMillis {
        AI_OutputSVM_Overlay(hero,hero,Ninja_MaxXPHelper_DeathAlertsSVM);
        _Ninja_MaxXPHelper_DeathAlerts_LastSVM = TimerGT();
    };
};

func void _Ninja_MaxXPHelper_DeathAlerts_TriggerAlert(var c_npc cnpc, var string msg) {
    const int alertHandle = 0; alertHandle = Ninja_MaxXPHelper_TextAlerts_Create(
        msg,  
        Ninja_MaxXPHelper_DeathAlertTextDurationInMillis, 
        Ninja_MaxXPHelper_DeathAlertsFailColor, 
        FALSE
    );
    _Ninja_MaxXPHelper_LogXPToCSV(-cnpc.level * XP_PER_VICTORY, ConcatStrings(cnpc.name, " XP lost"), cnpc);
    var oCNPC npc; npc = Hlp_GetNpc(cnpc);
    if Ninja_MaxXPHelper_ShowTrackerOnDeathAlert && Ninja_MaxXPHelper_IsNpcSpawned(npc) {
        const int h = 0; h = Ninja_MaxXPHelper_Trackers_Create();
        Ninja_MaxXPHelper_HT_Insert(_Ninja_MaxXPHelper_DeathAlerts_AlertIdToTrackerId_HT, h, alertHandle);
        Ninja_MaxXPHelper_TextAlerts_SetOnShowFunc(alertHandle, _Ninja_MaxXPHelper_DeathAlerts_AutoExpireTrackerOnAlertShown);
        const int x = 0; x = npc._zCVob_trafoObjToWorld[3];
        const int y = 0; y = npc._zCVob_trafoObjToWorld[7];
        const int z = 0; z = npc._zCVob_trafoObjToWorld[11];
        Ninja_MaxXPHelper_Trackers_Show(
            h,
            x, y, z,
            Ninja_MaxXPHelper_DeathAlertsFailColor, 
            Ninja_MaxXPHelper_Trackers_MaxPriority,
            "MAXXPHELPER_DEATH_ALERT2.tga"
        );
    };
};

func int _Ninja_MaxXPHelper_DeathAlerts_Handler_SkipDeadOnArrivalNPC(var c_npc _self) {
    const int instanceId = 0; instanceId = Hlp_GetInstanceID(_self);
    return Ninja_MaxXPHelper_HT_Get(_Ninja_MaxXPHelper_DeathAlerts_DeadOnArrivalNpc_HT, instanceId);
};

func void _Ninja_MaxXPHelper_DeathAlerts_DoDieCheckAlert(var c_npc npc, var string cause) {
    Ninja_MaxXPHelper_LogInfo(ConcatStrings("_Ninja_MaxXPHelper_DeathAlerts_DoDieCheckAlert ", npc.name));
    if Npc_WasInState(npc, ZS_Dead) {
        // When you exit orc graveyard, orcs outside "die" 2nd time...
        Ninja_MaxXPHelper_LogInfo(ConcatStrings("_Ninja_MaxXPHelper_DeathAlerts_DoDieCheckAlert skip - was ZS_Dead ", npc.name));
        return;
    };
    if !Ninja_MaxXPHelper_ShowDeathAlerts {
        Ninja_MaxXPHelper_LogInfo(ConcatStrings("_Ninja_MaxXPHelper_DeathAlerts_DoDieCheckAlert skip - alerts off ", npc.name));
        return;
    };
    if Ninja_MaxXPHelper_HT_Has(_Ninja_MaxXPHelper_DeathAlerts_RemovedNPCs_HT, _@(npc)) {
        Ninja_MaxXPHelper_LogInfo(ConcatStrings("_Ninja_MaxXPHelper_DeathAlerts_DoDieCheckAlert skip - already handled ", npc.name));
        return;
    };
    if Npc_IsPlayer(npc) {
        Ninja_MaxXPHelper_LogInfo(ConcatStrings("_Ninja_MaxXPHelper_DeathAlerts_DoDieCheckAlert skip - player death ", npc.name));
        return;
    };
    if (
        !Ninja_MaxXPHelper_ConsiderLevelZeroNPC &&
        npc.level <= 0
    ) {
        Ninja_MaxXPHelper_LogInfo(ConcatStrings("_Ninja_MaxXPHelper_DeathAlerts_DoDieCheckAlert skip - level 0 ", npc.name));
        return;
    };
    if _Ninja_MaxXPHelper_DeathAlerts_Handler_SkipDeadOnArrivalNPC(npc) {
        Ninja_MaxXPHelper_LogInfo(ConcatStrings("_Ninja_MaxXPHelper_DeathAlerts_DoDieCheckAlert skip - skip DoA ", npc.name));
        return;
    };
    const int victoryXPReceived = 0; victoryXPReceived = Ninja_MaxXPHelper_VictoryXPReceived(npc);
    Ninja_MaxXPHelper_LogInfo(ConcatStrings("_Ninja_MaxXPHelper_DeathAlerts_DoDieCheckAlert victoryReceived ", IntToString(victoryXPReceived)));
    const int B_DeathXP__xpReceived = 0; B_DeathXP__xpReceived = Ninja_MaxXPHelper_HT_Has(_Ninja_MaxXPHelper_DeathAlerts_B_DeathXPHack_HT, _@(npc));
    Ninja_MaxXPHelper_LogInfo(ConcatStrings("_Ninja_MaxXPHelper_DeathAlerts_DoDieCheckAlert B_DeathXP__xpReceived ", IntToString(B_DeathXP__xpReceived)));
    const string violation = ""; violation = "";
    const int ignoreCause = FALSE; 
    // double XP handling
    if  GOTHIC_BASE_VERSION == 1 && 
        Ninja_MaxXPHelper_IsKnockable(hero, npc) && (
            (
            Ninja_MaxXPHelper_ConsiderG1DoubleXPGlitch && 
            (
                // defeated flag only set in ZS_Unconscious
                // B_DeathXP gives XP if victim wasn't ZS_Unconscious and is called only if player/party/summon kills.
                !victoryXPReceived || !B_DeathXP__xpReceived
            )
        ) || (
            Ninja_MaxXPHelper_WarnG1DoubleXPGlitch && 
            (
                // defeated flag only set in ZS_Unconscious
                // B_DeathXP gives XP if victim wasn't ZS_Unconscious and is called only if player/party/summon kills.
                victoryXPReceived && B_DeathXP__xpReceived
            )
        )
        )
         {
        if !victoryXPReceived {
            violation = Ninja_MaxXPHelper_LOC_DoubleXPNoZSUnconsciousXP;
            ignoreCause = TRUE;
        } else if !B_DeathXP__xpReceived {
            violation = Ninja_MaxXPHelper_LOC_DoubleXPMeleeFinisherTip;
            ignoreCause = FALSE;
        } else if Ninja_MaxXPHelper_WarnG1DoubleXPGlitch {
            violation = Ninja_MaxXPHelper_LOC_WarnDoubleXPViolation;
            ignoreCause = TRUE;
        };
    };
    
    if !(victoryXPReceived || B_DeathXP__xpReceived) {
        violation = Ninja_MaxXPHelper_LOC_LostVictoryXP;
        ignoreCause = FALSE;
    };
    if Ninja_MaxXPHelper_WarnSummonKill {
        if Ninja_MaxXPHelper_IsSummon(npc) && (victoryXPReceived || B_DeathXP__xpReceived) {
            violation = Ninja_MaxXPHelper_LOC_WarnKilledSummon;
            ignoreCause = TRUE;
        };
    };

    if STR_Compare(violation, "") != STR_Equal {
        const string alert = ""; alert = Ninja_MaxXPHelper_LOC_RIPPrefix;
        alert = ConcatStrings(alert, npc.name);
        alert = ConcatStrings(alert, " - ");
        alert = ConcatStrings(alert, violation);
        if !ignoreCause && STR_Compare(cause, "") != STR_Equal {
            alert = ConcatStrings(alert, " - ");
            alert = ConcatStrings(alert, cause);
        };
        _Ninja_MaxXPHelper_DeathAlerts_TriggerAlert(npc, alert);
    };
};


func void Ninja_MaxXPHelper_DeathAlerts_B_DeathXP() {
    Ninja_MaxXPHelper_LogInfo("Enter _Ninja_MaxXPHelper_DeathAlerts_B_DeathXP");
    Ninja_MaxXPHelper_LogInfo(ConcatStrings("B_DeathXP ", self.name));
    const int xp = 0; xp = hero.exp;
    ContinueCall();
    if xp != hero.exp {
        Ninja_MaxXPHelper_LogInfo(ConcatStrings("B_DeathXP - hero XP changed by ", IntToString(hero.exp - xp)));
        Ninja_MaxXPHelper_HT_InsertOrChange(_Ninja_MaxXPHelper_DeathAlerts_B_DeathXPHack_HT, _@(self), TRUE);
    };
};


func void Ninja_MaxXPHelper_B_KillNpc_Hook(var int npcInstance) {
    Ninja_MaxXPHelper_LogInfo("Enter _Ninja_MaxXPHelper_B_KillNpc_Hook");
    var c_npc victimNpc; victimNpc = Hlp_GetNpc(npcInstance);
    const int immortal = 0;
    const int alreadyDead = 0;
    const int valid = 0; valid = FALSE;
    if Hlp_IsValidNpc(victimNpc) {
        immortal = victimNpc.flags & NPC_FLAG_IMMORTAL;
        alreadyDead = _Ninja_MaxXPHelper_XPNPCLocator_IsNpcDead(victimNpc);
        valid = TRUE;
    };
    PassArgumentI(npcInstance);
    ContinueCall();
    if alreadyDead {
        Ninja_MaxXPHelper_LogInfo(ConcatStrings("Scripted death - skip - already dead ", victimNpc.name));
        return;
    };
    if !valid {
        Ninja_MaxXPHelper_LogInfo("_Ninja_MaxXPHelper_B_RemoveNpc_Hook Skip invalid npc ");
        return;
    };
    const int eventPtr = 0; eventPtr = create(_Ninja_MaxXPHelper_OnDeadEvent@);
    var _Ninja_MaxXPHelper_OnDeadEvent event; event = _^(eventPtr);
    event.victimPtr = _@(victimNpc);
    event.timeOfDeath = TimerGT();
    event.cause = "B_KillNpc";
    event.wasImmortal = immortal;
    Q_Enqueue(_Ninja_MaxXPHelper_DeathAlerts_DoDie_Queue, eventPtr);
};

func void _Ninja_MaxXPHelper_B_RemoveNpc_Hook(var int npcInstance) {
    Ninja_MaxXPHelper_LogInfo("Enter _Ninja_MaxXPHelper_B_RemoveNpc_Hook");
    var c_npc victimNpc; victimNpc = Hlp_GetNpc(npcInstance);
    Ninja_MaxXPHelper_LogInfo(ConcatStrings("_Ninja_MaxXPHelper_B_RemoveNpc_Hook ", victimNpc.name));
    const int immortal = 0; 
    const int alreadyDead = 0; 
    const int valid = 0; valid = FALSE;
    if Hlp_IsValidNpc(victimNpc) {
        immortal = victimNpc.flags & NPC_FLAG_IMMORTAL;
        alreadyDead = _Ninja_MaxXPHelper_XPNPCLocator_IsNpcDead(victimNpc);
        valid = TRUE;
    };
    if valid && !alreadyDead {
        // Has to be handled immediately.
        if !immortal {
            const int eventPtr = 0; eventPtr = create(_Ninja_MaxXPHelper_OnDeadEvent@);
            var _Ninja_MaxXPHelper_OnDeadEvent event; event = _^(eventPtr);
            event.victimPtr = _@(victimNpc);
            event.timeOfDeath = TimerGT();
            event.cause = "B_RemoveNpc";
            event.wasImmortal = immortal;
            _Ninja_MaxXPHelper_DeathAlerts_DoDieCheckAlert(victimNpc, event.cause);
        };
        Ninja_MaxXPHelper_HT_InsertOrChange(_Ninja_MaxXPHelper_DeathAlerts_RemovedNPCs_HT, _@(victimNpc), TimerGT());
        Ninja_MaxXPHelper_WarningAlerts_OnNPCDeath(victimNpc);
        Ninja_MaxXPHelper_ThiefScanner_OnNPCDeath(victimNpc);
    } else {
        Ninja_MaxXPHelper_LogInfo(
            "_Ninja_MaxXPHelper_B_RemoveNpc_Hook skip - NPC invalid or already dead"
        );
    };
    PassArgumentI(npcInstance);
    ContinueCall();
};

func void Ninja_MaxXPHelper_DeathAlerts_DoDie() {
    var c_npc victimNpc; victimNpc = _^(ECX);
    const int eventPtr = 0; eventPtr = create(_Ninja_MaxXPHelper_OnDeadEvent@);
    var _Ninja_MaxXPHelper_OnDeadEvent event; event = _^(eventPtr);
    event.victimPtr = _@(victimNpc);
    const int attackerPtr = 0; attackerPtr = MEM_ReadInt(ESP + 4);
    if attackerPtr {
        var c_npc attackerNpc; attackerNpc = _^(attackerPtr);
        if Hlp_IsValidNpc(attackerNpc) {
            if Ninja_MaxXPHelper_WouldReceiveVictoryXP(victimNpc, attackerNpc) {
                event.cause = Ninja_MaxXPHelper_LOC_XPNotRegisteredBug;
            } else {
                event.cause = ConcatStrings(Ninja_MaxXPHelper_LOC_KilledBy, attackerNpc.name);
            };   
        };
    };
    event.timeOfDeath = TimerGT();
    Q_Enqueue(_Ninja_MaxXPHelper_DeathAlerts_DoDie_Queue, eventPtr);
};

func void _Ninja_MaxXPHelper_DeathAlerts_RefreshLoop() {
    if !Ninja_MaxXPHelper_ShouldRunHook() { return; };
    const int gotoLabel = 0; gotoLabel = MEM_StackPos.position;
    if !Q_IsEmpty(_Ninja_MaxXPHelper_DeathAlerts_DoDie_Queue) {
        var _Ninja_MaxXPHelper_OnDeadEvent event; event = _^(Q_Peek(_Ninja_MaxXPHelper_DeathAlerts_DoDie_Queue));
        var c_npc cnpc; cnpc = _^(event.victimPtr);
        if TimerGT() - event.timeOfDeath > 1000 {
            Q_Advance(_Ninja_MaxXPHelper_DeathAlerts_DoDie_Queue);
            if !event.wasImmortal {
                _Ninja_MaxXPHelper_DeathAlerts_DoDieCheckAlert(cnpc, event.cause);
            };
            Ninja_MaxXPHelper_HT_InsertOrChange(_Ninja_MaxXPHelper_DeathAlerts_RemovedNPCs_HT, _@(cnpc), TimerGT());
            Ninja_MaxXPHelper_WarningAlerts_OnNPCDeath(cnpc);
            Ninja_MaxXPHelper_ThiefScanner_OnNPCDeath(cnpc);
            
            free(_@(event), _Ninja_MaxXPHelper_OnDeadEvent@);
            MEM_StackPos.position = gotoLabel; // loop next if present
        };
    };
};
func void _Ninja_MaxXPHelper_DeathAlerts_ReinitDoDieQueue() {
    if Hlp_IsValidHandle(_Ninja_MaxXPHelper_DeathAlerts_DoDie_Queue) {
        while (!Q_IsEmpty(_Ninja_MaxXPHelper_DeathAlerts_DoDie_Queue));
            const int ptr = 0; ptr = Q_Advance(_Ninja_MaxXPHelper_DeathAlerts_DoDie_Queue);
            free(ptr, _Ninja_MaxXPHelper_OnDeadEvent@);
        end;
    };
    if !Hlp_IsValidHandle(_Ninja_MaxXPHelper_DeathAlerts_DoDie_Queue) {
        _Ninja_MaxXPHelper_DeathAlerts_DoDie_Queue = Q_Create();
    };
};

const int Ninja_MaxXPHelper_DeathAlerts_Init_Once = 0;
func void Ninja_MaxXPHelper_DeathAlerts_Init() {
    _Ninja_MaxXPHelper_DeathAlerts_LastSVM = 0;
    Ninja_MaxXPHelper_HT_Destroy(_Ninja_MaxXPHelper_DeathAlerts_AlertIdToTrackerId_HT);
    Ninja_MaxXPHelper_HT_Destroy(_Ninja_MaxXPHelper_DeathAlerts_B_MagicHurtNpc_Killed_To_RealKiller_HT);
    Ninja_MaxXPHelper_HT_ClearAndCreate(_@(_Ninja_MaxXPHelper_DeathAlerts_RemovedNPCs_HT), 0);
    Ninja_MaxXPHelper_HT_ClearAndCreate(_@(_Ninja_MaxXPHelper_DeathAlerts_B_DeathXPHack_HT), 0);
    
    _Ninja_MaxXPHelper_DeathAlerts_AlertIdToTrackerId_HT = Ninja_MaxXPHelper_HT_Create();
    _Ninja_MaxXPHelper_DeathAlerts_B_MagicHurtNpc_Killed_To_RealKiller_HT = Ninja_MaxXPHelper_HT_Create();

    Ninja_MaxXPHelper_DeathAlerts_InitDeadOnArrivalNPCList();
    _Ninja_MaxXPHelper_DeathAlerts_ReinitDoDieQueue();
    if !Ninja_MaxXPHelper_DeathAlerts_Init_Once {
        if GOTHIC_BASE_VERSION == 1 {
            HookDaedalusFuncS("B_DeathXP", "Ninja_MaxXPHelper_DeathAlerts_B_DeathXP");
        } else if GOTHIC_BASE_VERSION == 2 {
            HookDaedalusFuncS("B_RemoveNpc", "_Ninja_MaxXPHelper_B_RemoveNpc_Hook");
        };
        HookDaedalusFuncS("B_KillNpc", "Ninja_MaxXPHelper_B_KillNpc_Hook");
        HookEngineF(
                 MEMINT_SwitchG1G2(6894752, 7563104),
                7,
                Ninja_MaxXPHelper_DeathAlerts_DoDie
        );

        Ninja_MaxXPHelper_DeathAlerts_Init_Once = 1;
    };
    FF_ApplyOnceGT(_Ninja_MaxXPHelper_DeathAlerts_RefreshLoop);
};