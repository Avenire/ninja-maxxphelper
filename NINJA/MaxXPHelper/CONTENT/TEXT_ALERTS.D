const int _Ninja_MaxXPHelper_TextAlerts_WaitingQueue = 0;
const int _Ninja_MaxXPHelper_TextAlerts_ActiveQueue = 0;
const int _Ninja_MaxXPHelper_TextAlerts_ActiveCount = 0;
const int _Ninja_MaxXPHelper_TextAlerts_MaxActiveCount = 5;
const int _Ninja_MaxXPHelper_TextAlerts_Color = 16724530;
const int _Ninja_MaxXPHelper_TextAlerts_Duration = 5000;

class _Ninja_MaxXPHelper_TextAlert {
    var int expiresAfter;
    var string message;
    var int color;
    var int onShowFnc;
    var int next;
};
instance _Ninja_MaxXPHelper_TextAlert@(_Ninja_MaxXPHelper_TextAlert) {
    expiresAfter = 0;
    message = "";
    color = 0;
    onShowFnc = 0;
    next = 0;
};

func int _Ninja_MaxXPHelper_TextAlerts_Enqueue(var int rootPtr, var int newAlertPtr) {
    if Hlp_IsValidHandle(rootPtr) {
        var _Ninja_MaxXPHelper_TextAlert rootNode;
        var int currPtr; currPtr = rootPtr;
        while (Hlp_IsValidHandle(currPtr));
            rootNode = get(currPtr);
            currPtr = rootNode.next;
        end;
        rootNode.next = newAlertPtr;
        return rootPtr;
    } else {
        return newAlertPtr;
    };
};

func void _Ninja_MaxXPHelper_CallOnShowFunc(var int alertHandle) {
    locals();
    var _Ninja_MaxXPHelper_TextAlert a; a = get(alertHandle);
    if a.onShowFnc {
        MEMINT_StackPushInt(alertHandle);
        MEM_CallByPtr(a.onShowFnc);
    };
};

func void _Ninja_MaxXPHelper_TextAlerts_Show() {
    if Timer_IsPaused() { return; };
    while (Hlp_IsValidHandle(_Ninja_MaxXPHelper_TextAlerts_ActiveQueue));
        var int alertPtr; alertPtr = _Ninja_MaxXPHelper_TextAlerts_ActiveQueue;
        var _Ninja_MaxXPHelper_TextAlert alert; alert =  get(alertPtr);
        if  alert.expiresAfter < TimerGT() {
            _Ninja_MaxXPHelper_TextAlerts_ActiveCount -= 1;
            _Ninja_MaxXPHelper_TextAlerts_ActiveQueue = alert.next;
            delete(alertPtr);
        } else {
            break;
        };
    end;
    while (
        Hlp_IsValidHandle(_Ninja_MaxXPHelper_TextAlerts_WaitingQueue) && 
        _Ninja_MaxXPHelper_TextAlerts_ActiveCount < _Ninja_MaxXPHelper_TextAlerts_MaxActiveCount
    );
        
        var int alertPtr; alertPtr = _Ninja_MaxXPHelper_TextAlerts_WaitingQueue;
        var _Ninja_MaxXPHelper_TextAlert alert; alert = get(alertPtr);
        _Ninja_MaxXPHelper_TextAlerts_ActiveCount += 1;
        _Ninja_MaxXPHelper_CallOnShowFunc(alertPtr);
        Ninja_MaxXPHelper_PrintS_Ext(
            alert.message, 
            alert.expiresAfter,
            alert.color
        );
        alert.expiresAfter = TimerGT() + alert.expiresAfter;
        _Ninja_MaxXPHelper_TextAlerts_WaitingQueue = alert.next;
        alert.next = 0;
        _Ninja_MaxXPHelper_TextAlerts_ActiveQueue = _Ninja_MaxXPHelper_TextAlerts_Enqueue(
            _Ninja_MaxXPHelper_TextAlerts_ActiveQueue,
            alertPtr
        );
    end;
};

func void Ninja_MaxXPHelper_TextAlerts_Init() {
    _Ninja_MaxXPHelper_TextAlerts_ActiveCount = 0;
    // Not using Lego Queues because getting mysterious crashes and I can't get my head around
    // how is memory is supposed to be correctly managed with them.
    _Ninja_MaxXPHelper_TextAlerts_WaitingQueue = 0;
    _Ninja_MaxXPHelper_TextAlerts_ActiveQueue = 0;
    FF_ApplyOnceGT(_Ninja_MaxXPHelper_TextAlerts_Show);  
};

func int Ninja_MaxXPHelper_AddTextAlert(var string msg, var int duration, var int color, var int instant) {
    var int alertPtr; alertPtr = new(_Ninja_MaxXPHelper_TextAlert@);
    var _Ninja_MaxXPHelper_TextAlert newAlert; newAlert =  get(alertPtr);
    newAlert.message = msg;
    newAlert.expiresAfter = duration;
    newAlert.color = color;
    newAlert.next = 0;
    if instant {
        _Ninja_MaxXPHelper_TextAlerts_ActiveCount += 1;
        Ninja_MaxXPHelper_PrintS_Ext(
            newAlert.message, 
            newAlert.expiresAfter,
            newAlert.color
        );
        newAlert.expiresAfter = duration + TimerGT();
        _Ninja_MaxXPHelper_TextAlerts_ActiveQueue = _Ninja_MaxXPHelper_TextAlerts_Enqueue(
            _Ninja_MaxXPHelper_TextAlerts_ActiveQueue,
            alertPtr
        );
    } else {
        _Ninja_MaxXPHelper_TextAlerts_WaitingQueue = _Ninja_MaxXPHelper_TextAlerts_Enqueue(
            _Ninja_MaxXPHelper_TextAlerts_WaitingQueue,
            alertPtr
        );
    };
    return alertPtr;
};

func void Ninja_MaxXPHelper_SetOnShowFunc(var int textAlertHandle, var func onShowFnc) {
    if Hlp_IsValidHandle(textAlertHandle) {
        var _Ninja_MaxXPHelper_TextAlert ta; ta = get(textAlertHandle);
        ta.onShowFnc = MEM_GetFuncPtr(onShowFnc);
    };
};