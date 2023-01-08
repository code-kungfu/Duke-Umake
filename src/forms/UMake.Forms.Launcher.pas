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
    BevelHints: TBevel;
    ButtonBrowseProject: TBitBtn;
    ButtonClose: TButton;
    ButtonCompile: TButton;
    ButtonOptions: TButton;
    LabelHints: TLabel;
    LabelHintsParagraph1: TLabel;
    LabelHintsParagraph2: TLabel;
    LabelSource: TLabel;
    ComboBoxProject: TComboBox;
    Note1: TLabel;
    Note2: TLabel;
    Label1: TLabel;
    procedure ButtonBrowseProjectClick(Sender: TObject);
    procedure ButtonOptionsClick(Sender: TObject);
    procedure ComboBoxProjectChange(Sender: TObject);
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
  UMake.Forms.Options;
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
var
  IndexProject: Integer;
begin
  for IndexProject := 0 to Options.RegOptProjects.ItemCount - 1 do
    ComboBoxProject.Items.Add(Options.RegOptProjects[IndexProject].Value);

  ComboBoxProject.Text := Options.RegOptProjects.Value;
  ComboBoxProjectChange(ComboBoxProject);
end;

procedure TfrmLauncher.MessageDropFiles(var Msg: TWMDropFiles);
var
  LengthTextFileDropped: Integer;
  TextFileDropped: string;
begin
  LengthTextFileDropped := DragQueryFile(Msg.Drop, 0, nil, 0) + 1;
  SetLength(TextFileDropped, LengthTextFileDropped);

  DragQueryFile(Msg.Drop, 0, PChar(TextFileDropped), LengthTextFileDropped);
  DragFinish(Msg.Drop);

  if FileExists(TextFileDropped) then
    TextFileDropped := ExcludeTrailingBackslash(ExtractFilePath(TextFileDropped));
  if AnsiSameText(ExtractFileName(TextFileDropped), 'Classes') then
    TextFileDropped := ExcludeTrailingBackslash(ExtractFilePath(TextFileDropped));

  ComboBoxProject.Text := TextFileDropped;
  ComboBoxProject.SelectAll;
end;

procedure TfrmLauncher.ButtonBrowseProjectClick(Sender: TObject);
var
  TextDirPath: string;
begin
  TextDirPath := BrowseFolder(Handle, 'Select the UnrealScript project directory you wish to compile:');

  if Length(TextDirPath) > 0 then
  begin
    if AnsiSameText(ExtractFileName(TextDirPath), 'Classes') then
      TextDirPath := ExcludeTrailingBackslash(ExtractFilePath(TextDirPath));

    ComboBoxProject.Text := TextDirPath;
    ComboBoxProjectChange(ComboBoxProject);
  end;

  ComboBoxProject.SetFocus;
end;

procedure TfrmLauncher.ComboBoxProjectChange(Sender: TObject);
var
  TextDirPackage: string;
begin
  FreeAndNil(Configuration);

  TextDirPackage := Trim(ComboBoxProject.Text);
  if DirectoryExists(TextDirPackage) then
  begin
    TextDirPackage := GetLongPath(TextDirPackage);
    TextDirPackage := ExcludeTrailingBackslash(TextDirPackage);

    try
      Configuration := TConfiguration.Create(ExtractFileName(TextDirPackage), ExtractFilePath(TextDirPackage));
      Configuration.Read;
    except
      on EConfiguration do FreeAndNil(Configuration);
    end;
  end;

  ButtonCompile.Enabled := Assigned(Configuration);
  ButtonCompile.Default := Assigned(Configuration);    
end;

procedure TfrmLauncher.ButtonOptionsClick(Sender: TObject);
begin
  FormOptions.Configuration := Configuration;
  FormOptions.Options := Options;
  FormOptions.ShowModal;
end;

end.
