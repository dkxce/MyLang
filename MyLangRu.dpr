library MyLangRu;

uses Windows;

const
  WM_USER     = $0400;
  WM_INPUTLANGCHANGEREQUEST = $0050;

  {USER DEFINED}
  MM_USER_KEY = wm_User + 150;

var
  HookHandle: hHook = 0;
  SaveExitProc: Pointer;
  C_btn: boolean = true;
  A_btn: boolean = false;

procedure EmulateGlobalKey(Wnd: HWND; VKey: Integer);
asm
   push 0
   push edx
   push 0101H //WM_KEYUP
   push eax
   push 0
   push edx
   push 0100H //WM_KEYDOWN
   push eax
   call PostMessage
   call PostMessage
end;

procedure SimulateKeyDown(Key: byte);
begin
  keybd_event(Key, 0, 0, 0);
end;

procedure SimulateKeyUp(Key: byte);
begin
  keybd_event(Key, 0, KEYEVENTF_KEYUP, 0);
end;

function GetBtnState(Btn: word): Boolean;
var
  State : TKeyboardState;
begin
  GetKeyboardState(State);
  Result := ((State[btn] and 128) = 128);
end;

procedure ChangeLayOut(Shift,Ctrl,Alt: boolean);
begin
  if ((Shift) and (Ctrl) and (c_Btn)) then SendMessage(GetForegroundWindow,WM_INPUTLANGCHANGEREQUEST,0,0);
  if ((Shift) and (Alt) and (A_Btn)) then SendMessage(GetForegroundWindow,WM_INPUTLANGCHANGEREQUEST,0,0);
end;

// Byte(x)        - Shift
// Byte(x) shr 8  - Ctrl
// Byte(x) shr 16 - Alt
function Key_Hook(Code: integer; wParam: word; lParam: Longint): Longint; stdcall; export;
var hndl: THandle;
begin
  result:=0;
  {если Code>=0, то ловушка может обработать событие}
  if (Code >= 0) then
  begin
    hndl := FindWindow('TMyLangRuForm',nil);
	  ChangeLayOut(GetBtnState(VK_SHIFT),GetBtnState(VK_CONTROL),GetBtnState(VK_MENU));
    SendMessage(hndl, MM_USER_KEY, wParam, ( byte(GetBtnState(VK_MENU)) shl 16 or byte(GetBtnState(VK_CONTROL)) shl 8 or byte(GetBtnState(VK_SHIFT)) ) );
    {если 0, то система должна дальше обработать это событие} {если 1 - нет}
    Result := 0;
  end else begin
    if Code < 0 {если Code<0, то нужно вызвать следующую ловушку} then Result := CallNextHookEx(HookHandle, Code, wParam, lParam);
  end;
end;

procedure ExitHook;
begin
  UnhookWindowsHookEx(HookHandle);
end;

procedure LocalExitProc; far;
begin
  UnhookWindowsHookEx(HookHandle);
  ExitProc := SaveExitProc;
end;


procedure SetHook(Ctrl_Btn: boolean = true; Alt_Btn: boolean = false);
begin
  C_Btn := Ctrl_Btn;
  A_Btn := Alt_Btn;

  HookHandle := SetWindowsHookEx(WH_KEYBOARD, @Key_Hook, hInstance, 0);
  if HookHandle = 0 then MessageBox(0, 'Неудается запустить программу MyLangRu!', 'Error', mb_Ok);

  SaveExitProc := ExitProc;
  ExitProc := @LocalExitProc;
end;

exports SetHook,ExitHook;

begin

end.
