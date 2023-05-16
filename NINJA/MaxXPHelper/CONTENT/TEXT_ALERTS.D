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
};
instance _Ninja_MaxXPHelper_TextAlert_Proto(_Ninja_MaxXPHelper_TextAlert) {
    expiresAfter = 0;
    message = "";
    color = 0;
};


func void _Ninja_MaxXPHelper_TextAlerts_Show() {
    while (!Q_IsEmpty(_Ninja_MaxXPHelper_TextAlerts_ActiveQueue));
        var int handle; handle = Q_Peek(_Ninja_MaxXPHelper_TextAlerts_ActiveQueue);
        var _Ninja_MaxXPHelper_TextAlert alert; alert =  _^(getPtr(handle));
        if  alert.expiresAfter < TimerGT() {
            _Ninja_MaxXPHelper_TextAlerts_ActiveCount -= 1;
            delete(Q_Advance(_Ninja_MaxXPHelper_TextAlerts_ActiveQueue));
        } else {
            break;
        };
    end;
    while (!Q_IsEmpty(_Ninja_MaxXPHelper_TextAlerts_WaitingQueue) && _Ninja_MaxXPHelper_TextAlerts_ActiveCount < _Ninja_MaxXPHelper_TextAlerts_MaxActiveCount);
        var int handle; handle = Q_Advance(_Ninja_MaxXPHelper_TextAlerts_WaitingQueue);
        var _Ninja_MaxXPHelper_TextAlert alert; alert =  _^(getPtr(handle));
        _Ninja_MaxXPHelper_TextAlerts_ActiveCount += 1;
        Ninja_MaxXPHelper_PrintS_Ext(
            alert.message, 
            alert.expiresAfter,
            alert.color
        );
        alert.expiresAfter = TimerGT() + alert.expiresAfter;
        Q_Enqueue(_Ninja_MaxXPHelper_TextAlerts_ActiveQueue, handle);
    end;
};

func void Ninja_MaxXPHelper_TextAlerts_Init() {
    _Ninja_MaxXPHelper_TextAlerts_ActiveCount = 0;
    _Ninja_MaxXPHelper_TextAlerts_WaitingQueue = Q_Create();
    _Ninja_MaxXPHelper_TextAlerts_ActiveQueue = Q_Create();
    FF_ApplyExtGT(_Ninja_MaxXPHelper_TextAlerts_Show, 500, -1);
};


func void Ninja_MaxXPHelper_AddTextAlert(var string msg, var int duration, var int color) {
    var int newAlertHndl; newAlertHndl = new(_Ninja_MaxXPHelper_TextAlert_Proto);
    var _Ninja_MaxXPHelper_TextAlert newAlert; newAlert =  _^(getPtr(newAlertHndl));
    newAlert.message = msg;
    newAlert.expiresAfter = duration;
    newAlert.color = color;
    Q_Enqueue(_Ninja_MaxXPHelper_TextAlerts_WaitingQueue, newAlertHndl);
};