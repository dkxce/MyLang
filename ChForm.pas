unit ChForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, RzTray, ImgList, Menus, ExtCtrls;

const
  MM_USER_KEY  = wm_User + 150;

type
  TMyLangRuForm = class(TForm)
    TrayIcon1: TRzTrayIcon;
    ImageList1: TImageList;
    close1: TMenuItem;
    Timer1: TTimer;
    suiPopupMenu1: TPopupMenu;
    N1: TMenuItem;
    Rus1: TMenuItem;
    Eng1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure close1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TrayIcon1LButtonDblClick(Sender: TObject);
    procedure Rus1Click(Sender: TObject);
    procedure Eng1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure suiPopupMenu1Popup(Sender: TObject);
  private
    procedure On_USER_KEY(var M: TMessage); message MM_USER_KEY;
  public
    { Public declarations }
  end;

  TSetHook = procedure(Ctrl_Btn: boolean = true; Alt_Btn: boolean = false);

var
  MyLangRuForm: TMyLangRuForm;
  LibHandle: THandle;

implementation

{$R *.dfm}

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

procedure TMyLangRuForm.On_USER_KEY(var M: TMessage);
begin
  //
end;


procedure TMyLangRuForm.FormCreate(Sender: TObject);
var SetHook: TSetHook;
begin
  LibHandle := LoadLibrary('MyLangRu.dll');
  if LibHandle = 0 then raise Exception.Create('Не удается загрузить библиотеку...')
  else
    try
      @SetHook := GetProcAddress(LibHandle, 'SetHook');
     if @SetHook <> nil then SetHook(true,true);
    except
      on E: Exception do ShowMessage('Exception error: ' + E.Message);
    end;
end;

procedure TMyLangRuForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
var ExitHook: procedure;
begin
  try
    @ExitHook := GetProcAddress(LibHandle, 'ExitHook');
    if @ExitHook <> nil then ExitHook;
  except end;
  FreeLibrary(LibHandle);
  TrayIcon1.Enabled:=False;
end;

procedure TMyLangRuForm.close1Click(Sender: TObject);
begin
  Close;
end;

procedure TMyLangRuForm.Timer1Timer(Sender: TObject);
const ENG = 67699721;
      RUS = 68748313;
var PrevLA: integer;
begin
    PrevLA := GetKeyboardLayout(GetWindowThreadProcessId(GetForegroundWindow, nil));
    if PrevLA = ENG then TrayIcon1.IconIndex:=0;
    if PrevLA = RUS then TrayIcon1.IconIndex:=1;
end;

procedure TMyLangRuForm.TrayIcon1LButtonDblClick(Sender: TObject);
begin
  TrayIcon1.ShowBalloonHint('MyLangRu','(C) https://github.com/dkxce '#10#13' 2005 - 2022');
end;

procedure TMyLangRuForm.Rus1Click(Sender: TObject);
begin
   LoadKeyboardLayout('00000419', KLF_ACTIVATE);
end;

procedure TMyLangRuForm.Eng1Click(Sender: TObject);
begin
   LoadKeyboardLayout('00000409', KLF_ACTIVATE);
end;

procedure TMyLangRuForm.N2Click(Sender: TObject);
var
  hk:HKL;
begin
  hk := LoadKeyboardLayout(0, 0);
  ActivateKeyboardLayout(hk, 0);
end;

procedure TMyLangRuForm.suiPopupMenu1Popup(Sender: TObject);
var
  S : String;
begin
  SetLength(S, KL_NAMELENGTH);
  if GetKeyboardLayoutName(PChar(S)) then
    N4.Caption := 'Текущая: ' + S
  else
    N4.Caption := 'Текущая: ?';
end;

end.
