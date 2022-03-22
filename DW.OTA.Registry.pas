unit DW.OTA.Registry;

{*******************************************************}
{                                                       }
{         TOTAL - Terrific Open Tools API Library       }
{                                                       }
{*******************************************************}

{$I DW.GlobalDefines.inc}

interface

uses
  // RTL
  System.Win.Registry, System.Classes;

type
  TBDSRegistry = class(TRegistry)
  private
    class var FCurrent: TBDSRegistry;
    class destructor DestroyClass;
    class function GetCurrent: TBDSRegistry; static;
  private
    FRootPath: string;
  protected
    function FindNextKeyIndex(const AKeys: TStrings; const AKey: string): Integer;
  public
    class property Current: TBDSRegistry read GetCurrent;
  public
    constructor Create;
    function GetUpdateVersion: Integer; // i.e. is it 10.4.0, 10.4.1, 10.4.2 etc
    function OpenSubKey(const APath: string; const ACanCreate: Boolean =  False): Boolean;
    procedure ReadKeys(const APath: string; const AKeys: TStrings); overload;
    function ReadKeys(const APath: string): TArray<string>; overload;
    function ReadSubKeyString(const APath, AName: string): string;
    function WriteSubKeyString(const APath, AName, AValue: string): Boolean;
    property RootPath: string read FRootPath;
  end;

implementation

uses
  // RTL
  System.SysUtils,
  // Windows
  Winapi.Windows,
  // DW
  DW.OTA.Helpers;

{ TBDSRegistry }

constructor TBDSRegistry.Create;
var
  LAccess: Cardinal;
begin
  LAccess := KEY_READ or KEY_WRITE;
  if TOSVersion.Architecture = TOSVersion.TArchitecture.arIntelX64 then
    LAccess := LAccess or KEY_WOW64_64KEY
  else
    LAccess := LAccess or KEY_WOW64_32KEY;
  inherited Create(LAccess);
  RootKey := HKEY_CURRENT_USER;
  FRootPath := TOTAHelper.GetRegKey;
end;

class destructor TBDSRegistry.DestroyClass;
begin
  FCurrent.Free;
end;

function TBDSRegistry.FindNextKeyIndex(const AKeys: TStrings; const AKey: string): Integer;
var
  I, LKeyIndex: Integer;
  LKeyName: string;
begin
  Result := -1;
  for I := 0 to AKeys.Count - 1 do
  begin
    LKeyName := AKeys[I];
    if LKeyName.StartsWith(AKey) and TryStrToInt(LKeyName.Substring(Length(AKey)), LKeyIndex) and (LKeyIndex > Result) then
      Result := LKeyIndex;
  end;
  if Result > -1 then
    Inc(Result);
end;

class function TBDSRegistry.GetCurrent: TBDSRegistry;
begin
  if FCurrent = nil then
    FCurrent := TBDSRegistry.Create;
  Result := FCurrent;
end;

function TBDSRegistry.GetUpdateVersion: Integer;
var
  LParts: TArray<string>;
begin
  Result := -1; // Cannot determine
  if OpenKey(FRootPath + '\InstalledUpdates', False) then
  try
    LParts := ReadString('Main Product Update').Split([' ']); // e.g. Delphi 10.4 and C++Builder 10.4 Update 2
    if Length(LParts) > 0 then
      Result := StrToIntDef(LParts[Length(LParts) - 1], -1);
  finally
    CloseKey;
  end;
end;

function TBDSRegistry.OpenSubKey(const APath: string; const ACanCreate: Boolean): Boolean;
begin
  Result := OpenKey(FRootPath + APath, ACanCreate);
end;

function TBDSRegistry.ReadKeys(const APath: string): TArray<string>;
var
  LKeys: TStrings;
begin
  LKeys := TStringList.Create;
  try
    ReadKeys(APath, LKeys);
    Result := LKeys.ToStringArray;
  finally
    LKeys.Free;
  end;
end;

function TBDSRegistry.ReadSubKeyString(const APath, AName: string): string;
begin
  Result := '';
  if OpenSubKey(APath) then
  try
    if ValueExists(AName) then
      Result := ReadString(AName);
  finally
    CloseKey;
  end;
end;

function TBDSRegistry.WriteSubKeyString(const APath, AName, AValue: string): Boolean;
begin
  Result := False;
  if OpenSubKey(APath, True) then
  try
    WriteString(AName, AValue);
    Result := True;
  finally
    CloseKey;
  end;
end;

procedure TBDSRegistry.ReadKeys(const APath: string; const AKeys: TStrings);
begin
  AKeys.Clear;
  if OpenSubKey(APath) then
  try
    GetKeyNames(AKeys);
  finally
    CloseKey;
  end;
end;

end.
