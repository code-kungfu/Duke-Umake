program UMake;

uses
  Vcl.Forms,
  Vcl.Controls,
  WinApi.Windows,
  UMake.Configuration in 'src\UMake.Configuration.pas',
  UMake.Options in 'src\UMake.Options.pas',
  UMake.Forms.Launcher in 'src\forms\UMake.Forms.Launcher.pas' {frmLauncher},
  UMake.Forms.Main in 'src\forms\UMake.Forms.Main.pas' {frmMainForm},
  UMake.Forms.Options in 'src\forms\UMake.Forms.Options.pas' {frmOptions},
  UMake.Forms.Shortcuts in 'src\forms\UMake.Forms.Shortcuts.pas' {frmShortcuts},
  Vcl.Themes,
  Vcl.Styles;

{$R *.RES}
{$R CursorHand.res}

begin
  {$IF Defined(DEBUG)}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}

  Screen.Cursors[crHandPoint] := LoadCursor(HInstance, 'HANDCURSOR');
  Application.Initialize;
  TStyleManager.TrySetStyle('Windows10 SlateGray');
  Application.Title := 'UMake for Duke Nukem Forever 2001';
  Application.CreateForm(TfrmMainForm, frmMainForm);
  Application.CreateForm(TfrmLauncher, frmLauncher);
  Application.CreateForm(TfrmOptions, frmOptions);
  Application.CreateForm(TfrmShortcuts, frmShortcuts);
  Application.ShowMainForm := False;
  frmMainForm.Startup;
  Application.Run;
end.
