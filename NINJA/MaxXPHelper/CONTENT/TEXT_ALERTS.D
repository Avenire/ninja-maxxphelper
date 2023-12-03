const int _Ninja_MaxXPHelper_TextAlerts_WaitingQueue = 0;
const int _Ninja_MaxXPHelper_TextAlerts_ActiveQueue = 0;
const int _Ninja_MaxXPHelper_TextAlerts_ActiveCount = 0;
const int _Ninja_MaxXPHelper_TextAlerts_MaxActiveCount = 5;
const int _Ninja_MaxXPHelper_TextAlerts_Duration = 5000;

class _Ninja_MaxXPHelper_TextAlert {
    const int expiresAfter = 0;
    var string message;
    const int color = 0;
    const int onShowFnc = 0;
    const int next = 0;

    const int handle = 0;
};
instance _Ninja_MaxXPHelper_TextAlert@(_Ninja_MaxXPHelper_TextAlert) {
    expiresAfter = 0;
    message = "";
    color = 0;
    onShowFnc = 0;
    next = 0;
    handle = 0;
};


func void _Ninja_MaxXPHelper_TextAlert_Delete(var _Ninja_MaxXPHelper_TextAlert this) {
    delete(this.handle);
};

func int _Ninja_MaxXPHelper_TextAlerts_Enqueue(var int rootHandle, var int newAlertHandle) {
    if rootHandle > 0 {
        var _Ninja_MaxXPHelper_TextAlert rootNode;
        const int currHandle = 0; currHandle = rootHandle;
        while (currHandle > 0);
            rootNode = _^(currHandle);
            currHandle = rootNode.next;
        end;
        rootNode.next = newAlertHandle;
        return rootHandle;
    } else {
        return newAlertHandle;
    };
};

func void _Ninja_MaxXPHelper_TextAlerts_CallOnShowFunc(var int alertHandle) {
    locals();
    var _Ninja_MaxXPHelper_TextAlert a; a = _^(alertHandle);
    if a.onShowFnc {
        MEMINT_StackPushInt(alertHandle);
        MEM_CallByPtr(a.onShowFnc);
    };
};

const int _Ninja_MaxXPHelper_TextAlerts_Show_Heartbeat = 0;

func void _Ninja_MaxXPHelper_TextAlerts_Show() {
    const int heartbeat = FALSE; heartbeat = (TimerGT() - _Ninja_MaxXPHelper_TextAlerts_Show_Heartbeat) >= 10000;
    if heartbeat {
        const string msg = ""; msg = "Loop _Ninja_MaxXPHelper_TextAlerts_Show is running. activeCount=";
        msg = ConcatStrings(msg, inttostring(_Ninja_MaxXPHelper_TextAlerts_ActiveCount));
        msg = ConcatStrings(msg, " activeQueuePtr=");
        msg = ConcatStrings(msg, inttostring(_Ninja_MaxXPHelper_TextAlerts_ActiveQueue));
        msg = ConcatStrings(msg, " waitingQueuePtr=");
        msg = ConcatStrings(msg, inttostring(_Ninja_MaxXPHelper_TextAlerts_WaitingQueue));
        msg = ConcatStrings(msg, " maxActive=");
        msg = ConcatStrings(msg, inttostring(_Ninja_MaxXPHelper_TextAlerts_MaxActiveCount));
        if _Ninja_MaxXPHelper_TextAlerts_ActiveQueue {
            var _Ninja_MaxXPHelper_TextAlert alert; alert =  _^(alertHandle);
            msg = ConcatStrings(msg, " topActive=");
            msg = ConcatStrings(msg, alert.message);
            msg = ConcatStrings(msg, " top expires after=");
            msg = ConcatStrings(msg, IntToString(alert.expiresAfter));
            msg = ConcatStrings(msg, " TimerGT=");
            msg = ConcatStrings(msg, IntToString(TimerGT()));
        } else {
            msg = ConcatStrings(msg, " topActive=null");
        };
        Ninja_MaxXPHelper_LogInfo(msg);
        _Ninja_MaxXPHelper_TextAlerts_Show_Heartbeat = TimerGT();
    };
    if !Ninja_MaxXPHelper_ShouldRunHook() {
         return; 
    };
    while (_Ninja_MaxXPHelper_TextAlerts_ActiveQueue);
        const int alertHandle = 0; alertHandle = _Ninja_MaxXPHelper_TextAlerts_ActiveQueue;
        var _Ninja_MaxXPHelper_TextAlert alert; alert =  _^(alertHandle);
        if  alert.expiresAfter < TimerGT() {
            Ninja_MaxXPHelper_LogInfo(ConcatStrings("Expiring alert ", alert.message));
            _Ninja_MaxXPHelper_TextAlerts_ActiveCount -= 1;
            _Ninja_MaxXPHelper_TextAlerts_ActiveQueue = alert.next;
            free(alertHandle, _Ninja_MaxXPHelper_TextAlert@);
        } else {
            break;
        };
    end;
    while (
        _Ninja_MaxXPHelper_TextAlerts_WaitingQueue && 
        _Ninja_MaxXPHelper_TextAlerts_ActiveCount < _Ninja_MaxXPHelper_TextAlerts_MaxActiveCount
    );
        const int alertHandle = 0; alertHandle = _Ninja_MaxXPHelper_TextAlerts_WaitingQueue;
        var _Ninja_MaxXPHelper_TextAlert alert; alert = _^(alertHandle);
        Ninja_MaxXPHelper_LogInfo(ConcatStrings("Showing alert ", alert.message));
        _Ninja_MaxXPHelper_TextAlerts_ActiveCount += 1;
        _Ninja_MaxXPHelper_TextAlerts_CallOnShowFunc(alertHandle);
        alert.handle = Ninja_MaxXPHelper_PrintS_Ext(
            alert.message, 
            alert.expiresAfter,
            alert.color
        );
        alert.expiresAfter = TimerGT() + alert.expiresAfter;
        Ninja_MaxXPHelper_LogInfo(
            ConcatStrings("Alert expiry ", IntToString(alert.expiresAfter))
        );
        _Ninja_MaxXPHelper_TextAlerts_WaitingQueue = alert.next;
        Ninja_MaxXPHelper_LogInfo(
            ConcatStrings("Next alert ptr in queue ", 
            IntToString(_Ninja_MaxXPHelper_TextAlerts_WaitingQueue))
        );
        alert.next = 0;
        _Ninja_MaxXPHelper_TextAlerts_ActiveQueue = _Ninja_MaxXPHelper_TextAlerts_Enqueue(
            _Ninja_MaxXPHelper_TextAlerts_ActiveQueue,
            alertHandle
        );
    end;
};

