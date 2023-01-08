program UMake;

uses
  Vcl.Forms,
  Vcl.Controls,
  WinApi.Windows,
  UMake_Configuration in 'src\UMake_Configuration.pas',
  UMake_Options in 'src\UMake_Options.pas',
  UMake_FormLaunch in 'src\forms\UMake_FormLaunch.pas' {FormLaunch},
  UMake_FormMain in 'src\forms\UMake_FormMain.pas' {FormMain},
  UMake_FormOptions in 'src\forms\UMake_FormOptions.pas' {FormOptions},
  UMake_FormShortcuts in 'src\forms\UMake_FormShortcuts.pas' {FormShortcuts};

{$R *.RES}
{$R CursorHand.res}

begin
  {$IF Defined(DEBUG)}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}

  Screen.Cursors[crHandPoint] := LoadCursor(HInstance, 'HANDCURSOR');
  Application.Initialize;
  Application.Title := 'UMake';
  Application.CreateForm(TFormLaunch, FormLaunch);
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TFormOptions, FormOptions);
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TFormOptions, FormOptions);
  Application.CreateForm(TFormShortcuts, FormShortcuts);
  Application.ShowMainForm := False;
  FormMain.Startup;
  Application.Run;
end.
