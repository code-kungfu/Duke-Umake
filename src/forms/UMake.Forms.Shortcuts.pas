unit UMake.Forms.Shortcuts;


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
  System.Win.Registry,

  { WinAPI }
  Winapi.Windows,
  Winapi.Messages,

  { UMake Libraries }
  UMake.Configuration,
  SysTools,
  Shortcuts;
{$ENDREGION}


(*****************************************************************************)
(*  TFormShortcuts
(*****************************************************************************)

type
  TfrmShortcuts = class(TForm)
    BevelAuto: TBevel;
    BevelGeneric: TBevel;
    BevelProject: TBevel;
    ButtonBrowseGame: TBitBtn;
    ButtonCancel: TButton;
    ButtonCreate: TButton;
    ComboBoxGame: TComboBox;
    lblExplanationAuto: TLabel;
    lblExplanationGeneric: TLabel;
    lblExplanationProject: TLabel;
    lblProject: TLabel;
    PanelFocus: TPanel;
    RadioButtonAuto: TRadioButton;
    RadioButtonGeneric: TRadioButton;
    RadioButtonProject: TRadioButton;
    procedure FormShow(Sender: TObject);
    procedure ButtonBrowseGameClick(Sender: TObject);
    procedure ButtonCreateClick(Sender: TObject);
    procedure ComboBoxGameChange(Sender: TObject);
  private
    procedure CreateShortcutGeneric;
    procedure CreateShortcutProject;
    procedure CreateShortcutAuto;
  public
    Configuration: TConfiguration;
  end;

var
  frmShortcuts: TfrmShortcuts;

implementation

uses
  System.IOUtils, System.UITypes;

{$R *.DFM}

(*****************************************************************************)
(*  TFormShortcuts
(*****************************************************************************)

procedure TfrmShortcuts.FormShow(Sender: TObject);
var
  LRegistry: TRegistry;
  LStringListKeys: TStringList;
  LTextDirGame: string;
begin
  PanelFocus.SetFocus;
  RadioButtonGeneric.Checked := True;

  LRegistry := TRegistry.Create;
  try
    LRegistry.RootKey := HKEY_LOCAL_MACHINE;
    if LRegistry.OpenKeyReadOnly('\SOFTWARE\Unreal Technology\Installed Apps') then
    begin
      LStringListKeys := TStringList.Create;
      try
        LRegistry.GetKeyNames(LStringListKeys);
        LRegistry.CloseKey;

        for var LIndexKey: Integer := 0 to LStringListKeys.Count - 1 do
        begin
          if LRegistry.OpenKeyReadOnly('\SOFTWARE\Unreal Technology\Installed Apps\' + LStringListKeys[LIndexKey]) then
          begin
            if LRegistry.ValueExists('Folder') then
            begin
              LTextDirGame := LRegistry.ReadString('Folder');
              LTextDirGame := GetLongPath(LTextDirGame);
              if FileExists(IncludeTrailingBackslash(LTextDirGame) + 'System\ucc.exe') and (ComboBoxGame.Items.IndexOf(LTextDirGame) < 0) then
                ComboBoxGame.Items.Add(ExcludeTrailingBackslash(LTextDirGame));
            end;
            LRegistry.CloseKey;
          end;
        end;

        if ComboBoxGame.Items.Count > 0 then
          ComboBoxGame.Text := ComboBoxGame.Items[0];

      finally
        LStringListKeys.Free;
      end;
    end;
  finally
    LRegistry.Free;
  end;

  if Assigned(Configuration) then
  begin
    lblProject.Caption := Format('for %s', [Configuration.Package]);
    lblExplanationProject.Caption := Format('Double-click this shortcut to directly compile the currently loaded project, %s.', [Configuration.Package]);
    BevelProject.SetBounds(lblProject.Left + lblProject.Width + 5, BevelProject.Top, BevelProject.Left + BevelProject.Width - lblProject.Left - lblProject.Width - 5, BevelProject.Height);
    ComboBoxGame.Text := ExcludeTrailingBackslash(Configuration.DirGame);
  end
  else
  begin
    RadioButtonProject.Enabled := False;
    lblProject.Hide;
    lblExplanationProject.Enabled := False;
    lblExplanationProject.Caption := 'Load a project first to enable this option.';
    BevelProject.SetBounds(lblProject.Left + 2, BevelProject.Top, BevelProject.Left + BevelProject.Width - lblProject.Left - 2, BevelProject.Height);
  end;
end;

procedure TfrmShortcuts.ButtonBrowseGameClick(Sender: TObject);
var
  LTextDirGame: string;
begin
  LTextDirGame := BrowseFolder(Handle, 'Select the base directory of the game UMake should search for recently modified projects:');
  ComboBoxGame.Text := ExcludeTrailingBackslash(LTextDirGame);
  ComboBoxGameChange(ComboBoxGame);
  ComboBoxGame.SetFocus;
end;

procedure TfrmShortcuts.ComboBoxGameChange(Sender: TObject);
begin
  RadioButtonAuto.Checked := True;
end;

procedure TfrmShortcuts.ButtonCreateClick(Sender: TObject);
begin
  if RadioButtonGeneric.Checked then
    CreateShortcutGeneric
  else
  if RadioButtonProject.Checked then
    CreateShortcutProject
  else
  if RadioButtonAuto.Checked then
    CreateShortcutAuto;
end;

procedure TfrmShortcuts.CreateShortcutGeneric;
var
  LShortcutDesktop: TFileShortcut;
begin
  LShortcutDesktop := TFileShortcut.Create;
  try
    LShortcutDesktop.Path := GetLongPath(ParamStr(0));
    LShortcutDesktop.Description := 'Compile an UnrealScript file by dropping it on this icon.';
    LShortcutDesktop.Save(IncludeTrailingBackslash(GetDesktopPath) + 'UMake.lnk');
  finally
    LShortcutDesktop.Free;
  end;
end;

procedure TfrmShortcuts.CreateShortcutProject;
var
  LShortcutDesktop: TFileShortcut;
begin
  LShortcutDesktop := TFileShortcut.Create;
  try
  LShortcutDesktop.Path := GetLongPath(ParamStr(0));
  LShortcutDesktop.Arguments := GetQuotedParam(Configuration.DirPackage);
  LShortcutDesktop.Description := Format('Double-click this icon to compile %s.', [Configuration.Package]);
  LShortcutDesktop.Save(IncludeTrailingBackslash(GetDesktopPath) + Format('Compile %s.lnk', [Configuration.Package]));
  finally
    LShortcutDesktop.Free;
  end;
end;

procedure TfrmShortcuts.CreateShortcutAuto;
var
  LShortcutDesktop: TFileShortcut;
  LTextDirGame: string;
begin
  LTextDirGame := GetLongPath(ComboBoxGame.Text);

  if TFile.Exists(TPath.Combine(LTextDirGame, 'System\ucc.exe')) then
  begin
    LShortcutDesktop := TFileShortcut.Create;
    try
      LShortcutDesktop.Path := GetLongPath(ParamStr(0));
      LShortcutDesktop.Arguments := Format('/auto %s', [GetQuotedParam(LTextDirGame)]);
      LShortcutDesktop.Description := Format('Double-click this icon to compile the most recently modified project in %s.', [ExtractFileName(ComboBoxGame.Text)]);
      LShortcutDesktop.Save(IncludeTrailingBackslash(GetDesktopPath) + Format('Compile %s Project.lnk', [ExtractFileName(ComboBoxGame.Text)]));
    finally
      LShortcutDesktop.Free;
    end;
  end
  else
  begin
    if TDirectory.Exists(LTextDirGame) then
      MessageDlg('Invalid game directory.' + #13#10#13#10 + 'The game directory you selected seems to be invalid (no compiler found). Maybe you have to download and install a developer''s toolkit first.', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0)
    else
      MessageDlg('The selected game directory doesn''t exist.', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);

    ComboBoxGame.SetFocus;
    ModalResult := mrNone;
  end;
end;

end.
