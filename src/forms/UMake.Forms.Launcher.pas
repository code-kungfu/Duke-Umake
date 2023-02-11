unit UMake.Forms.Launcher;

interface

{$REGION '-> Global Uses Clause <-'}
uses
  { VCL }
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Buttons,
  Vcl.ExtCtrls,
  Vcl.FileCtrl,

  { RTL }
  System.SysUtils,
  System.Classes,

  { WinAPI }
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ShellAPI,

  { UMake Libraries }
  UMake.Configuration,
  UMake.Options,

  { Misc Libraries }
  SysTools;
{$ENDREGION}

(*****************************************************************************)
(*  TFormLaunch
(*****************************************************************************)

type
  TfrmLauncher = class(TForm)
    bvlHints: TBevel;
    btnBrowseProject: TBitBtn;
    btnClose: TButton;
    btnCompile: TButton;
    btnOptions: TButton;
    lblHints: TLabel;
    lblHintsParagraph1: TLabel;
    lblHintsParagraph2: TLabel;
    lblSource: TLabel;
    comProject: TComboBox;
    lblNote1: TLabel;
    lblNote2: TLabel;
    lblNote3: TLabel;
    procedure btnBrowseProjectClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnOptionsClick(Sender: TObject);
    procedure comProjectChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  protected
    procedure MessageDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
  public
    Configuration: TConfiguration;
    Options: TOptions;
  end;

var
  frmLauncher: TfrmLauncher;

implementation

{$REGION '-> Local Uses Clause <-'}
uses
  UMake.Forms.Options, System.IOUtils;
{$ENDREGION}

{$R *.DFM}

(*****************************************************************************)
(*  TFormLaunch
(*****************************************************************************)

procedure TfrmLauncher.FormCreate(Sender: TObject);
begin
  DragAcceptFiles(Handle, True);
end;

procedure TfrmLauncher.FormShow(Sender: TObject);
begin
  for var LIndexProject: Integer := 0 to Options.RegOptProjects.ItemCount - 1 do
    comProject.Items.Add(Options.RegOptProjects[LIndexProject].Value);

  comProject.Text := Options.RegOptProjects.Value;
  comProjectChange(comProject);
end;

procedure TfrmLauncher.MessageDropFiles(var Msg: TWMDropFiles);
var
  LLengthTextFileDropped: Integer;
  LTextFileDropped: string;
begin
  LLengthTextFileDropped := DragQueryFile(Msg.Drop, 0, nil, 0) + 1;
  SetLength(LTextFileDropped, LLengthTextFileDropped);

  DragQueryFile(Msg.Drop, 0, PChar(LTextFileDropped), LLengthTextFileDropped);
  DragFinish(Msg.Drop);

  if TDirectory.Exists(LTextFileDropped) then
    LTextFileDropped := ExcludeTrailingBackslash(ExtractFilePath(LTextFileDropped));

  if SameText(ExtractFileName(LTextFileDropped), 'Classes') then
    LTextFileDropped := ExcludeTrailingBackslash(ExtractFilePath(LTextFileDropped));

  comProject.Text := LTextFileDropped;
  comProject.SelectAll;
end;

procedure TfrmLauncher.btnBrowseProjectClick(Sender: TObject);
var
  LTextDirPath: string;
begin
  LTextDirPath := BrowseFolder(Handle, 'Select the UnrealScript project directory you wish to compile:');
  if LTextDirPath.Length > 0 then
  begin
    if SameText(ExtractFileName(LTextDirPath), 'Classes') then
      LTextDirPath := ExcludeTrailingBackslash(ExtractFilePath(LTextDirPath));

    comProject.Text := LTextDirPath;
    comProjectChange(comProject);
  end;
  comProject.SetFocus;
end;

procedure TfrmLauncher.btnCloseClick(Sender: TObject);
begin
  //Close;
end;

procedure TfrmLauncher.comProjectChange(Sender: TObject);
var
  LTextDirPackage: string;
begin
  if Configuration <> nil then
    Configuration.Free;

  LTextDirPackage := Trim(comProject.Text);
  if TDirectory.Exists(LTextDirPackage) then
  begin
    LTextDirPackage := GetLongPath(LTextDirPackage);
    LTextDirPackage := ExcludeTrailingBackslash(LTextDirPackage);
    try
      Configuration := TConfiguration.Create(ExtractFileName(LTextDirPackage), ExtractFilePath(LTextDirPackage));
      Configuration.Read;
    except
      on EConfiguration do
        Configuration.Free;
    end;
  end;

  btnCompile.Enabled := Assigned(Configuration);
  btnCompile.Default := Assigned(Configuration);
end;

procedure TfrmLauncher.btnOptionsClick(Sender: TObject);
begin
  frmOptions.Configuration := Configuration;
  frmOptions.Options := Options;
  frmOptions.ShowModal;
end;

end.
