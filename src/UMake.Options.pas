unit UMake.Options;

interface

{$REGION '-> Global Uses Clause <-'}
uses
  { VCL }
  Vcl.Forms,
  Vcl.FileCtrl,

  { UMake Libraries }
  UMake.Configuration,

  { Misc Libraries }
  RegOpts;
{$ENDREGION}

(*****************************************************************************)
(*  TOptions
(*****************************************************************************)

type
  TOptionsPerformIndex = (perfSuccess, perfFailure);
  TOptionsPerformWindow = (perfWindowNone, perfWindowFront, perfWindowClose);

  TOptionsPerform = record
  public
    RegOptWindow: TRegOptInteger;
    RegOptLaunch: TRegOptString;
    RegOptSound: TRegOptString;
  end;

  TOptions = class
  public
    RegOptDetails: TRegOptBoolean;
    RegOptEditor: TRegOptString;
    RegOptProjects: TRegOptString;
    Perform: array [TOptionsPerformIndex] of TOptionsPerform;
    constructor Create;
    destructor Destroy; override;
    procedure PerformAction(IndexPerform: TOptionsPerformIndex; Form: TCustomForm; Configuration: TConfiguration);
    procedure PerformEdit(Configuration: TConfiguration; TextFileError: string; IndexLineError: Integer);
  end;

implementation

{$REGION '-> Local Uses Clause <-'}
uses
  { RTL }
  System.SysUtils,
  System.Win.Registry,

  { WinAPI }
  Winapi.Windows,
  Winapi.MMSystem,
  Winapi.ShellAPI,

  { Misc Libraries }
  SysTools,
  RegExpr, System.IOUtils, System.UITypes, Vcl.Dialogs;
{$ENDREGION}

(*****************************************************************************)
(*  TOptions
(*****************************************************************************)

constructor TOptions.Create;
const
  cTextNameProgram = 'Phase\UMake';
  cTextNameSettingPerform: array [TOptionsPerformIndex] of string = ('Success', 'Failure');
var
  LRegistry: TRegistry;
  LTextFileSound: string;
  LTextNameSetting: string;
  LTextNameSound: string;
begin
  RegOptDetails := TRegOptBoolean.Create(cTextNameProgram, 'Details', False);
  RegOptEditor := TRegOptString.Create(cTextNameProgram, 'Editor', '');
  RegOptProjects := TRegOptString.CreateList(cTextNameProgram, 'Projects');

  for var LIndexProject: Integer := RegOptProjects.ItemCount - 1 downto 0 do
  begin
    if not TDirectory.Exists(RegOptProjects[LIndexProject].Value) then
      RegOptProjects.ItemDelete(LIndexProject);
  end;

  if not TDirectory.Exists(RegOptProjects.Value) then
    RegOptProjects.Value := string.Empty;

  LRegistry := TRegistry.Create;
  try
    for var LIndexPerform: TOptionsPerformIndex := Low(TOptionsPerformIndex) to High(TOptionsPerformIndex) do
    begin
      case LIndexPerform of
        perfSuccess: LTextNameSound := 'SystemExclamation';
        perfFailure: LTextNameSound := 'SystemHand';
      end;

      if LRegistry.OpenKeyReadOnly('\AppEvents\Schemes\Apps\.Default\' + LTextNameSound + '\.Current') then
        LTextFileSound := LRegistry.ReadString(string.Empty)
      else
        LTextFileSound := string.Empty;

      LTextNameSetting := 'Perform' + cTextNameSettingPerform[LIndexPerform];

      Perform[LIndexPerform].RegOptWindow := TRegOptInteger.Create(cTextNameProgram, LTextNameSetting + 'Window', Integer(perfWindowFront));
      Perform[LIndexPerform].RegOptLaunch := TRegOptString.Create(cTextNameProgram, LTextNameSetting + 'Launch', string.Empty);
      Perform[LIndexPerform].RegOptSound := TRegOptString.Create(cTextNameProgram, LTextNameSetting + 'Sound', LTextFileSound);

      if (Perform[LIndexPerform].RegOptWindow.Value < Integer(Low (TOptionsPerformWindow))) or
         (Perform[LIndexPerform].RegOptWindow.Value > Integer(High(TOptionsPerformWindow))) then
        Perform[LIndexPerform].RegOptWindow.Value := Integer(perfWindowFront);
    end;
  finally
    LRegistry.Free;
  end;
end;

destructor TOptions.Destroy;
begin
  RegOptDetails.Free;
  RegOptEditor.Free;
  RegOptProjects.Free;

  for var LIndexPerform: TOptionsPerformIndex := Low(TOptionsPerformIndex) to High(TOptionsPerformIndex) do
  begin
    Perform[LIndexPerform].RegOptWindow.Destroy;
    Perform[LIndexPerform].RegOptLaunch.Destroy;
    Perform[LIndexPerform].RegOptSound .Destroy;
  end;
end;

procedure TOptions.PerformAction(IndexPerform: TOptionsPerformIndex; Form: TCustomForm; Configuration: TConfiguration);
var
  LTextCommand: string;
  LOptionsSound: Integer;
begin
  if Perform[IndexPerform].RegOptSound.Value.Trim.Length > 0 then
  begin
    LOptionsSound := SND_FILENAME;
    if TOptionsPerformWindow(Perform[IndexPerform].RegOptWindow.Value) <> perfWindowClose then
      LOptionsSound := LOptionsSound + SND_ASYNC;

    PlaySound(PChar(Perform[IndexPerform].RegOptSound.Value), 0, LOptionsSound);
  end;

  LTextCommand := Perform[IndexPerform].RegOptLaunch.Value;
  if LTextCommand.Trim.Length > 0 then
  begin
    LTextCommand := ReplaceRegExpr('%package%', LTextCommand, Configuration.Package);
    LTextCommand := ReplaceRegExpr('%packagedir%', LTextCommand, Configuration.DirPackage);
    LTextCommand := ReplaceRegExpr('%gamedir%', LTextCommand, Configuration.DirGame);
    LaunchProgram(LTextCommand);
  end;

  case TOptionsPerformWindow(Perform[IndexPerform].RegOptWindow.Value) of
    perfWindowClose:
      begin
        Form.Hide;
        Form.Close;
      end;
    perfWindowFront:
      begin
        Form.Show;
        Form.Update;
      end;
  end;
end;

procedure TOptions.PerformEdit(Configuration: TConfiguration; TextFileError: string; IndexLineError: Integer);
var
  LTextCommand: string;
begin
  if RegOptEditor.Value.Length > 0 then
  begin
    LTextCommand := RegOptEditor.Value;
    LTextCommand := ReplaceRegExpr('%package%', LTextCommand, Configuration.Package);
    LTextCommand := ReplaceRegExpr('%packagedir%', LTextCommand, Configuration.DirPackage);
    LTextCommand := ReplaceRegExpr('%gamedir%', LTextCommand, Configuration.DirGame);
    LTextCommand := ReplaceRegExpr('%errfile%', LTextCommand, GetQuotedParam(TextFileError));

    if IndexLineError = 0 then
      LTextCommand := ReplaceRegExpr('%errline%', LTextCommand, '1')
    else
      LTextCommand := ReplaceRegExpr('%errline%', LTextCommand, IntToStr(IndexLineError));

    if not LaunchProgram(LTextCommand) then
      MessageDlg('Unable to start specified source code editor.', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0)
  end
  else
    MessageDlg('No source code editor specified.', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
end;

end.
