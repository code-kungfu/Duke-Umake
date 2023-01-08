﻿program UMake;

uses
  Vcl.Forms,
  Vcl.Controls,
  WinApi.Windows,
  UMake.Configuration in 'src\UMake.Configuration.pas',
  UMake.Options in 'src\UMake.Options.pas',
  UMake.Forms.Launcher in 'src\forms\UMake.Forms.Launcher.pas' {frmLauncher},
  UMake.Forms.Main in 'src\forms\UMake.Forms.Main.pas' {frmMainForm},
  UMake.Forms.Options in 'src\forms\UMake.Forms.Options.pas' {frmOptions},
  UMake.Forms.Shortcuts in 'src\forms\UMake.Forms.Shortcuts.pas' {frmShotcuts};

R *.RES}
{$R CursorHand.res}

begin
  {$IF Defined(DEBUG)}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}

  Screen.Cursors[crHandPoint] := LoadCursor(HInstance, 'HANDCURSOR');
  Application.Initialize;
  Application.Title := 'UMake';
  Application.CreateForm(TfrmLauncher, frmLauncher);
  Application.CreateForm(TfrmMainForm, frmMainForm);
  Application.CreateForm(TfrmOptions, frmOptions);
  Application.CreateForm(TfrmMainForm, frmMainForm);
  Application.CreateForm(TfrmShotcuts, frmShotcuts);
  Application.ShowMainForm := False;
  frmMainForm.Startup;
  Application.Run;
end.
