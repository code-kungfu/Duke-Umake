unit UMake.Forms.Main;

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
  Vcl.FileCtrl,

  { RTL }
  System.Classes,
  System.Math,

  { WinAPI }
  Winapi.Windows,
  Winapi.Messages,

  { UMake Libraries }
  UMake.Configuration,
  UMake.Options,

  { Misc Libraries }
  SysTools,
  RegExpr;
{$ENDREGION}

(*****************************************************************************)
(*  TInfoError
(*****************************************************************************)

type
  TInfoError = class
  private
    FTextMessageFormatted: string;
    FTextExplanation:      string;
    function GetTextMessageFormatted: string;
    function GetTextExplanation:      string;
  public
    IndexLine:   Integer;
    TextFile:    string;
    TextMessage: string;
    property TextMessageFormatted: string read GetTextMessageFormatted;
    property TextExplanation:      string read GetTextExplanation;
  end;


(*****************************************************************************)
(*  TFormMain
(*****************************************************************************)

type
  TfrmMainForm = class(TForm)
    ButtonAbort: TButton;
    ButtonDetails: TButton;
    ButtonErrorEdit: TButton;
    ButtonOptions: TButton;
    ButtonWarningEdit: TButton;
    ButtonWarningNext: TButton;
    ButtonWarningPrev: TButton;
    ImageError: TImage;
    ImageWarning: TImage;
    LabelErrorLocation: TLabel;
    LabelErrorTitle: TLabel;
    LabelWarningLocation: TLabel;
    LabelWarningNumber: TLabel;
    LabelWarningTitle: TLabel;
    PageControlDetails: TPageControl;
    ProgressBar: TProgressBar;
    RichEditError: TRichEdit;
    RichEditMessages: TRichEdit;
    RichEditWarning: TRichEdit;
    StaticTextProgress: TStaticText;
    TabSheetError: TTabSheet;
    TabSheetMessages: TTabSheet;
    TabSheetWarnings: TTabSheet;
    ButtonRebuild: TButton;
    procedure FormShow(Sender: TObject);
    procedure ButtonAbortClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonOptionsClick(Sender: TObject);
    procedure ButtonDetailsClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ButtonErrorEditClick(Sender: TObject);
    procedure ButtonWarningPrevClick(Sender: TObject);
    procedure ButtonWarningNextClick(Sender: TObject);
    procedure TabSheetWarningsResize(Sender: TObject);
    procedure TabSheetErrorResize(Sender: TObject);
  private
    Configuration: TConfiguration;
    Options: TOptions;
    IndexWarning: Integer;
    InfoError: TInfoError;
    ListInfoWarning: TList;
    FlagClosing: Boolean;
    PipedProcess: TPipedProcess;
    RegExprClass: TRegExpr;
    RegExprCompiling: TRegExpr;
    RegExprCompleted: TRegExpr;
    RegExprPackage: TRegExpr;
    RegExprParsing: TRegExpr;
    RegExprErrorCompile: TRegExpr;
    RegExprErrorParse: TRegExpr;
    RegExprWarningCompile: TRegExpr;
    RegExprWarningParse: TRegExpr;
    TextBufferPipe: string;
    TextFilePackageBackup: string;
    TextFilePackageOriginal: string;
    procedure ErrorMessageBox(TextMessage: string; OptionsMessage: Integer = MB_ICONERROR);
    procedure ErrorDetails(InfoError: TInfoError; LabelLocation: TLabel; RichEdit: TRichEdit);
    procedure PipedProcessDebug(Sender: TObject; const DebugEvent: TDebugEvent; var ContinueStatus: Cardinal);
    procedure PipedProcessOutput(Sender: TObject; const TextData: string; Pipe: TPipedOutput);
    procedure PipedProcessTerminate(Sender: TObject);
    procedure UpdateDetailsError;
    procedure UpdateDetailsWarning;
    procedure RichEditMessagesAppend(TextAppend: string; ColorAppend: TColor);
  public
    procedure Startup;
  end;

var
  frmMainForm: TfrmMainForm;

implementation

{$REGION '-> Local Uses Clause <-'}
uses
  { RTL }
  System.IOUtils,
  System.SysUtils,

  { UMake Forms }
  UMake.Forms.Options,
  UMake.Forms.Launcher, System.UITypes;
{$ENDREGION}

{$R *.DFM}

(*****************************************************************************)
(*  TInfoError
(*****************************************************************************)

function TInfoError.GetTextMessageFormatted: string;
begin
  if FTextMessageFormatted.Length = 0 then
  begin
    FTextMessageFormatted := TextMessage;
    FTextMessageFormatted := ReplaceRegExpr('\s+', FTextMessageFormatted, ' ');
    FTextMessageFormatted := ReplaceRegExpr('^''|''$', FTextMessageFormatted, string.Empty);
    FTextMessageFormatted := ReplaceRegExpr('(\W)''|''(\W)', FTextMessageFormatted, '$1$2', True);
    FTextMessageFormatted := ReplaceRegExpr('([^.])$', FTextMessageFormatted, '$1.',  True);
  end;
  Result := FTextMessageFormatted;
end;

function TInfoError.GetTextExplanation: string;
var
  LIndexCharSeparator: Integer;
  LRegExprExplanation: TRegExpr;
  LTextLineExplanation: string;
  LTextFileExplanations: string;
  LStringListExplanations: TStringList;
begin
  LStringListExplanations := TStringList.Create;
  try
    if FTextExplanation.Length = 0 then
    begin
      if not Assigned(LStringListExplanations) then
      begin
        LTextFileExplanations := ChangeFileExt(ParamStr(0), 'Explanations.txt');

        if TFile.Exists(LTextFileExplanations) then
          LStringListExplanations.LoadFromFile(LTextFileExplanations);
      end;

      LRegExprExplanation := TRegExpr.Create;
      try
        for var LIndexExplanation: Integer := 0 to LStringListExplanations.Count - 1 do
        begin
          LTextLineExplanation := LStringListExplanations[LIndexExplanation];

          LIndexCharSeparator := Pos(#9, LTextLineExplanation);
          if LIndexCharSeparator = 0 then
            Continue;

          try
            LRegExprExplanation.Expression := Copy(LTextLineExplanation, 1, LIndexCharSeparator - 1);

            if LRegExprExplanation.Exec(TextMessageFormatted) then
            begin
              FTextExplanation := Copy(LTextLineExplanation, LIndexCharSeparator + 1, Length(LTextLineExplanation));
              FTextExplanation := ReplaceRegExpr('\\n', FTextExplanation, sLineBreak);
              FTextExplanation := LRegExprExplanation.Substitute(FTextExplanation);
              Break;
            end;
          except
            on ERegExpr do;
          end;
        end;
      finally
        LRegExprExplanation.Free;
      end;

      if Length(FTextExplanation) = 0 then
        FTextExplanation := 'Sorry, no further explanation available.';
    end;

    Result := FTextExplanation;
  finally
    LStringListExplanations.Free;
  end;
end;

(*****************************************************************************)
(*  TFormMain
(*****************************************************************************)

procedure TfrmMainForm.FormCreate(Sender: TObject);
begin
  Options := TOptions.Create;

  ImageError.Picture.Icon.Handle := LoadIcon(0, IDI_HAND);
  ImageWarning.Picture.Icon.Handle := LoadIcon(0, IDI_EXCLAMATION);

  PageControlDetails.ActivePage := TabSheetMessages;
  TabSheetError.TabVisible := False;
  TabSheetWarnings.TabVisible := False;

  StaticTextProgress.DoubleBuffered := True;
  ProgressBar.DoubleBuffered := True;
  PageControlDetails.DoubleBuffered := True;

  Constraints.MaxHeight := Constraints.MinHeight;
end;

procedure TfrmMainForm.Startup;
var
  LCountFiles: Integer;
  LDateTimePackage: TDateTime;
  LDateTimeSource: TDateTime;
  LFlagAuto: Boolean;
  LFlagSetup: Boolean;
  LFlagUpdated: Boolean;
  LIndexProject: Integer;
  LResultFindDir: Integer;
  LResultFindFile: Integer;
  LSearchRecDir: TSearchRec;
  LSearchRecFile: TSearchRec;
  LTextDirGame: string;
  LTextDirPackage: string;
  LTextDirPackageLatest: string;
  LTextFilePackage: string;
  LTextFileSource: string;
  LTextPackage: string;
begin
  LFlagAuto := False;
  LFlagSetup := False;
  LTextFileSource := string.Empty;

  for var LIndexParam: Integer := 1 to ParamCount do
  begin
    if SameText(ParamStr(LIndexParam), '/setup') then
      LFlagSetup := True
    else
    if SameText(ParamStr(LIndexParam), '/auto') then
      LFlagAuto := True
    else
    if (ParamStr(LIndexParam).Length > 0) and (ParamStr(LIndexParam)[1] <> '/') then
    begin
      if LTextFileSource.Length = 0 then
      begin
        LTextFileSource := GetLongPath(ParamStr(LIndexParam));
        if TDirectory.Exists(LTextFileSource) then
          LTextFileSource := IncludeTrailingBackslash(LTextFileSource);
      end;
    end;
  end;

  if LTextFileSource.Length = 0 then
  begin
    if LFlagSetup then
    begin
      frmOptions.Options := Options;
      frmOptions.ShowModal;
      Self.Close;
    end
    else
    if LFlagAuto then
    begin
      MessageDlg('Specify the base directory of a game along with the /auto switch to automatically compile the most recently modified project for that game.', TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], 0);
      Self.Close;
    end
    else
    begin
      frmLauncher.Options := Options;
      if frmLauncher.ShowModal = mrOk then
        Configuration := frmLauncher.Configuration
      else
        Self.Close;
    end;
  end
  else
  begin
    if LFlagAuto then
    begin
      LTextDirGame := GetLongPath(LTextFileSource);
      LTextFileSource := string.Empty;

      if TFile.Exists(TPath.Combine(LTextDirGame, 'System\ucc.exe')) then
      begin
        LDateTimeSource := 0.0;
        LTextDirPackageLatest := string.Empty;
        try
          LResultFindDir := FindFirst(IncludeTrailingBackslash(LTextDirGame) + '*', faDirectory, LSearchRecDir);
          while LResultFindDir = 0 do
          begin
            LTextDirPackage := IncludeTrailingBackslash(LTextDirGame) + LSearchRecDir.Name + '\';

            if TDirectory.Exists(TPath.Combine(LTextDirPackage, 'Classes')) then
            begin
              LResultFindFile := FindFirst(LTextDirPackage + 'Classes\*.uc', faAnyFile, LSearchRecFile);
              while LResultFindFile = 0 do
              begin
                if LDateTimeSource < FileDateToDateTime(LSearchRecFile.Time) then
                begin
                  LDateTimeSource := FileDateToDateTime(LSearchRecFile.Time);
                  LTextDirPackageLatest := LTextDirPackage;
                end;
                LResultFindFile := FindNext(LSearchRecFile);
              end;
              FindClose(LSearchRecFile);
            end;

            LResultFindDir := FindNext(LSearchRecDir);
          end;
          FindClose(LSearchRecDir);
        except
          on EInOutError do;
        end;

        if LTextDirPackageLatest.Length = 0 then
        begin
          MessageDlg('No project directories with source files found in game directory.', TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], 0);
          Self.Close;
        end
        else
          LTextFileSource := LTextDirPackageLatest;
      end
      else
      begin
        MessageDlg('Invalid game directory given with /auto switch.', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
        Self.Close;
      end;
    end;

    if LTextFileSource.Length > 0 then
    begin
      LTextDirPackage := ExcludeTrailingBackslash(ExtractFilePath(LTextFileSource));
      if SameText(ExtractFileName(LTextDirPackage), 'Classes') then
        LTextDirPackage := ExcludeTrailingBackslash(ExtractFilePath(LTextDirPackage));

      try
        Configuration := TConfiguration.Create(ExtractFileName(LTextDirPackage), ExtractFilePath(LTextDirPackage));
      except
        on EConfigurationGameDirNotFound do
          ErrorMessageBox('Game directory not found for the given file.');

        on EConfigurationGameDirInvalid do
          ErrorMessageBox('UnrealScript project directories must be located directly below the game base directory.');

        on EConfigurationPackageDirNotFound do
          ErrorMessageBox('Package directory not found for the given file.');

        on EConfigurationPackageDirInvalid do
          ErrorMessageBox('UnrealScript project directories must contain a "Classes" subdirectory for UnrealScript source files.');
      end;
    end;
  end;

  if Assigned(Configuration) then
  begin
    try
      Configuration.Read;
    except
      on EConfigurationGameIniNotFound do
      begin
        ErrorMessageBox('Unable to find the main game configuration file.');
        Self.Close;
        Exit;
      end;
    end;

    if LFlagSetup then
    begin
      frmOptions.Configuration := Configuration;
      frmOptions.Options := Options;
      frmOptions.ShowModal;
      Self.Close;
    end
    else
    begin
      Options.RegOptProjects.Value := Configuration.DirPackage;
      LIndexProject := 0;

      while LIndexProject < Options.RegOptProjects.ItemCount do
      begin
        if CompareText(Configuration.DirPackage, Options.RegOptProjects[LIndexProject].Value) <= 0 then
          Break;

        Inc(LIndexProject);
      end;

      if (LIndexProject >= Options.RegOptProjects.ItemCount) or not AnsiSameText(Configuration.DirPackage, Options.RegOptProjects[LIndexProject].Value) then
      begin
        Options.RegOptProjects.ItemInsert(LIndexProject);
        Options.RegOptProjects[LIndexProject].Value := Configuration.DirPackage;
      end;

      if not FileExists(IncludeTrailingBackslash(Configuration.DirGame) + Configuration.Package + '\make.ini') then
      begin
        frmOptions.Configuration := Configuration;
        frmOptions.Options := Options;

        if frmOptions.ShowModal <> mrOk then
        begin
          Self.Close;
          Exit;
        end;
      end;

      LFlagUpdated := False;

      for var LIndexPackage: Integer := 0 to Configuration.StringListPackages.Count - 1 do
      begin
        LTextPackage := Configuration.StringListPackages[LIndexPackage];
        LTextFilePackage := Configuration.FindFilePackage(LTextPackage);

        if SameText(LTextPackage, Configuration.Package) or (LTextFilePackage.Length = 0) then
        begin
          LCountFiles := 0;
          try
            if TFile.Exists(LTextFilePackage) then
              LDateTimePackage := FileDateToDateTime(FileAge(LTextFilePackage))
            else
              LDateTimePackage := 0.0;

            LResultFindFile := FindFirst(IncludeTrailingBackslash(Configuration.DirGame) + LTextPackage + '\Classes\*.uc', faAnyFile, LSearchRecFile);
            while LResultFindFile = 0 do
            begin
              LDateTimeSource := FileDateToDateTime(LSearchRecFile.Time);
              if LDateTimeSource > LDateTimePackage then
                LFlagUpdated := True;

              Inc(LCountFiles);
              LResultFindFile := FindNext(LSearchRecFile);
            end;
            FindClose(LSearchRecFile);
          except
            on EInOutError do;
          end;

          if LCountFiles = 0 then
          begin
            ErrorMessageBox(Format('No valid project directory found for package %s (which requires recompilation).', [LTextPackage]));
            Close;
            Exit;
          end;

          ProgressBar.Max := ProgressBar.Max + LCountFiles * 2;
        end
        else
        begin
          if not AnsiSameText(ExtractFileExt(LTextFilePackage), '.u') then
          begin
            ErrorMessageBox(Format('Invalid dependency on non-code package %s.', [ExtractFileName(LTextFilePackage)]));
            Self.Close;
            Exit;
          end;
          ProgressBar.Max := ProgressBar.Max + 1;
        end;
      end;

      if LFlagUpdated or (MessageBox(Application.Handle, PChar(Format('Your project, %s, seems to be up to date. Compile anyway?', [Configuration.Package])), PChar(Application.Title), MB_ICONINFORMATION + MB_YESNO) = IDYES) then
        Self.Show
      else
        Self.Close;
    end;
  end
  else
    Self.Close;
end;

procedure TfrmMainForm.ErrorMessageBox(TextMessage: string; OptionsMessage: Integer);
begin
  Application.MessageBox(PChar(TextMessage), PChar(Application.Title), OptionsMessage);
end;

procedure TfrmMainForm.ErrorDetails(InfoError: TInfoError; LabelLocation: TLabel; RichEdit: TRichEdit);
var
  LRegExprParagraph: TRegExpr;
  LStringListParagraphs: TStringList;
begin
  if Length(InfoError.TextFile) = 0 then
    LabelLocation.Caption := 'Occurred before compilation'
  else
  if InfoError.IndexLine = 0 then
    LabelLocation.Caption := ExtractFileName(InfoError.TextFile)
  else
    LabelLocation.Caption := Format('%s (line %d)', [ExtractFileName(InfoError.TextFile), InfoError.IndexLine]);

  RichEdit.Lines.BeginUpdate;
  RichEdit.Clear;

  RichEdit.SelAttributes.Size := RichEditError.Font.Size;
  RichEdit.SelAttributes.Style := [];
  RichEdit.Paragraph.FirstIndent := 2;

  RichEdit.SelText := InfoError.TextMessageFormatted + sLineBreak;

  if InfoError.TextExplanation.Length > 0 then
  begin
    RichEdit.SelAttributes.Size := 6;
    RichEdit.SelText := sLineBreak;
    RichEdit.SelAttributes.Size := RichEditError.Font.Size;
    RichEdit.SelAttributes.Style := [fsBold];
    RichEdit.SelText := 'Explanation' + sLineBreak;
    RichEdit.SelAttributes.Style := [];

    LStringListParagraphs := TStringList.Create;
    LRegExprParagraph := TRegExpr.Create;
    try
      LRegExprParagraph.Expression := '(\r?\n)+';
      LRegExprParagraph.Split(InfoError.TextExplanation, LStringListParagraphs);

      for var LIndexParagraph: Integer := 0 to LStringListParagraphs.Count - 1 do
      begin
        RichEdit.SelAttributes.Size := 3;
        RichEdit.SelText := sLineBreak;
        RichEdit.SelAttributes.Size := RichEditError.Font.Size;
        RichEdit.SelText := LStringListParagraphs[LIndexParagraph];
        if LIndexParagraph < LStringListParagraphs.Count - 1 then
          RichEdit.SelText := sLineBreak;
      end;
      RichEdit.Perform(WM_VSCROLL, SB_TOP, 0);
    finally
      LStringListParagraphs.Free;
      LRegExprParagraph.Free;
    end;
  end;

  RichEditError.Lines.EndUpdate;

  if ButtonDetails.Enabled then
    ButtonDetailsClick(ButtonDetails);
end;

procedure TfrmMainForm.FormShow(Sender: TObject);
var
  LTextCommand: string;
  LTextDirSystem: string;
begin
  TextFilePackageOriginal := Configuration.FindFilePackage(Configuration.Package);

  if TextFilePackageOriginal.Length > 0 then
  begin
    TextFilePackageBackup := TextFilePackageOriginal + '.backup';

    if TFile.Exists(TextFilePackageBackup) then
      TFile.Delete(TextFilePackageBackup);

    while not RenameFile(TextFilePackageOriginal, TextFilePackageBackup) do
    begin
      if Application.MessageBox(PChar(Format('UMake is unable to rename %s before recompiling it. Please make sure that the file isn''t loaded in UnrealEd or any other application at the moment.', [ExtractFileName(TextFilePackageOriginal)])), PChar(Application.Title), MB_ICONERROR + MB_RETRYCANCEL) <> IDRETRY then
      begin
        Self.Close;
        Exit;
      end;
    end;
  end;

  ButtonAbort.Caption := '&Abort';
  ButtonAbort.Enabled := False;
  ButtonAbort.Cancel  := False;
  RichEditMessages.Paragraph.FirstIndent := 2;
  RichEditMessages.Paragraph.LeftIndent  := 6;
  RegExprClass := TRegExpr.Create;
  RegExprPackage := TRegExpr.Create;
  RegExprParsing := TRegExpr.Create;
  RegExprCompiling := TRegExpr.Create;
  RegExprCompleted := TRegExpr.Create;
  RegExprErrorCompile := TRegExpr.Create;
  RegExprErrorParse := TRegExpr.Create;
  RegExprWarningCompile := TRegExpr.Create;
  RegExprWarningParse := TRegExpr.Create;

  RegExprClass.Expression := '^([^.]+\.)?(\w+)';
  RegExprPackage.Expression := '^-+\s*(\w+)(\s*-\s*(\w+))?';
  RegExprParsing.Expression := '^Parsing\s+(\w+)';
  RegExprCompiling.Expression := '^Compiling\s+(\w+)';
  RegExprCompleted.Expression := '^(Success|Failure) - \d+ error\(s\)';
  RegExprErrorCompile.Expression := '^([A-Za-z]:\\.*?\\Classes\\\w+\.uc)\s*\((\d+)\)\s*:\s*Error,\s*(.*)';
  RegExprErrorParse.Expression := '^Script vs. class name mismatch \((([^/]+))/[^)]+\)|^Bad class definition|^Superclass \S+ of class ((\S+)) not found|^([^:]+: )Unknown property|^ObjectProperty ([^.]+\.[^.]+\.)';
  RegExprWarningCompile.Expression := '^([A-Za-z]:\\.*?\\Classes\\\w+\.uc)\s*\((\d+)\)\s*:\s*ExecWarning,\s*(.*)';
  RegExprWarningParse.Expression := '^Failed loading\s+.*';
  PageControlDetails.ActivePage := TabSheetMessages;
  TabSheetError.TabVisible := False;
  TabSheetWarnings.TabVisible := False;
  InfoError := TInfoError.Create;
  ListInfoWarning := TList.Create;
  Configuration.Write;
  LTextDirSystem := IncludeTrailingBackslash(Configuration.DirGame) + 'System';

  LTextCommand := Format('%s make -fixcompat -silent ini=%s',
    [GetQuotedParam(IncludeTrailingBackslash(LTextDirSystem) + 'ucc.exe'),
     GetQuotedParam(GetRelativePath(IncludeTrailingBackslash(Configuration.DirPackage) + 'make.ini', IncludeTrailingBackslash(LTextDirSystem)))]);

  ProgressBar.Position := 0;
  PipedProcess := TPipedProcess.Create;
  PipedProcess.Directory := LTextDirSystem;
  PipedProcess.Command := LTextCommand;
  PipedProcess.OnDebug := PipedProcessDebug;
  PipedProcess.OnOutput := PipedProcessOutput;
  PipedProcess.OnTerminate := PipedProcessTerminate;
  PipedProcess.Debug;

  if Options.RegOptDetails.Value and ButtonDetails.Enabled then
    ButtonDetailsClick(ButtonDetails);

  StaticTextProgress.SetFocus;
end;


procedure TfrmMainForm.PipedProcessDebug(Sender: TObject; const DebugEvent: TDebugEvent; var ContinueStatus: Cardinal);
begin
  // nothing
end;

procedure TfrmMainForm.PipedProcessOutput(Sender: TObject;
                                          const TextData: string;
                                          Pipe: TPipedOutput);

  function FormatError(const ATextType: string; const AInfoError: TInfoError): string;
  begin
    Result := Format('%s in %s (%d): %s', [ATextType, ExtractFileName(AInfoError.TextFile),
                                                                      AInfoError.IndexLine,
                                                                      AInfoError.TextMessage]);
  end;
var
  LColorLine: TColor;
  LIndexCharSeparator: Integer;
  LIndexCharSeparatorCR: Integer;
  LIndexCharSeparatorLF: Integer;
  LInfoWarning: TInfoError;
  LTextLine: string;
begin
  if not FlagClosing then
    ButtonAbort.Enabled := True;

  RichEditMessages.Lines.BeginUpdate;

  TextBufferPipe := TextBufferPipe + TextData;
  while Length(TextBufferPipe) > 0 do
  begin
    LIndexCharSeparatorCR := Pos(#13, TextBufferPipe);
    LIndexCharSeparatorLF := Pos(#10, TextBufferPipe);

    if LIndexCharSeparatorCR = Length(TextBufferPipe) then
      LIndexCharSeparatorCR := 0;

    if LIndexCharSeparatorCR = 0 then
      LIndexCharSeparator := LIndexCharSeparatorLF
    else
    if LIndexCharSeparatorLF = 0 then
      LIndexCharSeparator := LIndexCharSeparatorCR
    else
    begin
      if LIndexCharSeparatorCR < LIndexCharSeparatorLF - 1 then
        LIndexCharSeparator := LIndexCharSeparatorCR
      else
        LIndexCharSeparator := LIndexCharSeparatorLF;
    end;

    if LIndexCharSeparator = 0 then
      Break;

    LTextLine := TrimRight(Copy(TextBufferPipe, 1, LIndexCharSeparator));
    Delete(TextBufferPipe, 1, LIndexCharSeparator);

    LColorLine := RichEditMessages.Font.Color;

    if RegExprPackage.Exec(LTextLine) then
    begin
      LTextLine := Format('----- %s', [RegExprPackage.Match[1]]);
      if RegExprPackage.SubExprMatchCount > 1 then
        LTextLine := LTextLine + Format(' (%s)', [RegExprPackage.Match[3]]);

      if not FlagClosing then
      begin
        if ProgressBar.Position < ProgressBar.Max then
          ProgressBar.StepIt;

        StaticTextProgress.Caption := Format('Reading %s', [RegExprPackage.Match[1]]);
      end;
    end
    else
    if RegExprParsing.Exec(LTextLine) then
    begin
      if not FlagClosing then
      begin
        if ProgressBar.Position < ProgressBar.Max then
          ProgressBar.StepIt;

        StaticTextProgress.Caption := Format('Parsing %s', [RegExprParsing.Match[1]]);
      end;
    end
    else
    if RegExprCompiling.Exec(LTextLine) then
    begin
      if not FlagClosing then
      begin
        if ProgressBar.Position < ProgressBar.Max then
          ProgressBar.StepIt;

        StaticTextProgress.Caption := Format('Compiling %s', [RegExprCompiling.Match[1]]);
      end;
    end

    else
    if RegExprErrorParse.Exec(LTextLine) then
    begin
      InfoError.TextFile := string.Empty;
      InfoError.TextMessage := LTextLine;
      InfoError.IndexLine := 0;

      for var LIndexMatch: Integer := 1 to RegExprErrorParse.SubExprMatchCount do
      begin
        if (RegExprErrorParse.MatchLen[LIndexMatch] > 0) and RegExprClass.Exec(RegExprErrorParse.Match[LIndexMatch]) then
        begin
          Delete(InfoError.TextMessage, RegExprErrorParse.MatchPos[LIndexMatch], RegExprErrorParse.MatchLen[LIndexMatch]);
          Insert(RegExprErrorParse.Match[LIndexMatch + 1], InfoError.TextMessage, RegExprErrorParse.MatchPos[LIndexMatch]);
          InfoError.TextFile := IncludeTrailingBackslash(Configuration.DirPackage) + 'Classes\' + RegExprClass.Match[2] + '.uc';
          Break;
        end;
      end;

      LColorLine := clRed;
    end
    else
    if RegExprErrorCompile.Exec(LTextLine) then
    begin
      InfoError.TextFile := RegExprErrorCompile.Match[1];
      InfoError.TextMessage := RegExprErrorCompile.Match[3];
      InfoError.IndexLine := StrToInt(RegExprErrorCompile.Match[2]);
      LColorLine := clRed;
      LTextLine := FormatError('Error', InfoError);
    end
    else
    if RegExprWarningParse.Exec(LTextLine) then
    begin
      LInfoWarning := TInfoError.Create;
      ListInfoWarning.Add(LInfoWarning);

      LInfoWarning.TextMessage := LTextLine;
      LInfoWarning.TextFile    := '';
      LInfoWarning.IndexLine   := 0;

      LColorLine := clRed;
    end
    else
    if RegExprWarningCompile.Exec(LTextLine) then
    begin
      LInfoWarning := TInfoError.Create;
      ListInfoWarning.Add(LInfoWarning);
      LInfoWarning.TextFile := RegExprWarningCompile.Match[1];
      LInfoWarning.TextMessage := RegExprWarningCompile.Match[3];
      LInfoWarning.IndexLine := StrToInt(RegExprWarningCompile.Match[2]);
      LColorLine := clRed;
      LTextLine := FormatError('Warning', LInfoWarning);
    end
    else
    if RegExprCompleted.Exec(LTextLine) then
    begin
      StaticTextProgress.Caption := 'Finishing';
    end;

    RichEditMessagesAppend(LTextLine, LColorLine);
  end;

  RichEditMessages.SelStart := RichEditMessages.Perform(EM_GETLIMITTEXT, 0, 0);
  RichEditMessages.Perform(EM_SCROLLCARET, 0, 0);
  RichEditMessages.Lines.EndUpdate;
end;

procedure TfrmMainForm.PipedProcessTerminate(Sender: TObject);
begin
  if not FileExists(TextFilePackageOriginal) and FileExists(TextFilePackageBackup) then
    RenameFile(TextFilePackageBackup, TextFilePackageOriginal);

  if FlagClosing then
  begin
    Self.Close;
  end
  else
  begin
    if PipedProcess.ExitCode = 0 then
    begin
      ProgressBar.Position := ProgressBar.Max;
      StaticTextProgress.Caption := 'Done';

      if ListInfoWarning.Count = 0 then
      begin
        Options.PerformAction(perfSuccess, Self, Configuration);
      end
      else
      begin
        Options.PerformAction(perfFailure, Self, Configuration);
        if Visible then
        begin
          UpdateDetailsWarning;
          PageControlDetails.ActivePage := TabSheetWarnings;
        end;
      end;
    end
    else
    begin
      StaticTextProgress.Caption := 'Failed';
      Options.PerformAction(perfFailure, Self, Configuration);

      if Visible then
      begin
        if InfoError.TextMessage.Length > 0 then
        begin
          UpdateDetailsError;
          if ListInfoWarning.Count > 0 then
            UpdateDetailsWarning;

          PageControlDetails.ActivePage := TabSheetError;
        end
        else
        if ListInfoWarning.Count > 0 then
        begin
          UpdateDetailsWarning;
          PageControlDetails.ActivePage := TabSheetWarnings;
        end
        else
        begin
          if ButtonDetails.Enabled then
            ButtonDetailsClick(ButtonDetails);
        end;
      end;
    end;

    ButtonAbort.Caption := '&Close';
    ButtonAbort.Enabled := True;
    ButtonAbort.Cancel := True;
  end;
end;

procedure TfrmMainForm.RichEditMessagesAppend(TextAppend: string; ColorAppend: TColor);
begin
  RichEditMessages.SelStart := $7fffffff;
  RichEditMessages.SelAttributes.Color := ColorAppend;
  RichEditMessages.SelText := TextAppend + sLineBreak;
end;

procedure TfrmMainForm.UpdateDetailsError;
begin
  ErrorDetails(InfoError, LabelErrorLocation, RichEditError);
  ButtonErrorEdit.Enabled := Length(InfoError.TextFile) > 0;
  TabSheetError.TabVisible := True;
end;

procedure TfrmMainForm.UpdateDetailsWarning;
var
  LControlFocused: TControl;
begin
  ErrorDetails(ListInfoWarning[IndexWarning], LabelWarningLocation, RichEditWarning);
  LabelWarningNumber.Caption := Format('(%d of %d)', [IndexWarning + 1, ListInfoWarning.Count]);
  LControlFocused := ActiveControl;
  ButtonWarningPrev.Enabled := IndexWarning > 0;
  ButtonWarningNext.Enabled := IndexWarning < ListInfoWarning.Count - 1;
  if Assigned(LControlFocused) and not LControlFocused.Enabled then
    StaticTextProgress.SetFocus;

  ButtonWarningEdit.Enabled := Length(TInfoError(ListInfoWarning[IndexWarning]).TextFile) > 0;
  TabSheetWarnings.TabVisible := True;
end;

procedure TfrmMainForm.ButtonWarningPrevClick(Sender: TObject);
begin
  if IndexWarning > 0 then
  begin
    Dec(IndexWarning);
    UpdateDetailsWarning;
  end;
end;

procedure TfrmMainForm.ButtonWarningNextClick(Sender: TObject);
begin
  if IndexWarning < ListInfoWarning.Count - 1 then
  begin
    Inc(IndexWarning);
    UpdateDetailsWarning;
  end;
end;

procedure TfrmMainForm.ButtonOptionsClick(Sender: TObject);
begin
  frmOptions.Configuration := Configuration;
  frmOptions.Options := Options;
  frmOptions.ShowModal;

  if not Visible then
    Self.Close;
end;

procedure TfrmMainForm.ButtonAbortClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmMainForm.ButtonDetailsClick(Sender: TObject);
begin
  Constraints.MaxWidth  := 0;
  Constraints.MaxHeight := 0;
  ClientHeight := ClientHeight + 248;
  Constraints.MinHeight := Constraints.MinHeight + 200;
  PageControlDetails.Height := ClientHeight - PageControlDetails.Top - PageControlDetails.Left;
  PageControlDetails.Enabled := True;
  ButtonDetails.Enabled := False;
end;

procedure TfrmMainForm.ButtonErrorEditClick(Sender: TObject);
begin
  Options.PerformEdit(Configuration, InfoError.TextFile, InfoError.IndexLine);
  Self.Hide;
  Self.Close;
end;

procedure TfrmMainForm.TabSheetErrorResize(Sender: TObject);
begin
  RichEditError.Repaint;
end;

procedure TfrmMainForm.TabSheetWarningsResize(Sender: TObject);
begin
  RichEditWarning.Repaint;
end;

procedure TfrmMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Assigned(PipedProcess) and PipedProcess.Executing then
  begin
    PipedProcess.Abort;
    ButtonAbort.Enabled := False;
    StaticTextProgress.Caption := 'Aborting';
    FlagClosing := True;
    CanClose := False;
  end
  else
  begin
    CanClose := not frmOptions.Visible;
  end;
end;

procedure TfrmMainForm.FormDestroy(Sender: TObject);
begin
  Configuration.Free;
  Options.Free;
  PipedProcess.Free;
  RegExprClass.Free;
  RegExprCompiling.Free;
  RegExprCompleted.Free;
  RegExprErrorCompile.Free;
  RegExprErrorParse.Free;
  RegExprPackage.Free;
  RegExprParsing.Free;
  RegExprWarningCompile.Free;
  RegExprWarningParse.Free;
end;

end.
