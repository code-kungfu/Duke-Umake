﻿unit UMake.Forms.Options;


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
  UMake.Forms.Shortcuts;
{$ENDREGION}

{$R *.DFM}

(*****************************************************************************)
(*  Global
(*****************************************************************************)

function IsInRect(X, Y: Integer; Rect: TRect): Boolean;
begin
  Result := (X >= Rect.Left) and (X < Rect.Right) and
            (Y >= Rect.Top)  and (Y < Rect.Bottom);
end;

(*****************************************************************************)
(*  TFormOptions
(*****************************************************************************)

procedure TfrmOptions.FormShow(Sender: TObject);
var
  IndexItem: Integer;
  IndexItemAdded: Integer;
  IndexPerform: TOptionsPerformIndex;
  TextPath: string;
begin
  if Assigned(Configuration) then
  begin
    TabSheetProject.TabVisible := True;
    LabelProjectExplanation.Caption := Format('The options on this tab only affect the currently selected project, %s.', [Configuration.Package]);

    CheckListBoxDependencies.Clear;
    for IndexItem := 0 to Configuration.StringListPackages.Count - 1 do
    begin
      if not AnsiSameText(Configuration.StringListPackages[IndexItem], Configuration.Package) then
      begin
        IndexItemAdded := CheckListBoxDependencies.Items.Add(Configuration.StringListPackages[IndexItem]);
        CheckListBoxDependencies.Checked[IndexItemAdded] := True;
      end;
    end;

    CheckListBoxDependenciesClick(CheckListBoxDependencies);

    CheckListBoxPaths.Clear;
    for IndexItem := 0 to Configuration.StringListPaths.Count - 1 do
    begin
      TextPath := StringReplace(Configuration.StringListPaths[IndexItem], '/', '\', [rfReplaceAll]);
      TextPath := GetAbsolutePath(TextPath, IncludeTrailingBackslash(Configuration.DirGame) + 'System\');
      TextPath := GetRelativePath(TextPath, IncludeTrailingBackslash(Configuration.DirGame));

      IndexItemAdded := CheckListBoxPaths.Items.Add(TextPath);
      CheckListBoxPaths.Checked[IndexItemAdded] := True;
    end;
  end
  else begin
    TabSheetProject.TabVisible := False;
  end;

  EditEditor.Text := Options.RegOptEditor.Value;
  CheckBoxDetails.Checked := Options.RegOptDetails.Value;

  for IndexPerform := Low(TOptionsPerformIndex) to High(TOptionsPerformIndex) do
  begin
    OptionsPerform[IndexPerform].Window := TOptionsPerformWindow(Options.Perform[IndexPerform].RegOptWindow.Value);
    OptionsPerform[IndexPerform].TextLaunch := Options.Perform[IndexPerform].RegOptLaunch.Value;
    OptionsPerform[IndexPerform].TextSound  := Options.Perform[IndexPerform].RegOptSound .Value;
  end;

  if Assigned(Configuration) then
  begin
    OpenDialogPackage.InitialDir := IncludeTrailingBackslash(Configuration.DirGame) + 'System';
    OpenDialogPath   .InitialDir := IncludeTrailingBackslash(Configuration.DirGame) + 'System';
    PageControl.ActivePage := TabSheetProject;
  end
  else begin
    PageControl.ActivePage := TabSheetGeneral;
  end;

  PageControlPerform.ActivePage := TabSheetPerformSuccess;
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
    with TStaticText(Sender).Font do
    begin
      Color := clBlue;
      Style := Style + [fsUnderline];
    end;

    Mouse.Capture := TWinControl(Sender).Handle;
  end
  else begin
    with TStaticText(Sender).Font do
    begin
      Color := clWindowText;
      Style := Style - [fsUnderline];
    end;

    Mouse.Capture := 0;
  end;
end;

procedure TfrmOptions.StaticTextMailAboutRegexpMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  TextTarget: string;
begin
  if IsInRect(X, Y, TStaticText(Sender).ClientRect) then
  begin
    TextTarget := TStaticText(Sender).Caption;
    if Pos(':', TextTarget) = 0 then
      TextTarget := 'mailto:' + TextTarget;

    ShellExecute(Handle, nil, PChar(TextTarget), nil, nil, SW_SHOWNORMAL);
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
  PointPopup: TPoint;
begin
  PointPopup := ButtonPlaceholdersEditor.ClientToScreen(Point(0, ButtonPlaceholdersEditor.Height));
  PopupMenuPlaceholders.Popup(PointPopup.X, PointPopup.Y);
end;

procedure TfrmOptions.MenuItemPlaceholderClick(Sender: TObject);
var
  TextPlaceholder: string;
begin
  case TMenuItem(Sender).Tag of
    0:  TextPlaceholder := 'package';
    1:  TextPlaceholder := 'errfile';
    2:  TextPlaceholder := 'errline';
  end;

  TextPlaceholder := '%' + TextPlaceholder + '%';

  if (EditEditor.SelStart >= 1) and (EditEditor.SelStart <= Length(EditEditor.Text)) and (EditEditor.Text[EditEditor.SelStart] <> ' ') then
    TextPlaceholder := ' ' + TextPlaceholder;

  EditEditor.SelText := TextPlaceholder;
  EditEditor.SetFocus;
end;

procedure TfrmOptions.PageControlChange(Sender: TObject);
begin
  if PageControl.ActivePage = TabSheetProject then
  begin
    PanelFocusProject.SetFocus;
  end

  else if PageControl.ActivePage = TabSheetGeneral then
  begin
    EditEditor.SelStart := Length(EditEditor.Text);
    EditEditor.SetFocus;
  end

  else if PageControl.ActivePage = TabSheetShortcuts then
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
  ControlFocused: TControl;
begin
  ControlFocused := ActiveControl;

  ButtonDependencyDown.Enabled := (CheckListBoxDependencies.ItemIndex >= 0) and (CheckListBoxDependencies.ItemIndex < CheckListBoxDependencies.Items.Count - 1);
  ButtonDependencyUp  .Enabled :=  CheckListBoxDependencies.ItemIndex >  0;

  if Assigned(ControlFocused) and not ControlFocused.Enabled then
    CheckListBoxDependencies.SetFocus;
end;

procedure TfrmOptions.ButtonDependencySelectClick(Sender: TObject);
var
  IndexFile: Integer;
  IndexItem: Integer;
  TextNamePackage: string;
begin
  OpenDialogPackage.FileName := '';

  if OpenDialogPackage.Execute then
  begin
    CheckListBoxDependencies.Items.BeginUpdate;

    for IndexFile := 0 to OpenDialogPackage.Files.Count - 1 do
    begin
      TextNamePackage := ExtractFileName(ChangeFileExt(OpenDialogPackage.Files[IndexFile], ''));

      IndexItem := CheckListBoxDependencies.Items.IndexOf(TextNamePackage);
      if IndexItem < 0 then
        IndexItem := CheckListBoxDependencies.Items.Add(TextNamePackage);

      CheckListBoxDependencies.Checked[IndexItem] := True;
      CheckListBoxDependencies.ItemIndex := IndexItem;
    end;

    CheckListBoxDependencies.Items.EndUpdate;
  end;

  CheckListBoxDependenciesClick(CheckListBoxDependencies);
  CheckListBoxDependencies.SetFocus;
end;

procedure TfrmOptions.ButtonBrowsePathsClick(Sender: TObject);
var
  IndexItem: Integer;
  TextPath: string;
begin
  if OpenDialogPath.Execute then
  begin
    TextPath := OpenDialogPath.FileName;
    TextPath := ExtractFilePath(TextPath) + '*' + ExtractFileExt(TextPath);
    TextPath := GetRelativePath(TextPath, IncludeTrailingBackslash(Configuration.DirGame));

    IndexItem := CheckListBoxPaths.Items.IndexOf(TextPath);
    if IndexItem < 0 then
      IndexItem := CheckListBoxPaths.Items.Add(TextPath);

    CheckListBoxPaths.Checked[IndexItem] := True;
    CheckListBoxPaths.ItemIndex := IndexItem;
  end;

  CheckListBoxPaths.SetFocus;
end;

function TfrmOptions.GetIndexPerform: TOptionsPerformindex;
begin
  if PageControlPerform.ActivePage = TabSheetPerformSuccess
    then Result := perfSuccess
    else Result := perfFailure;
end;

procedure TfrmOptions.CheckBoxPerformWindowFrontClick(Sender: TObject);
begin
  if CheckBoxPerformWindowFront.Checked then
  begin
    CheckBoxPerformWindowClose.Checked := False;
    OptionsPerform[GetIndexPerform].Window := perfWindowFront;
  end
  else begin
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
  else begin
    OptionsPerform[GetIndexPerform].Window := perfWindowNone;
  end;
end;

procedure TfrmOptions.PageControlPerformChange(Sender: TObject);
begin
  with OptionsPerform[GetIndexPerform] do
  begin
    case Window of
      perfWindowNone:
      begin
        CheckBoxPerformWindowClose.Checked := False;
        CheckBoxPerformWindowFront.Checked := False;
      end;

      perfWindowFront:  CheckBoxPerformWindowFront.Checked := True;
      perfWindowClose:  CheckBoxPerformWindowClose.Checked := True;
    end;

    EditPerformLaunch.Text := TextLaunch;
    EditPerformSound .Text := TextSound;
  end;

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
    if Length(Trim(EditPerformLaunch.Text)) = 0 then
    begin
      CheckBoxPerformLaunch.Checked := False;
      ButtonBrowsePerformLaunchClick(ButtonBrowsePerformLaunch);
    end;
  end
  else begin
    EditPerformLaunch.Text := '';
  end;
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
    if Length(Trim(EditPerformSound.Text)) = 0 then
    begin
      CheckBoxPerformSound.Checked := False;
      ButtonBrowsePerformSoundClick(ButtonBrowsePerformSound);
    end;
  end
  else begin
    EditPerformSound.Text := '';
  end;
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
  FormShortcuts.Left := Left + (Width  - FormShortcuts.Width)  div 2;
  FormShortcuts.Top  := Top  + (Height - FormShortcuts.Height) div 2;
  FormShortcuts.Configuration := Configuration;
  FormShortcuts.ShowModal;

  PanelFocusShortcuts.SetFocus;
end;

procedure TfrmOptions.ButtonShortcutExplorerClick(Sender: TObject);
var
  Registry: TRegistry;
  TextKeyFile: string;
begin
  PanelFocusShortcuts.SetFocus;

  Registry := TRegistry.Create;
  Registry.RootKey := HKEY_CLASSES_ROOT;

  try
    TextKeyFile := '';

    if Registry.OpenKey('\.uc', False) then
    begin
      TextKeyFile := Registry.ReadString('');
      Registry.CloseKey;
    end;

    if Length(TextKeyFile) = 0 then
    begin
      TextKeyFile := 'UnrealScript';

      if not Registry.OpenKey('\.uc', True) then
        raise ERegistryException.Create('Unable to create file extension key');
      Registry.WriteString('', TextKeyFile);
      Registry.CloseKey;
    end;

    if not Registry.OpenKey(Format('\%s\shell\compile', [TextKeyFile]), True) then
      raise ERegistryException.Create('Unable to create "compile" command description');
    Registry.WriteString('', 'UMake Compile');
    Registry.CloseKey;

    if not Registry.OpenKey(Format('\%s\shell\compile\command', [TextKeyFile]), True) then
      raise ERegistryException.Create('Unable to create "compile" command');
    Registry.WriteString('', Format('%s "%%1"', [GetQuotedParam(GetLongPath(ParamStr(0)))]));
    Registry.CloseKey;

    if not Registry.OpenKey(Format('\%s\shell\setup', [TextKeyFile]), True) then
      raise ERegistryException.Create('Unable to create "compile" command description');
    Registry.WriteString('', 'UMake Project Setup');
    Registry.CloseKey;

    if not Registry.OpenKey(Format('\%s\shell\setup\command', [TextKeyFile]), True) then
      raise ERegistryException.Create('Unable to create "compile" command');
    Registry.WriteString('', Format('%s /setup "%%1"', [GetQuotedParam(GetLongPath(ParamStr(0)))]));
    Registry.CloseKey;

    Application.MessageBox('The Explorer right-click menu commands have been registered.', PChar(Application.Title), MB_ICONINFORMATION);

  except
    on ERegistryException do
      Application.MessageBox('Unable to register Explorer commands. You might need administrator privileges to do this.', PChar(Application.Title), MB_ICONERROR);
  end;

  Registry.Free;
end;

procedure TfrmOptions.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  FlagFound: Boolean;
  IndexPath: Integer;
begin
  if ModalResult = mrOk then
  begin
    if TabSheetProject.TabVisible then
    begin
      FlagFound := False;

      for IndexPath := 0 to CheckListBoxPaths.Items.Count - 1 do
      begin
        if CheckListBoxPaths.Checked[IndexPath] and AnsiSameText(ExtractFileExt(CheckListBoxPaths.Items[IndexPath]), '.u') then
        begin
          FlagFound := True;
          Break;
        end;
      end;

      if not FlagFound then
      begin
        PageControl.ActivePage := TabSheetProject;
        CheckListBoxPaths.SetFocus;

        Application.MessageBox('UMake will not be able to compile your project unless you specify a search path for .u files.', PChar(Application.Title), MB_ICONERROR);  
        CanClose := False;
      end;
    end;
  end;
end;

procedure TfrmOptions.FormClose(Sender: TObject; var Action: TCloseAction);
var
  IndexPackage: Integer;
  IndexPath: Integer;
  IndexPerform: TOptionsPerformIndex;
  TextPath: string;
begin
  if ModalResult = mrOk then
  begin
    Options.RegOptDetails.Value := CheckBoxDetails.Checked;
    Options.RegOptEditor.Value := EditEditor.Text;

    for IndexPerform := Low(TOptionsPerformIndex) to High(TOptionsPerformIndex) do
    begin
      with Options.Perform[IndexPerform] do
      begin
        RegOptWindow.Value := Integer(OptionsPerform[IndexPerform].Window);
        RegOptLaunch.Value := OptionsPerform[IndexPerform].TextLaunch;
        RegOptSound .Value := OptionsPerform[IndexPerform].TextSound;
      end;
    end;

    if Assigned(Configuration) then
    begin
      Configuration.StringListPackages.Clear;
      for IndexPackage := 0 to CheckListBoxDependencies.Items.Count - 1 do
        if CheckListBoxDependencies.Checked[IndexPackage] then
          Configuration.StringListPackages.Add(CheckListBoxDependencies.Items[IndexPackage]);
      Configuration.StringListPackages.Add(Configuration.Package);

      Configuration.StringListPaths.Clear;
      for IndexPath := 0 to CheckListBoxPaths.Items.Count - 1 do
      begin
        if CheckListBoxPaths.Checked[IndexPath] then
        begin
          TextPath := CheckListBoxPaths.Items[IndexPath];
          TextPath := GetAbsolutePath(TextPath, IncludeTrailingBackslash(Configuration.DirGame));
          TextPath := GetRelativePath(TextPath, IncludeTrailingBackslash(Configuration.DirGame) + 'System\');
          TextPath := StringReplace(TextPath, '\', '/', [rfReplaceAll]);

          Configuration.StringListPaths.Add(TextPath);
        end;
      end;

      Configuration.Write;
    end;
  end;
end;

end.
