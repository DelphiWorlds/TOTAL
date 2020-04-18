unit DW.OTA.Wizard;

{*******************************************************}
{                                                       }
{         TOTAL - Terrific Open Tools API Library       }
{                                                       }
{*******************************************************}

interface

uses
  // RTL
  System.Generics.Collections, System.Classes,
  // Windows
  System.Win.Registry,
  // Design
  ToolsAPI,
  // VCL
  Vcl.Forms, Vcl.ExtCtrls;

type
  TUserRegistry = class(TRegistry)
  private
    FRootPath: string;
  protected
    function FindNextKeyIndex(const AKeys: TStrings; const AKey: string): Integer;
  public
    constructor Create;
    function OpenSubKey(const APath: string; const ACanCreate: Boolean =  False): Boolean;
    procedure ReadKeys(const APath: string; const AKeys: TStrings);
  end;

  /// <summary>
  ///  Base Wizard. Create descendants of this class to act as "sub-wizards" of your OTA Wizard
  /// </summary>
  TWizard = class(TInterfacedObject)
  private
    class var FReg: TRegistry;
    class var FEnvVars: TStrings;
    class constructor CreateClass;
    class destructor DestroyClass;
  private
    function GetEnvVars: TStrings;
  protected
    procedure ActiveFormChanged; virtual;
    procedure ConfigChanged; virtual;
    procedure FileNotification(const ANotifyCode: TOTAFileNotification; const AFileName: string); virtual;
    function GetRSVersion: string;
    procedure IDEAfterCompile(const AProject: IOTAProject; const ASucceeded, AIsCodeInsight: Boolean); virtual;
    procedure IDEStarted; virtual;
    procedure Modification; virtual;
  protected
    class property Reg: TRegistry read FReg;
  protected
    property EnvVars: TStrings read GetEnvVars;
  public
    class procedure GetEffectivePaths(const APaths: TStrings; const ABase: Boolean = False);
    class procedure GetSearchPaths(const APlatform: string; const APaths: TStrings; const AAdd: Boolean = False);
  public
    constructor Create; virtual;
  end;

  TWizardClass = class of TWizard;

  TWizardRegistry = TList<TWizardClass>;
  TWizards = TList<TWizard>;

  TOTAWizard = class;

  TOTAWizardClass = class of TOTAWizard;

  /// <summary>
  ///   Base OTA Wizard. This class manages all that's required for your add-in
  /// </summary>
  /// <remarks>
  ///   Usually, add-ins will use descendants of TIDENotifierOTAWizard, rather than of this class
  /// </remarks>
  TOTAWizard = class(TInterfacedObject, IOTAWizard)
  private
    class var FIndex: Integer;
    class var FPluginIndex: Integer;
    class var FRegistry: TWizardRegistry;
    class var FWizard: TOTAWizard;
    class var FWizards: TWizards;
    class procedure Terminate; static;
  private
    FActiveForm: TForm;
    FIsIDEStarted: Boolean;
    FIDETimer: TTimer;
    procedure CreateWizards;
    procedure DoActiveFormChanged;
    procedure IDETimerIntervalHandler(Sender: TObject);
    procedure NotifyIDEStarted;
    procedure RegisterPlugin;
  protected
    /// <summary>
    ///   Override this function with the name of your add-in
    /// </summary>
    class function GetWizardName: string; virtual;
    /// <summary>
    ///   Call RegisterSplash in the initialization section of your TOTAWizard descendants unit
    /// </summary>
    class procedure RegisterSplash;
  protected
    /// <summary>
    ///   Called when the active form of the IDE changes
    /// </summary>
    procedure ActiveFormChanged; virtual;
    /// <summary>
    ///   Call ConfigChanged to notify the "sub-wizards" that the configuration has changed
    /// </summary>
    procedure ConfigChanged;
    /// <summary>
    ///   Call FileNotification to notify the "sub-wizards" of the TOTAFileNotification
    /// </summary>
    procedure FileNotification(const ANotifyCode: TOTAFileNotification; const AFileName: string);
    function GetWizardPluginName: string;
    /// <summary>
    ///   Override this function with the description of your add-in
    /// </summary>
    function GetWizardDescription: string; virtual;
    procedure IDEAfterCompile(const AProject: IOTAProject; const ASucceeded, AIsCodeInsight: Boolean);
    /// <summary>
    ///   Override this function to respond when the IDE has started
    /// </summary>
    procedure IDEStarted; virtual;
    /// <summary>
    ///   Override this function to respond when the IDE has stopped
    /// </summary>
    procedure IDEStopped; virtual;
    /// <summary>
    ///   Override this function to take advantage of the IDE timer
    /// </summary>
    procedure IDETimer; virtual;
    /// <summary>
    ///   Call Modification to notify the "sub-wizards" that a modification has occurred
    /// </summary>
    procedure Modification;
    /// <summary>
    ///   Override this function to respond when all the "sub-wizards" have been created
    /// </summary>
    procedure WizardsCreated; virtual;
    { IOTANotifier }
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;
    { IOTAWizard }
    procedure Execute; virtual;
    /// <summary>
    ///   Override GetIDString with a unique id for your add-in (e.g. com.mydomain.myexpert)
    /// </summary>
    function GetIDString: string; virtual;
    /// <summary>
    ///   Override GetName with a name for your add-in
    /// </summary>
    function GetName: string; virtual;
    function GetState: TWizardState;
    /// <summary>
    ///   Provides class-based access to the instance of the add-in
    /// </summary>
    class property Wizard: TOTAWizard read FWizard;
  public
    /// <summary>
    ///   Override this function if necessary to provide the add-in's version (default is Major.Minor.Release)
    /// </summary>
    class function GetWizardVersion: string; virtual;
    /// <summary>
    ///   Call InitializeWizard from the function named as WizardEntryPoint that is exported by your add-in
    /// </summary>
    /// <remarks>
    ///   Refer to the export section at the end of the TotalDemo.OTAWizard unit
    /// </remarks>
    class function InitializeWizard(const Services: IBorlandIDEServices; RegisterProc: TWizardRegisterProc;
      var TerminateProc: TWizardTerminateProc; const AWizardClass: TOTAWizardClass): Boolean;
    /// <summary>
    ///   Call RegisterWizard to register a "sub-wizard" that is managed by the add-in
    /// </summary>
    class procedure RegisterWizard(const AWizardClass: TWizardClass);
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure AfterConstruction; override;
  end;

