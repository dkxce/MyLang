program MyLang;

uses
  Forms,
  ChForm in 'ChForm.pas' {MyLangRuForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMyLangRuForm, MyLangRuForm);
  Application.ShowMainForm:=False;
  Application.Run;
end.
