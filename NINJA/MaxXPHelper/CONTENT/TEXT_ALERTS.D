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

func void _Ninja_MaxXPHelper_TextAlert_Delete(var _Ninja_MaxXPHelper_TextAlert this) {
    Ninja_MaxXPHelper_LogInfo(ConcatStrings("Alert dtor called ", this.message));
};


func void _Ninja_MaxXPHelper_TextAlerts_Clear(var int rootPtr) {
    var int root; root = MEM_ReadInt(rootPtr);
    if !root { return; };
    var _Ninja_MaxXPHelper_TextAlert rootNode; rootNode = _^(root);
    MEM_WriteInt(rootPtr, 0);
    while (root);
        var _Ninja_MaxXPHelper_TextAlert curr; curr = _^(root);
        free(root, _Ninja_MaxXPHelper_TextAlert@);
        root = curr.next;
    end;
};

func void _Ninja_MaxXPHelper_TextAlerts_Enqueue(var int rootPtr, var int newAlertPtr) {
    var int root; root = MEM_ReadInt(rootPtr);
    if root {
        var _Ninja_MaxXPHelper_TextAlert rootNode; rootNode = _^(root);
        while (rootNode.next);
            rootNode = _^(rootNode.next);
        end;
        rootNode.next = newAlertPtr;
    } else {
        MEM_WriteInt(rootPtr, newAlertPtr);
    };
};

func void _Ninja_MaxXPHelper_CallOnShowFunc(var int alertHandle) {
    locals();
    var _Ninja_MaxXPHelper_TextAlert a; a = _^(alertHandle);
    if a.onShowFnc {
        MEMINT_StackPushInt(alertHandle);
        MEM_CallByPtr(a.onShowFnc);
    };
};

func void _Ninja_MaxXPHelper_TextAlerts_Show() {
    if Timer_IsPaused() { return; };
    while (_Ninja_MaxXPHelper_TextAlerts_ActiveQueue);
        var int alertPtr; alertPtr = _Ninja_MaxXPHelper_TextAlerts_ActiveQueue;
        var _Ninja_MaxXPHelper_TextAlert alert; alert =  _^(alertPtr);
        if  alert.expiresAfter < TimerGT() {
            _Ninja_MaxXPHelper_TextAlerts_ActiveCount -= 1;
            _Ninja_MaxXPHelper_TextAlerts_ActiveQueue = alert.next;
            free(alertPtr, _Ninja_MaxXPHelper_TextAlert@);
        } else {
            break;
        };
    end;
    while (_Ninja_MaxXPHelper_TextAlerts_WaitingQueue && _Ninja_MaxXPHelper_TextAlerts_ActiveCount < _Ninja_MaxXPHelper_TextAlerts_MaxActiveCount);
        var int alertPtr; alertPtr = _Ninja_MaxXPHelper_TextAlerts_WaitingQueue;
        var _Ninja_MaxXPHelper_TextAlert alert; alert = _^(alertPtr);
        _Ninja_MaxXPHelper_TextAlerts_WaitingQueue = alert.next;
        _Ninja_MaxXPHelper_TextAlerts_ActiveCount += 1;
        _Ninja_MaxXPHelper_CallOnShowFunc(alertPtr);
        Ninja_MaxXPHelper_PrintS_Ext(
            alert.message, 
            alert.expiresAfter,
            alert.color
        );
        alert.expiresAfter = TimerGT() + alert.expiresAfter;
        _Ninja_MaxXPHelper_TextAlerts_Enqueue(
            _@(_Ninja_MaxXPHelper_TextAlerts_ActiveQueue),
            alertPtr
        );
    end;
};

func void Ninja_MaxXPHelper_TextAlerts_Init() {
    _Ninja_MaxXPHelper_TextAlerts_ActiveCount = 0;
    // Not using Lego Queues because getting mysterious crashes and I can't get my head around
    // how is memory is supposed to be correctly managed with them.
    _Ninja_MaxXPHelper_TextAlerts_Clear(_@(_Ninja_MaxXPHelper_TextAlerts_WaitingQueue));
    _Ninja_MaxXPHelper_TextAlerts_Clear(_@(_Ninja_MaxXPHelper_TextAlerts_ActiveQueue));
    FF_ApplyOnceGT(_Ninja_MaxXPHelper_TextAlerts_Show);  
};

func int Ninja_MaxXPHelper_AddTextAlert(var string msg, var int duration, var int color, var int instant) {
    var int alertPtr; alertPtr = create(_Ninja_MaxXPHelper_TextAlert@);
    var _Ninja_MaxXPHelper_TextAlert newAlert; newAlert =  _^(alertPtr);
    newAlert.message = msg;
    newAlert.expiresAfter = duration;
    newAlert.color = color;
    if instant {
        _Ninja_MaxXPHelper_TextAlerts_ActiveCount += 1;
        Ninja_MaxXPHelper_PrintS_Ext(
            newAlert.message, 
            newAlert.expiresAfter,
            newAlert.color
        );
        newAlert.expiresAfter = duration + TimerGT();
        _Ninja_MaxXPHelper_TextAlerts_Enqueue(
            _@(_Ninja_MaxXPHelper_TextAlerts_ActiveQueue),
            alertPtr
        );
    } else {
        _Ninja_MaxXPHelper_TextAlerts_Enqueue(
            _@(_Ninja_MaxXPHelper_TextAlerts_WaitingQueue),
            alertPtr
        );
    };
    return alertPtr;
};

func void Ninja_MaxXPHelper_SetOnShowFunc(var int textAlertHandle, var func onShowFnc) {
    var _Ninja_MaxXPHelper_TextAlert ta; ta = _^(textAlertHandle); // SIC
    ta.onShowFnc = MEM_GetFuncPtr(onShowFnc);
};