unit UMake.Forms.Options;


interface


{$REGION '-> Global Uses Clause <-'}
uses
  { VCL }
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,
  Vcl.CheckLst,
  Vcl.Buttons,
  Vcl.Menus,

  { RTL }
  System.SysUtils,
  System.Classes,
  System.Win.Registry,

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
(*  TFormOptions
(*****************************************************************************)

type
  TfrmOptions = class(TForm)
    BevelAboutAdditional: TBevel;
    BevelAboutUMake: TBevel;
    BevelDependencies: TBevel;
    BevelPaths: TBevel;
    BevelShortcutDesktop: TBevel;
    BevelShortcutExplorer: TBevel;
    ButtonBrowseEditor: TBitBtn;
    ButtonBrowsePaths: TButton;
    ButtonBrowsePerformLaunch: TBitBtn;
    ButtonBrowsePerformSound: TBitBtn;
    ButtonCancel: TButton;
    ButtonDependencyDown: TBitBtn;
    ButtonDependencySelect: TButton;
    ButtonDependencyUp: TBitBtn;
    ButtonOK: TButton;
    ButtonPlaceholdersEditor: TBitBtn;
    ButtonShortcutDesktop: TButton;
    ButtonShortcutExplorer: TButton;
    CheckBoxDetails: TCheckBox;
    CheckBoxPerformLaunch: TCheckBox;
    CheckBoxPerformSound: TCheckBox;
    CheckBoxPerformWindowClose: TCheckBox;
    CheckBoxPerformWindowFront: TCheckBox;
    CheckListBoxDependencies: TCheckListBox;
    CheckListBoxPaths: TCheckListBox;
    EditEditor: TEdit;
    EditPerformLaunch: TEdit;
    EditPerformSound: TEdit;
    LabelAboutAdditional: TLabel;
    LabelAboutHashes: TLabel;
    LabelAboutHashesCopyright: TLabel;
    LabelAboutRegexp: TLabel;
    LabelAboutRegexpCopyright: TLabel;
    LabelAboutUMake: TLabel;
    LabelAboutUMakeCopyright: TLabel;
    LabelAboutUMakeVersion: TLabel;
    LabelDependencies: TLabel;
    LabelEditor: TLabel;
    LabelPaths: TLabel;
    LabelProjectExplanation: TLabel;
    LabelShortcutDesktop: TLabel;
    LabelShortcutDesktopExplanation: TLabel;
    LabelShortcutExplorer: TLabel;
    LabelShortcutExplorerExplanation: TLabel;
    MenuItemPlaceholderErrorFile: TMenuItem;
    MenuItemPlaceholderErrorLine: TMenuItem;
    MenuItemPlaceholderPackage: TMenuItem;
    MenuItemPlaceholderSeparator: TMenuItem;
    OpenDialogApplication: TOpenDialog;
    OpenDialogPackage: TOpenDialog;
    OpenDialogPath: TOpenDialog;
    OpenDialogSound: TOpenDialog;
    PageControl: TPageControl;
    PageControlPerform: TPageControl;
    PanelFocusProject: TPanel;
    PanelFocusShortcuts: TPanel;
    PopupMenuPlaceholders: TPopupMenu;
    StaticTextMailAboutHashes: TStaticText;
    StaticTextMailAboutRegexp: TStaticText;
    StaticTextMailAboutUMake: TStaticText;
    StaticTextPerformWindow: TStaticText;
    TabSheetAbout: TTabSheet;
    TabSheetGeneral: TTabSheet;
    TabSheetPerformFailure: TTabSheet;
    TabSheetPerformSuccess: TTabSheet;
    TabSheetProject: TTabSheet;
    TabSheetShortcuts: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    procedure StaticTextMailAboutRegexpMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure StaticTextMailAboutRegexpMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ButtonBrowseEditorClick(Sender: TObject);
    procedure ButtonPlaceholdersEditorClick(Sender: TObject);
    procedure MenuItemPlaceholderClick(Sender: TObject);
    procedure PageControlChange(Sender: TObject);
    procedure ButtonDependencyUpClick(Sender: TObject);
    procedure ButtonDependencyDownClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CheckListBoxDependenciesClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ButtonDependencySelectClick(Sender: TObject);
    procedure CheckBoxPerformWindowFrontClick(Sender: TObject);
    procedure CheckBoxPerformWindowCloseClick(Sender: TObject);
    procedure PageControlPerformChange(Sender: TObject);
    procedure EditPerformLaunchChange(Sender: TObject);
    procedure EditPerformSoundChange(Sender: TObject);
    procedure CheckBoxPerformLaunchClick(Sender: TObject);
    procedure ButtonBrowsePerformLaunchClick(Sender: TObject);
    procedure CheckBoxPerformSoundClick(Sender: TObject);
    procedure ButtonBrowsePerformSoundClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ButtonBrowsePathsClick(Sender: TObject);
    procedure ButtonShortcutExplorerClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ButtonShortcutDesktopClick(Sender: TObject);
  public
    Configuration: TConfiguration;
    Options: TOptions;
  private
    OptionsPerform: array [TOptionsPerformIndex] of record
      Window: TOptionsPerformWindow;
      TextLaunch: string;
      TextSound: string;
    end;
    function GetIndexPerform: TOptionsPerformIndex;
  end;

var
  frmOptions: TfrmOptions;

implementation

{$REGION '-> Local Uses Clause <-'}
uses
  { RTL }
  System.UITypes,
  System.Types,

  { UMake Forms }
  UMake.Forms.Shortcuts;
{$ENDREGION}

{$R *.DFM}

(*****************************************************************************)
(*  Global
(*****************************************************************************)

function IsInRect(const AX, AY: Integer; const ARect: TRect): Boolean;
begin
  Result := (AX >= ARect.Left) and
            (AX < ARect.Right) and
            (AY >= ARect.Top)  and
            (AY < ARect.Bottom);
end;

(*****************************************************************************)
(*  TFormOptions
(*****************************************************************************)

procedure TfrmOptions.FormShow(Sender: TObject);
var
  LIndexItemAdded: Integer;
  LTextPath: string;
begin
  if Assigned(Configuration) then
  begin
    TabSheetProject.TabVisible := True;
    LabelProjectExplanation.Caption := Format('The options on this tab only affect the currently selected project, %s.', [Configuration.Package]);

    CheckListBoxDependencies.Clear;
    for var LIndexItem: Integer := 0 to Configuration.StringListPackages.Count - 1 do
    begin
      if not SameText(Configuration.StringListPackages[LIndexItem], Configuration.Package) then
      begin
        LIndexItemAdded := CheckListBoxDependencies.Items.Add(Configuration.StringListPackages[LIndexItem]);
        CheckListBoxDependencies.Checked[LIndexItemAdded] := True;
      end;
    end;

    CheckListBoxDependenciesClick(CheckListBoxDependencies);

    CheckListBoxPaths.Clear;
    for var LIndexItem: Integer := 0 to Configuration.StringListPaths.Count - 1 do
    begin
      LTextPath := StringReplace(Configuration.StringListPaths[LIndexItem], '/', '\', [rfReplaceAll]);
      LTextPath := GetAbsolutePath(LTextPath, IncludeTrailingBackslash(Configuration.DirGame) + 'System\');
      LTextPath := GetRelativePath(LTextPath, IncludeTrailingBackslash(Configuration.DirGame));

      LIndexItemAdded := CheckListBoxPaths.Items.Add(LTextPath);
      CheckListBoxPaths.Checked[LIndexItemAdded] := True;
    end;
  end
  else
  begin
    TabSheetProject.TabVisible := False;
  end;

  EditEditor.Text := Options.RegOptEditor.Value;
  CheckBoxDetails.Checked := Options.RegOptDetails.Value;

  for var LIndexPerform: TOptionsPerformIndex := Low(TOptionsPerformIndex) to High(TOptionsPerformIndex) do
  begin
    OptionsPerform[LIndexPerform].Window := TOptionsPerformWindow(Options.Perform[LIndexPerform].RegOptWindow.Value);
    OptionsPerform[LIndexPerform].TextLaunch := Options.Perform[LIndexPerform].RegOptLaunch.Value;
    OptionsPerform[LIndexPerform].TextSound := Options.Perform[LIndexPerform].RegOptSound .Value;
  end;

  if Assigned(Configuration) then
  begin
    OpenDialogPackage.InitialDir := IncludeTrailingBackslash(Configuration.DirGame) + 'System';
    OpenDialogPath.InitialDir := IncludeTrailingBackslash(Configuration.DirGame) + 'System';
    PageControl.ActivePage := TabSheetProject;
  end
  else
  begin
    PageControl.ActivePage := TabSheetGeneral;
  end;

  PageControlPerform.ActivePage := TabSheetPerformSuccess;
  {$IF Defined(DEBUG)}
  TabSheetProject.TabVisible := True;
  {$ENDIF}
end;

procedure TfrmOptions.FormActivate(Sender: TObject);
begin
  PageControlPerformChange(PageControlPerform);
  PageControlChange(PageControl);
end;

procedure TfrmOptions.StaticTextMailAboutRegexpMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if IsInRect(X, Y, TStaticText(Sender).ClientRect) then
  begin
    TStaticText(Sender).Font.Color := clBlue;
    TStaticText(Sender).Font.Style := TStaticText(Sender).Font.Style + [fsUnderline];
    Mouse.Capture := TWinControl(Sender).Handle;
  end
  else
  begin
    Color := clWindowText;
    TStaticText(Sender).Font.Style := TStaticText(Sender).Font.Style - [fsUnderline];
    Mouse.Capture := 0;
  end;
end;

procedure TfrmOptions.StaticTextMailAboutRegexpMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LTextTarget: string;
begin
  if IsInRect(X, Y, TStaticText(Sender).ClientRect) then
  begin
    LTextTarget := TStaticText(Sender).Caption;
    if Pos(':', LTextTarget) = 0 then
      LTextTarget := 'mailto:' + LTextTarget;

    ShellExecute(Handle, nil, PChar(LTextTarget), nil, nil, SW_SHOWNORMAL);
  end;
end;

procedure TfrmOptions.ButtonBrowseEditorClick(Sender: TObject);
begin
  OpenDialogApplication.FileName := GetFirstParam(EditEditor.Text);
  OpenDialogApplication.InitialDir := ExtractFilePath(OpenDialogApplication.FileName);

  if OpenDialogApplication.Execute then
    EditEditor.Text := GetQuotedParam(OpenDialogApplication.FileName);

  EditEditor.SelStart := Length(EditEditor.Text);
  EditEditor.SetFocus;
end;

procedure TfrmOptions.ButtonPlaceholdersEditorClick(Sender: TObject);
var
  LPointPopup: TPoint;
begin
  LPointPopup := ButtonPlaceholdersEditor.ClientToScreen(Point(0, ButtonPlaceholdersEditor.Height));
  PopupMenuPlaceholders.Popup(LPointPopup.X, LPointPopup.Y);
end;

procedure TfrmOptions.MenuItemPlaceholderClick(Sender: TObject);
var
  LTextPlaceholder: string;
begin
  case TMenuItem(Sender).Tag of
    0: LTextPlaceholder := 'package';
    1: LTextPlaceholder := 'errfile';
    2: LTextPlaceholder := 'errline';
  end;

  LTextPlaceholder := '%' + LTextPlaceholder + '%';

  if (EditEditor.SelStart >= 1) and (EditEditor.SelStart <= Length(EditEditor.Text)) and (EditEditor.Text[EditEditor.SelStart] <> ' ') then
    LTextPlaceholder := ' ' + LTextPlaceholder;

  EditEditor.SelText := LTextPlaceholder;
  EditEditor.SetFocus;
end;

procedure TfrmOptions.PageControlChange(Sender: TObject);
begin
  if PageControl.ActivePage = TabSheetProject then
  begin
    PanelFocusProject.SetFocus;
  end
  else
  if PageControl.ActivePage = TabSheetGeneral then
  begin
    EditEditor.SelStart := Length(EditEditor.Text);
    EditEditor.SetFocus;
  end
  else
  if PageControl.ActivePage = TabSheetShortcuts then
  begin
    PanelFocusShortcuts.SetFocus;
  end;
end;

procedure TfrmOptions.ButtonDependencyUpClick(Sender: TObject);
begin
  if CheckListBoxDependencies.ItemIndex > 0 then
    CheckListBoxDependencies.Items.Exchange(CheckListBoxDependencies.ItemIndex, CheckListBoxDependencies.ItemIndex - 1);

  CheckListBoxDependenciesClick(CheckListBoxDependencies);
end;

procedure TfrmOptions.ButtonDependencyDownClick(Sender: TObject);
begin
  if CheckListBoxDependencies.ItemIndex < CheckListBoxDependencies.Items.Count - 1 then
    CheckListBoxDependencies.Items.Exchange(CheckListBoxDependencies.ItemIndex, CheckListBoxDependencies.ItemIndex + 1);

  CheckListBoxDependenciesClick(CheckListBoxDependencies);
end;

procedure TfrmOptions.CheckListBoxDependenciesClick(Sender: TObject);
var
  LControlFocused: TControl;
begin
  LControlFocused := ActiveControl;

  ButtonDependencyDown.Enabled := (CheckListBoxDependencies.ItemIndex >= 0) and
                                  (CheckListBoxDependencies.ItemIndex < CheckListBoxDependencies.Items.Count - 1);

  ButtonDependencyUp.Enabled := CheckListBoxDependencies.ItemIndex >  0;

  if Assigned(LControlFocused) and not LControlFocused.Enabled then
    CheckListBoxDependencies.SetFocus;
end;

procedure TfrmOptions.ButtonDependencySelectClick(Sender: TObject);
var
  LIndexItem: Integer;
  LTextNamePackage: string;
begin
  OpenDialogPackage.FileName := string.Empty;

  if OpenDialogPackage.Execute then
  begin
    CheckListBoxDependencies.Items.BeginUpdate;

    for var LIndexFile: Integer := 0 to OpenDialogPackage.Files.Count - 1 do
    begin
      LTextNamePackage := ExtractFileName(ChangeFileExt(OpenDialogPackage.Files[LIndexFile], string.Empty));

      LIndexItem := CheckListBoxDependencies.Items.IndexOf(LTextNamePackage);
      if LIndexItem < 0 then
        LIndexItem := CheckListBoxDependencies.Items.Add(LTextNamePackage);

      CheckListBoxDependencies.Checked[LIndexItem] := True;
      CheckListBoxDependencies.ItemIndex := LIndexItem;
    end;

    CheckListBoxDependencies.Items.EndUpdate;
  end;

  CheckListBoxDependenciesClick(CheckListBoxDependencies);
  CheckListBoxDependencies.SetFocus;
end;

procedure TfrmOptions.ButtonBrowsePathsClick(Sender: TObject);
var
  LIndexItem: Integer;
  LTextPath: string;
begin
  if OpenDialogPath.Execute then
  begin
    LTextPath := OpenDialogPath.FileName;
    LTextPath := ExtractFilePath(LTextPath) + '*' + ExtractFileExt(LTextPath);
    LTextPath := GetRelativePath(LTextPath, IncludeTrailingBackslash(Configuration.DirGame));

    LIndexItem := CheckListBoxPaths.Items.IndexOf(LTextPath);
    if LIndexItem < 0 then
      LIndexItem := CheckListBoxPaths.Items.Add(LTextPath);

    CheckListBoxPaths.Checked[LIndexItem] := True;
    CheckListBoxPaths.ItemIndex := LIndexItem;
  end;

  CheckListBoxPaths.SetFocus;
end;

function TfrmOptions.GetIndexPerform: TOptionsPerformindex;
begin
  if PageControlPerform.ActivePage = TabSheetPerformSuccess then
    Result := perfSuccess
  else
    Result := perfFailure;
end;

procedure TfrmOptions.CheckBoxPerformWindowFrontClick(Sender: TObject);
begin
  if CheckBoxPerformWindowFront.Checked then
  begin
    CheckBoxPerformWindowClose.Checked := False;
    OptionsPerform[GetIndexPerform].Window := perfWindowFront;
  end
  else
  begin
    OptionsPerform[GetIndexPerform].Window := perfWindowNone;
  end;
end;

procedure TfrmOptions.CheckBoxPerformWindowCloseClick(Sender: TObject);
begin
  if CheckBoxPerformWindowClose.Checked then
  begin
    CheckBoxPerformWindowFront.Checked := False;
    OptionsPerform[GetIndexPerform].Window := perfWindowClose;
  end
  else
    OptionsPerform[GetIndexPerform].Window := perfWindowNone;
end;

procedure TfrmOptions.PageControlPerformChange(Sender: TObject);
begin
  case OptionsPerform[GetIndexPerform].Window of
    perfWindowNone:
    begin
      CheckBoxPerformWindowClose.Checked := False;
      CheckBoxPerformWindowFront.Checked := False;
    end;

    perfWindowFront: CheckBoxPerformWindowFront.Checked := True;
    perfWindowClose: CheckBoxPerformWindowClose.Checked := True;
  end;

  EditPerformLaunch.Text := OptionsPerform[GetIndexPerform].TextLaunch;
  EditPerformSound .Text := OptionsPerform[GetIndexPerform].TextSound;

  if PageControl.ActivePage = TabSheetGeneral then
    CheckBoxPerformWindowFront.SetFocus;
end;

procedure TfrmOptions.EditPerformLaunchChange(Sender: TObject);
begin
  OptionsPerform[GetIndexPerform].TextLaunch := EditPerformLaunch.Text;
  CheckBoxPerformLaunch.Checked := Length(Trim(EditPerformLaunch.Text)) > 0;
end;

procedure TfrmOptions.EditPerformSoundChange(Sender: TObject);
begin
  OptionsPerform[GetIndexPerform].TextSound := EditPerformSound.Text;
  CheckBoxPerformSound.Checked := Length(Trim(EditPerformSound.Text)) > 0;
end;

procedure TfrmOptions.CheckBoxPerformLaunchClick(Sender: TObject);
begin
  if CheckBoxPerformLaunch.Checked then
  begin
    if string(EditPerformLaunch.Text).Trim.Length = 0 then
    begin
      CheckBoxPerformLaunch.Checked := False;
      ButtonBrowsePerformLaunchClick(ButtonBrowsePerformLaunch);
    end;
  end
  else
    EditPerformLaunch.Text := string.Empty;
end;

procedure TfrmOptions.ButtonBrowsePerformLaunchClick(Sender: TObject);
begin
  OpenDialogApplication.FileName := GetFirstParam(EditPerformLaunch.Text);
  OpenDialogApplication.InitialDir := ExtractFilePath(OpenDialogApplication.FileName);

  if OpenDialogApplication.Execute then
    EditPerformLaunch.Text := GetQuotedParam(OpenDialogApplication.FileName);

  EditPerformLaunch.SelStart := Length(EditPerformLaunch.Text);
  EditPerformLaunch.SetFocus;
end;

procedure TfrmOptions.CheckBoxPerformSoundClick(Sender: TObject);
begin
  if CheckBoxPerformSound.Checked then
  begin
    if string(EditPerformSound.Text).Trim.Length = 0 then
    begin
      CheckBoxPerformSound.Checked := False;
      ButtonBrowsePerformSoundClick(ButtonBrowsePerformSound);
    end;
  end
  else
    EditPerformSound.Text := string.Empty;
end;

procedure TfrmOptions.ButtonBrowsePerformSoundClick(Sender: TObject);
begin
  OpenDialogSound.FileName := GetFirstParam(EditPerformSound.Text);
  OpenDialogSound.InitialDir := ExtractFilePath(OpenDialogSound.FileName);

  if OpenDialogSound.Execute then
    EditPerformSound.Text := OpenDialogSound.FileName;

  EditPerformSound.SelStart := Length(EditPerformSound.Text);
  EditPerformSound.SetFocus;
end;

procedure TfrmOptions.ButtonShortcutDesktopClick(Sender: TObject);
begin
  frmShortcuts.Left := Left + (Width - frmShortcuts.Width) div 2;
  frmShortcuts.Top := Top + (Height - frmShortcuts.Height) div 2;
  frmShortcuts.Configuration := Configuration;
  frmShortcuts.ShowModal;
  PanelFocusShortcuts.SetFocus;
end;

procedure TfrmOptions.ButtonShortcutExplorerClick(Sender: TObject);
var
  LRegistry: TRegistry;
  LTextKeyFile: string;
begin
  PanelFocusShortcuts.SetFocus;
  LRegistry := TRegistry.Create;
  try
    LRegistry.RootKey := HKEY_CLASSES_ROOT;
    try
      LTextKeyFile := string.Empty;

      if LRegistry.OpenKey('\.uc', False) then
      begin
        LTextKeyFile := LRegistry.ReadString(string.Empty);
        LRegistry.CloseKey;
      end;

      if LTextKeyFile.Length = 0 then
      begin
        LTextKeyFile := 'UnrealScript';

        if not LRegistry.OpenKey('\.uc', True) then
          raise ERegistryException.Create('Unable to create file extension key');

        LRegistry.WriteString(string.Empty, LTextKeyFile);
        LRegistry.CloseKey;
      end;

      if not LRegistry.OpenKey(Format('\%s\shell\compile', [LTextKeyFile]), True) then
        raise ERegistryException.Create('Unable to create "compile" command description');

      LRegistry.WriteString(string.Empty, 'UMake Compile');
      LRegistry.CloseKey;

      if not LRegistry.OpenKey(Format('\%s\shell\compile\command', [LTextKeyFile]), True) then
        raise ERegistryException.Create('Unable to create "compile" command');

      LRegistry.WriteString(string.Empty, Format('%s "%%1"', [GetQuotedParam(GetLongPath(ParamStr(0)))]));
      LRegistry.CloseKey;

      if not LRegistry.OpenKey(Format('\%s\shell\setup', [LTextKeyFile]), True) then
        raise ERegistryException.Create('Unable to create "compile" command description');

      LRegistry.WriteString(string.Empty, 'UMake Project Setup');
      LRegistry.CloseKey;

      if not LRegistry.OpenKey(Format('\%s\shell\setup\command', [LTextKeyFile]), True) then
        raise ERegistryException.Create('Unable to create "compile" command');

      LRegistry.WriteString(string.Empty, Format('%s /setup "%%1"', [GetQuotedParam(GetLongPath(ParamStr(0)))]));
      LRegistry.CloseKey;

      MessageDlg('The Explorer right-click menu commands have been registered.', TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], 0);
    except
      on ERegistryException do
        MessageDlg('Unable to register Explorer commands. You might need administrator privileges to do this.', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
    end;
  finally
    LRegistry.Free;
  end;
end;

procedure TfrmOptions.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  LFlagFound: Boolean;
begin
  if ModalResult = mrOk then
  begin
    if TabSheetProject.TabVisible then
    begin
      LFlagFound := False;

      for var LIndexPath: Integer := 0 to CheckListBoxPaths.Items.Count - 1 do
      begin
        if CheckListBoxPaths.Checked[LIndexPath] and AnsiSameText(ExtractFileExt(CheckListBoxPaths.Items[LIndexPath]), '.u') then
        begin
          LFlagFound := True;
          Break;
        end;
      end;

      if not LFlagFound then
      begin
        PageControl.ActivePage := TabSheetProject;
        CheckListBoxPaths.SetFocus;
        MessageDlg('UMake will not be able to compile your project unless you specify a search path for .u files.', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
        CanClose := False;
      end;
    end;
  end;
end;

procedure TfrmOptions.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ModalResult = mrOk then
  begin
    Options.RegOptDetails.Value := CheckBoxDetails.Checked;
    Options.RegOptEditor.Value := EditEditor.Text;

    for var LIndexPerform: TOptionsPerformIndex := Low(TOptionsPerformIndex) to High(TOptionsPerformIndex) do
    begin
      Options.Perform[LIndexPerform].RegOptWindow.Value := Integer(OptionsPerform[LIndexPerform].Window);
      Options.Perform[LIndexPerform].RegOptLaunch.Value := OptionsPerform[LIndexPerform].TextLaunch;
      Options.Perform[LIndexPerform].RegOptSound .Value := OptionsPerform[LIndexPerform].TextSound;
    end;

    if Assigned(Configuration) then
    begin
      Configuration.StringListPackages.Clear;
      for var LIndexPackage: Integer := 0 to CheckListBoxDependencies.Items.Count - 1 do
      begin
        if CheckListBoxDependencies.Checked[LIndexPackage] then
          Configuration.StringListPackages.Add(CheckListBoxDependencies.Items[LIndexPackage]);
      end;
      Configuration.StringListPackages.Add(Configuration.Package);

      Configuration.StringListPaths.Clear;
      for var LIndexPath: Integer := 0 to CheckListBoxPaths.Items.Count - 1 do
      begin
        if CheckListBoxPaths.Checked[LIndexPath] then
        begin
          var LTextPath: string;
          LTextPath := CheckListBoxPaths.Items[LIndexPath];
          LTextPath := GetAbsolutePath(LTextPath, IncludeTrailingBackslash(Configuration.DirGame));
          LTextPath := GetRelativePath(LTextPath, IncludeTrailingBackslash(Configuration.DirGame) + 'System\');
          LTextPath := StringReplace(LTextPath, '\', '/', [rfReplaceAll]);
          Configuration.StringListPaths.Add(LTextPath);
        end;
      end;
      Configuration.Write;
    end;
  end;
end;

end.
