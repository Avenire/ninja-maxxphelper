class _Ninja_MaxXPHelper_FileStream {
    const int bufferPtr = 0;
    const int cursor = 0;
    const int size = 0;
};
instance _Ninja_MaxXPHelper_FileStream@(_Ninja_MaxXPHelper_FileStream) {};

func void _Ninja_MaxXPHelper_FileStream_Delete(var _Ninja_MaxXPHelper_FileStream this) {
    if this.bufferPtr {
        MEM_Free(this.bufferPtr);
        this.cursor = -1;
        this.size = -1;
    };
};

func int Ninja_MaxXPHelper_OpenFileStreamForReading(var string filename) {
    const int fileHandle = 0; fileHandle = WIN_CreateFile(
        filename, 
        GENERIC_READ, FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE, 
        0, 
        OPEN_EXISTING, 
        FILE_ATTRIBUTE_NORMAL, 
        0
    );
    const int streamPtr = 0; streamPtr = create(_Ninja_MaxXPHelper_FileStream@);
    if streamPtr == 0 { return 0; };
    var _Ninja_MaxXPHelper_FileStream stream; stream = _^(streamPtr);
    stream.size = WIN_GetFileSize(fileHandle, 0);
    stream.bufferPtr = MEM_Alloc(stream.size);
    const int ptr = 0; ptr = MEM_Alloc(4);
    WIN_ReadFile(fileHandle, stream.bufferPtr, stream.size, ptr, 0);
    MEM_Free(ptr);
    WIN_CloseHandle(fileHandle);
    return streamPtr;
};

func int _Ninja_MaxXPHelper_ReadUpTo2Bytes(var _Ninja_MaxXPHelper_FileStream stream) {
    
    if stream.cursor >= stream.size {
        return 0;
    };
    const int length = 0; length = 2;
    if stream.cursor + length >= stream.size {
        length = stream.size - stream.cursor;
    };
    if length == 0 { return 0; };
    const int b = 0; b = MEM_ReadInt(stream.bufferPtr + stream.cursor);
    if(length < 4) {
        b = b&((256<<((length-1)<<3))-1);
    };
    stream.cursor += length;
    return b;
};

func string _Ninja_MaxXPHelper_ReadAsString(var _Ninja_MaxXPHelper_FileStream stream, var int len) {
    var string str; str = "";
    var zString zstr; zstr = MEM_PtrToInst(_@s(str));
    zstr.ptr = MEM_Alloc(len+2)+1;
    MEM_CopyBytes(stream.bufferPtr + stream.cursor, zstr.ptr, len);
    zstr.len = len;
    zstr.res = len;
    return str;
};

const int _Ninja_MaxXPHelper_CRLF = 2573;
const int _Ninja_MaxXPHelper_CR = 13;
const int _Ninja_MaxXPHelper_1111Mask = 15;
func int Ninja_MaxXPHelper_EOF(var int streamPtr) {
    var _Ninja_MaxXPHelper_FileStream stream; stream = _^(streamPtr);
    return stream.cursor >= stream.size;
};
func string Ninja_MaxXPHelper_TextLine(var int streamPtr) {
    var _Ninja_MaxXPHelper_FileStream stream; stream = _^(streamPtr);
    const int start = 0; start = stream.cursor;
    const int gotoLabel = 0; gotoLabel = MEM_StackPos.position;
    const int b2 = 0; b2 = _Ninja_MaxXPHelper_ReadUpTo2Bytes(stream);
    if(b2 != 0) {
        if _Ninja_MaxXPHelper_CRLF == b2 {
            b2 = 2;
        } else {
            // Check if CR is the last byte
            if ((b2 >> 8) & _Ninja_MaxXPHelper_1111Mask) == _Ninja_MaxXPHelper_CR {
                stream.cursor -= 1; // Next will read CR as first and LF should follow
            };
            MEM_StackPos.position = gotoLabel; // continue looping
        };
    };
    const int end = 0; end = stream.cursor;
    stream.cursor = start;
    var string str; str = _Ninja_MaxXPHelper_ReadAsString(stream, end - start - b2);
    stream.cursor = end;
    return str;
};

func void Ninja_MaxXPHelper_CloseFileStream(var int streamPtr) {
    free(streamPtr, _Ninja_MaxXPHelper_FileStream@);
};