func void Ninja_MaxXPHelper_TextAlerts_Init() {
    var _Ninja_MaxXPHelper_TextAlert alert; 

    while (_Ninja_MaxXPHelper_TextAlerts_ActiveQueue);
        alert = _^(_Ninja_MaxXPHelper_TextAlerts_ActiveQueue);
        _Ninja_MaxXPHelper_TextAlerts_ActiveQueue = alert.next;
        free(_@(alert), _Ninja_MaxXPHelper_TextAlert@);
    end;
    
    while (_Ninja_MaxXPHelper_TextAlerts_WaitingQueue);
        alert = _^(_Ninja_MaxXPHelper_TextAlerts_WaitingQueue);
        free(_@(alert), _Ninja_MaxXPHelper_TextAlert@);
        _Ninja_MaxXPHelper_TextAlerts_WaitingQueue = alert.next;
    end;
    Ninja_MaxXPHelper_PrintS_ClearAll();
    _Ninja_MaxXPHelper_TextAlerts_ActiveQueue = 0;
    _Ninja_MaxXPHelper_TextAlerts_WaitingQueue = 0;
    _Ninja_MaxXPHelper_TextAlerts_ActiveCount = 0;
    _Ninja_MaxXPHelper_TextAlerts_Show_Heartbeat = TimerGT();
    FF_ApplyOnceGT(_Ninja_MaxXPHelper_TextAlerts_Show);  
};

func int Ninja_MaxXPHelper_TextAlerts_Create(var string msg, var int duration, var int color, var int instant) {
    const int alertHandle = 0; alertHandle = create(_Ninja_MaxXPHelper_TextAlert@);
    var _Ninja_MaxXPHelper_TextAlert newAlert; newAlert =  _^(alertHandle);
    newAlert.message = msg;
    newAlert.expiresAfter = duration;
    newAlert.color = color;
    newAlert.next = 0;
    if instant {
        _Ninja_MaxXPHelper_TextAlerts_ActiveCount += 1;
        newAlert.handle = Ninja_MaxXPHelper_PrintS_Ext(
            newAlert.message, 
            newAlert.expiresAfter,
            newAlert.color
        );
        newAlert.expiresAfter = duration + TimerGT();
        _Ninja_MaxXPHelper_TextAlerts_ActiveQueue = _Ninja_MaxXPHelper_TextAlerts_Enqueue(
            _Ninja_MaxXPHelper_TextAlerts_ActiveQueue,
            alertHandle
        );
    } else {
        _Ninja_MaxXPHelper_TextAlerts_WaitingQueue = _Ninja_MaxXPHelper_TextAlerts_Enqueue(
            _Ninja_MaxXPHelper_TextAlerts_WaitingQueue,
            alertHandle
        );
    };
    return alertHandle;
};

func void Ninja_MaxXPHelper_TextAlerts_SetOnShowFunc(var int textAlertHandle, var func onShowFnc) {
    if textAlertHandle > 0 {
        var _Ninja_MaxXPHelper_TextAlert ta; ta = _^(textAlertHandle);
        ta.onShowFnc = MEM_GetFuncPtr(onShowFnc);
    };
};