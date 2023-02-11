unit UMake.Configuration;

interface

{$REGION '-> Global Uses Clause <-'}
uses
  { RTL }
  System.Classes,
  System.SysUtils,

  { VCL }
  Vcl.FileCtrl,

  { Misc Libraries }
  SysTools,
  Hashes;
{$ENDREGION}

(*****************************************************************************)
(*  TConfiguration
(*****************************************************************************)

type
  EConfiguration = class(Exception);
  EConfigurationGameDirInvalid = class(EConfiguration);
  EConfigurationGameDirNotFound = class(EConfiguration);
  EConfigurationGameIniNotFound = class(EConfiguration);
  EConfigurationPackageDirInvalid = class(EConfiguration);
  EConfigurationPackageDirNotFound = class(EConfiguration);

  TConfiguration = class
  private
    FHashFilePackage: TStringHash;
    FTextDirCacheRecord: string;
    FTextDirGame: string;
    FTextDirPackage: string;
    FTextFileIniGame: string;
    FTextFileIniPackage: string;
    FTextNamePackage: string;
    function FindIniGame: Boolean;
    function FindIniPackage: Boolean;
    procedure StringListPathsChange(Sender: TObject);
  public
    StringListPaths: TStringList;
    StringListPackages: TStringList;
    constructor Create(ATextNamePackage: string; ATextDirGame: string);
    destructor Destroy; override;
    procedure Read;
    procedure Write;
    function FindFilePackage(TextPackage: string): string;
    property Package: string read FTextNamePackage;
    property DirGame: string read FTextDirGame;
    property DirPackage: string read FTextDirPackage;
  end;

implementation

uses
  System.IOUtils;

(*****************************************************************************)
(*  TConfiguration
(*****************************************************************************)

constructor TConfiguration.Create(ATextNamePackage: string; ATextDirGame: string);
begin
  FTextNamePackage := ATextNamePackage;
  FTextDirGame := ATextDirGame;

  if not TDirectory.Exists(FTextDirGame) then
    raise EConfigurationGameDirNotFound.Create('Game directory not found');

  if not TFile.Exists(TPath.Combine(FTextDirGame, 'System\ucc.exe')) then
    raise EConfigurationGameDirInvalid.Create('Game directory does not contain valid "System" subdirectory');

  FTextDirPackage := IncludeTrailingBackslash(FTextDirGame) + FTextNamePackage;

  if not TDirectory.Exists(FTextDirPackage) then
    raise EConfigurationPackageDirNotFound.Create('Package directory not found');

  if not TDirectory.Exists(TPath.Combine(FTextDirPackage, 'Classes')) then
    raise EConfigurationPackageDirInvalid.Create('Package directory does not contain "Classes" subdirectory');

  FHashFilePackage := TStringHash.Create;
  StringListPaths := TStringList.Create;
  StringListPackages := TStringList.Create;

  StringListPaths.OnChange := StringListPathsChange;
end;

destructor TConfiguration.Destroy;
begin
  FHashFilePackage.Free;
  StringListPaths.Free;
  StringListPackages.Free;
  inherited;
end;

function TConfiguration.FindIniGame: Boolean;
var
  LFileIni: TextFile;
  LTextFileIni: string;
  LTextLineIni: string;
  LResultFind: Integer;
  LSearchRecIni: TSearchRec;
begin
  Result := False;
  LResultFind := FindFirst(IncludeTrailingBackslash(FTextDirGame) + 'Players\UMake\*.ini', faAnyFile, LSearchRecIni);

  while LResultFind = 0 do
  begin
    if not SameText(LSearchRecIni.Name, 'Default.ini') then
    begin
      LTextFileIni := IncludeTrailingBackslash(FTextDirGame) + 'Players\UMake\' + LSearchRecIni.Name;

      try
        AssignFile(LFileIni, LTextFileIni);
        Reset(LFileIni);
        Readln(LFileIni, LTextLineIni);
        CloseFile(LFileIni);

        if SameText(LTextLineIni, '[url]') then
        begin
          Result := True;
          FTextFileIniGame := LTextFileIni;
          Break;
        end;
      except
        on EInOutError do;
      end;
    end;
    LResultFind := FindNext(LSearchRecIni);
  end;

  FindClose(LSearchRecIni);
end;

function TConfiguration.FindIniPackage: Boolean;
begin
  FTextFileIniPackage := TPath.Combine(FTextDirPackage, 'make.ini');
  Result := TFile.Exists(FTextFileIniPackage);
end;

procedure TConfiguration.Read;
var
  LFileIni: TextFile;
  LIndexCharSeparator: Integer;
  LTextLine: string;
  LTextLineName: string;
  LTextLineValue: string;
  LTextSection: string;

  procedure ReadIni(TextFileIni: string);
  begin
    StringListPaths.Clear;
    StringListPackages.Clear;

    AssignFile(LFileIni, TextFileIni);
    Reset(LFileIni);

    while not Eof(LFileIni) do
    begin
      Readln(LFileIni, LTextLine);
      LTextLine := LTextLine.Trim;

      if (LTextLine.Length = 0) or (LTextLine[1] = ';') then
        Continue;

      if LTextLine[1] = '[' then
      begin
        LTextSection := Copy(LTextLine, 2, Length(LTextLine) - 2);
      end
      else
      begin
        LIndexCharSeparator := Pos('=', LTextLine);
        if LIndexCharSeparator = 0 then
          Continue;

        LTextLineName := Copy(LTextLine, 1, LIndexCharSeparator - 1);
        LTextLineValue := Copy(LTextLine, LIndexCharSeparator + 1, Length(LTextLine));

        if SameText(LTextSection, 'Core.System') then
        begin
          if SameText(LTextLineName, 'Paths') then
            StringListPaths.Add(LTextLineValue);

          if SameText(LTextLineName, 'CacheRecordPath') then
            FTextDirCacheRecord := LTextLineValue;
        end
        else
        if SameText(LTextSection, 'Editor.EditorEngine') then
        begin
          if SameText(LTextLineName, 'EditPackages') then
            StringListPackages.Add(LTextLineValue);
        end;
      end;
    end;

    CloseFile(LFileIni);
  end;

var
  LFlagFound: Boolean;
begin
  if not FindIniGame then
    raise EConfigurationGameIniNotFound.Create('Game configuration file not found');

  ReadIni(FTextFileIniGame);

  if FindIniPackage then
    ReadIni(FTextFileIniPackage);

  LFlagFound := False;
  for var LIndexPackage: Integer := 0 to StringListPackages.Count - 1 do
  begin
    if SameText(StringListPackages[LIndexPackage], FTextNamePackage) then
    begin
      LFlagFound := True;
      Break;
    end;
  end;

  if not LFlagFound then
    StringListPackages.Add(FTextNamePackage);
end;

procedure TConfiguration.Write;
var
  LStringListIni: TStringList;

  procedure InsertSettings(ATextSection, ATextName: string; AStringListSettings: TStringList);
  var
    LIndexLine: Integer;
    LIndexLineSection: Integer;
    LIndexLineSetting: Integer;
    LTextLine: string;
  begin
    ATextSection := '[' + ATextSection + ']';
    ATextName := ATextName + '=';

    LIndexLineSection := 0;
    while (LIndexLineSection < LStringListIni.Count) and not SameText(Trim(LStringListIni[LIndexLineSection]), ATextSection) do
      Inc(LIndexLineSection);

    if LIndexLineSection < LStringListIni.Count then
    begin
      LIndexLineSetting := -1;
      LIndexLine := LIndexLineSection + 1;

      while LIndexLine < LStringListIni.Count do
      begin
        LTextLine := Trim(LStringListIni[LIndexLine]);

        if (Length(LTextLine) > 0) and (LTextLine[1] = '[') then
        begin
          Break;
        end
        else
        if SameText(Copy(LTextLine, 1, Length(ATextName)), ATextName) then
        begin
          if LIndexLineSetting < 0 then
            LIndexLineSetting := LIndexLine;

          LStringListIni.Delete(LIndexLine);
        end
        else
        begin
          Inc(LIndexLine);
        end;
      end;

      if LIndexLineSetting < 0 then
      begin
        LIndexLineSetting := LIndexLine;
        while Length(Trim(LStringListIni[LIndexLineSetting - 1])) = 0 do
          Dec(LIndexLineSetting);
      end;

      for var LIndexSetting: Integer := AStringListSettings.Count - 1 downto 0 do
        LStringListIni.Insert(LIndexLineSetting, ATextName + AStringListSettings[LIndexSetting]);

    end
    else
    begin
      LStringListIni.Add(string.Empty);
      LStringListIni.Add(ATextSection);

      for var LIndexSetting: Integer := 0 to AStringListSettings.Count - 1 do
        LStringListIni.Add(ATextName + AStringListSettings[LIndexSetting]);
    end;
  end;

  procedure InsertSetting(ATextSection, ATextName, ATextSetting: string);
  var
    LStringListSetting: TStringList;
  begin
    LStringListSetting := TStringList.Create;
    try
      LStringListSetting.Add(ATextSetting);
      InsertSettings(ATextSection, ATextName, LStringListSetting);
    finally
      LStringListSetting.Free;
    end;
  end;

var
  LFlagChanged: Boolean;
  LStringListIniOriginal: TStringList;
begin
  LStringListIni := TStringList.Create;
  LStringListIniOriginal := TStringList.Create;
  try
    FindIniPackage;
    if TFile.Exists(FTextFileIniPackage) then
    begin
      LStringListIni.LoadFromFile(FTextFileIniPackage);
      LStringListIniOriginal.Assign(LStringListIni);
    end
    else
    begin
      LStringListIni.Add('; Generated by UMake');
      LStringListIni.Add(string.Empty);
      LStringListIni.Add('[Engine.Engine]');
      LStringListIni.Add('EditorEngine=Editor.EditorEngine');
      LStringListIni.Add(string.Empty);
      LStringListIni.Add('[Editor.EditorEngine]');
      LStringListIni.Add('CacheSizeMegs=32');
    end;

    InsertSettings('Core.System', 'Paths', StringListPaths);
    InsertSettings('Editor.EditorEngine', 'EditPackages', StringListPackages);

    if Length(FTextDirCacheRecord) > 0 then
      InsertSetting ('Core.System', 'CacheRecordPath', FTextDirCacheRecord);

    if LStringListIni.Count <> LStringListIniOriginal.Count then
    begin
      LFlagChanged := True;
    end
    else
    begin
      LFlagChanged := False;
      for var LIndexLine: Integer := 0 to LStringListIni.Count - 1 do
      begin
        if not SameText(LStringListIni[LIndexLine], LStringListIniOriginal[LIndexLine]) then
        begin
          LFlagChanged := True;
          Break;
        end;
      end;
    end;

    if LFlagChanged then
      LStringListIni.SaveToFile(FTextFileIniPackage);

  finally
    LStringListIniOriginal.Free;
    LStringListIni.Free;
  end;
end;

procedure TConfiguration.StringListPathsChange(Sender: TObject);
begin
  FHashFilePackage.Clear;
end;

function TConfiguration.FindFilePackage(TextPackage: string): string;
var
  LTextFilePackage: string;
begin
  if not FHashFilePackage.Exists(LowerCase(TextPackage)) then
  begin
    for var LIndexPath: Integer := 0 to StringListPaths.Count - 1 do
    begin
      LTextFilePackage := StringReplace(StringListPaths[LIndexPath], '/', '\', [rfReplaceAll]);
      LTextFilePackage := GetAbsolutePath(LTextFilePackage, IncludeTrailingBackslash(FTextDirGame) + 'System\');
      LTextFilePackage := StringReplace(LTextFilePackage, '*', TextPackage, [rfReplaceAll]);

      if TFile.Exists(LTextFilePackage) then
      begin
        FHashFilePackage[LowerCase(TextPackage)] := LTextFilePackage;
        Break;
      end;
    end;

    if not FHashFilePackage.Exists(LowerCase(TextPackage)) then
      FHashFilePackage[LowerCase(TextPackage)] := string.Empty;
  end;

  Result := FHashFilePackage[LowerCase(TextPackage)];
end;

end.