implementation

uses
  // RTL
  System.SysUtils,
  // Windows
  Winapi.Windows,
  // DW
  DW.OTA.Helpers, DW.OSDevice;

function GetEnvironmentVariable(const AName: string): string;
const
  BufSize = 1024;
var
  Len: Integer;
  Buffer: array[0..BufSize - 1] of Char;
begin
  Result := '';
  Len := Winapi.Windows.GetEnvironmentVariable(PChar(AName), @Buffer, BufSize);
  if Len < BufSize then
    SetString(Result, PChar(@Buffer), Len)
  else
  begin
    SetLength(Result, Len - 1);
    Winapi.Windows.GetEnvironmentVariable(PChar(AName), PChar(Result), Len);
  end;
end;

{ TUserRegistry }

constructor TUserRegistry.Create;
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

procedure TUserRegistry.ReadKeys(const APath: string; const AKeys: TStrings);
begin
  AKeys.Clear;
  if OpenSubKey(APath) then
  try
    GetKeyNames(AKeys);
  finally
    CloseKey;
  end;
end;

function TUserRegistry.OpenSubKey(const APath: string; const ACanCreate: Boolean =  False): Boolean;
begin
  Result := OpenKey(FRootPath + APath, ACanCreate);
end;

function TUserRegistry.FindNextKeyIndex(const AKeys: TStrings; const AKey: string): Integer;
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

{ TWizard }

constructor TWizard.Create;
begin
  inherited;
  //
end;

class constructor TWizard.CreateClass;
begin
  FReg := TUserRegistry.Create;
  FEnvVars := TStringList.Create;
end;

class destructor TWizard.DestroyClass;
begin
  FReg.Free;
  FEnvVars.Free;
end;

procedure TWizard.FileNotification(const ANotifyCode: TOTAFileNotification; const AFileName: string);
begin
  //
end;

function TWizard.GetEnvVars: TStrings;
begin
  GetEnvironmentVars(FEnvVars, False);
  Result := FEnvVars;
end;

function TWizard.GetRSVersion: string;
begin
  Result := GetEnvironmentVariable('ProductVersion');
end;

class procedure TWizard.GetEffectivePaths(const APaths: TStrings; const ABase: Boolean = False);
var
  LPlatform: string;
  LProject: IOTAProject;
begin
  LProject := TOTAHelper.GetActiveProject;
  if LProject <> nil then
  begin
    TOTAHelper.GetProjectActiveEffectivePaths(LProject, APaths, ABase);
    LPlatform := LProject.CurrentPlatform;
    if LPlatform.Equals('Android') then
      LPlatform := 'Android32';
    GetSearchPaths(LPlatform, APaths, True);
    TOTAHelper.ExpandPaths(APaths, LProject);
  end;
end;

class procedure TWizard.GetSearchPaths(const APlatform: string; const APaths: TStrings; const AAdd: Boolean = False);
var
  LPaths: TStrings;
begin
  if Reg.OpenKey(TOTAHelper.GetRegKey + '\Library\' + APlatform, False) then
  try
    LPaths := TStringList.Create;
    try
      LPaths.Text := StringReplace(Reg.GetDataAsString('Search Path'), ';', #13#10, [rfReplaceAll]);
      if AAdd then
        APaths.AddStrings(LPaths)
      else
        APaths.Assign(LPaths);
    finally
      LPaths.Free;
    end;
  finally
    Reg.CloseKey;
  end;
end;

procedure TWizard.Modification;
begin
  //
end;

procedure TWizard.ActiveFormChanged;
begin
  //
end;

procedure TWizard.ConfigChanged;
begin
  //
end;

procedure TWizard.IDEAfterCompile(const AProject: IOTAProject; const ASucceeded, AIsCodeInsight: Boolean);
begin
  //
end;

procedure TWizard.IDEStarted;
begin
  //
end;

{ TOTAWizard }

constructor TOTAWizard.Create;
begin
  inherited;
  {$IFDEF DEBUG}
  TOTAHelper.IsDebug := True;
  {$ENDIF}
  RegisterPlugin;
  FIDETimer := TTimer.Create(nil);
  FIDETimer.Interval := 50;
  FIDETimer.OnTimer := IDETimerIntervalHandler;
  FIDETimer.Enabled := True;
end;

destructor TOTAWizard.Destroy;
begin
  if FPluginIndex > 0 then
    (BorlandIDEServices as IOTAAboutBoxServices).RemovePluginInfo(FPluginIndex);
  FIDETimer.Free;
  inherited;
end;

procedure TOTAWizard.ConfigChanged;
var
  LWizard: TWizard;
begin
  if FWizards <> nil then
  begin
    for LWizard in FWizards do
      LWizard.ConfigChanged;
  end;
end;

procedure TOTAWizard.IDEAfterCompile(const AProject: IOTAProject; const ASucceeded, AIsCodeInsight: Boolean);
var
  LWizard: TWizard;
begin
  if FWizards <> nil then
  begin
    for LWizard in FWizards do
      LWizard.IDEAfterCompile(AProject, ASucceeded, AIsCodeInsight);
  end;
end;

procedure TOTAWizard.IDEStarted;
begin
  //
end;

procedure TOTAWizard.IDEStopped;
begin
  //
end;

procedure TOTAWizard.IDETimer;
begin
  //
end;

procedure TOTAWizard.IDETimerIntervalHandler(Sender: TObject);
var
  LMainForm: TComponent;
begin
  if not Application.Terminated then
  begin
    LMainForm := Application.FindComponent('AppBuilder');
    if not FIsIDEStarted and (LMainForm is TForm) and TForm(LMainForm).Visible then
      NotifyIDEStarted;
    if Screen.ActiveForm <> FActiveForm then
    begin
      FActiveForm := Screen.ActiveForm;
      DoActiveFormChanged;
    end;
    IDETimer;
  end
  else
    IDEStopped;
end;

procedure TOTAWizard.DoActiveFormChanged;
var
  LWizard: TWizard;
begin
  ActiveFormChanged;
  if FWizards <> nil then
  begin
    for LWizard in FWizards do
      LWizard.ActiveFormChanged;
  end;
end;

procedure TOTAWizard.NotifyIDEStarted;
var
  LWizard: TWizard;
begin
  FIsIDEStarted := True;
  IDEStarted;
  if FWizards <> nil then
  begin
    for LWizard in FWizards do
      LWizard.IDEStarted;
  end;
end;

procedure TOTAWizard.ActiveFormChanged;
begin
  //
end;

procedure TOTAWizard.AfterConstruction;
begin
  inherited;
  CreateWizards;
end;

procedure TOTAWizard.CreateWizards;
var
  LWizardClass: TWizardClass;
begin
  if FRegistry <> nil then
  begin
    for LWizardClass in FRegistry do
      FWizards.Add(LWizardClass.Create);
    WizardsCreated;
  end;
end;

procedure TOTAWizard.WizardsCreated;
begin
  //
end;

procedure TOTAWizard.AfterSave;
begin
  //
end;

procedure TOTAWizard.BeforeSave;
begin
  //
end;

procedure TOTAWizard.Destroyed;
begin
  //
end;

procedure TOTAWizard.Modification;
var
  LWizard: TWizard;
begin
  if FWizards <> nil then
  begin
    for LWizard in FWizards do
      LWizard.Modification;
  end;
end;

procedure TOTAWizard.Modified;
begin
  //
end;

procedure TOTAWizard.Execute;
begin
  //
end;

procedure TOTAWizard.FileNotification(const ANotifyCode: TOTAFileNotification; const AFileName: string);
var
  LWizard: TWizard;
begin
  if FWizards <> nil then
  begin
    for LWizard in FWizards do
      LWizard.FileNotification(ANotifyCode, AFileName);
  end;
end;

function TOTAWizard.GetIDString: string;
begin
  Result := '';
end;

function TOTAWizard.GetName: string;
begin
  Result := '';
end;

function TOTAWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

function TOTAWizard.GetWizardDescription: string;
begin
  Result := '';
end;

class function TOTAWizard.GetWizardName: string;
begin
  Result := '';
end;

function TOTAWizard.GetWizardPluginName: string;
begin
  Result := GetName + ' ' + GetWizardVersion;
end;

class function TOTAWizard.GetWizardVersion: string;
var
  LBuild: string;
begin
  Result := TOSDevice.GetPackageVersion;
  if TOSDevice.IsBeta then
  begin
    LBuild := TOSDevice.GetPackageBuild;
    if not LBuild.Equals('0') then
      Result := Format('%s (Beta %s)', [Result, LBuild])
    else
      Result := Format('%s (Beta)', [Result]);
  end;
end;

procedure TOTAWizard.RegisterPlugin;
var
  LBitmapHandle: HBITMAP;
  LServices: IOTAAboutBoxServices;
begin
  LBitmapHandle := LoadBitmap(HInstance, 'SplashScreenBitmap');
  if LBitmapHandle > 0 then
  begin
    LServices := BorlandIDEServices as IOTAAboutBoxServices;
    FPluginIndex := LServices.AddPluginInfo(GetWizardPluginName, GetWizardDescription, LBitmapHandle, False, '', GetWizardVersion);
  end;
end;

class procedure TOTAWizard.RegisterSplash;
var
  LBitmapHandle: HBITMAP;
begin
  LBitmapHandle := LoadBitmap(HInstance, 'SplashScreenBitmap');
  if LBitmapHandle > 0 then
    SplashScreenServices.AddPluginBitmap(GetWizardName, LBitmapHandle, False, '', GetWizardVersion);
end;

class procedure TOTAWizard.RegisterWizard(const AWizardClass: TWizardClass);
begin
  if FRegistry = nil then
    FRegistry := TWizardRegistry.Create;
  if FWizards = nil then
    FWizards := TWizards.Create;
  FRegistry.Add(AWizardClass);
end;

class function TOTAWizard.InitializeWizard(const Services: IBorlandIDEServices; RegisterProc: TWizardRegisterProc;
  var TerminateProc: TWizardTerminateProc; const AWizardClass: TOTAWizardClass): Boolean;
begin
  FWizard := AWizardClass.Create;
  FIndex := (BorlandIDEServices as IOTAWizardServices).AddWizard(FWizard as IOTAWizard);
  TerminateProc := TOTAWizard.Terminate;
  Result := True;
end;

class procedure TOTAWizard.Terminate;
begin
  (BorlandIDEServices as IOTAWizardServices).RemoveWizard(FIndex);
end;

end.

