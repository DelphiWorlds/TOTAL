unit DW.OTA.Wizard;

{*******************************************************}
{                                                       }
{         DelphiWorlds Open Tools API Support           }
{                                                       }
{          Copyright(c) 2018 David Nottage              }
{              All rights reserved                      }
{                                                       }
{*******************************************************}

{$I DW.GlobalDefines.inc}

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
  TWizard = class(TInterfacedObject)
  private
    class var FReg: TRegistry;
    class var FEnvVars: TStrings;
    class destructor DestroyClass;
  private
    procedure CreateReg;
    function GetEnvVars: TStrings;
  protected
    procedure ActiveFormChanged; virtual;
    procedure ConfigChanged; virtual;
    procedure FileNotification(const ANotifyCode: TOTAFileNotification; const AFileName: string); virtual;
    function GetRSVersion: string;
    procedure GetSearchPaths(const APlatform: string; const APaths: TStrings; const AAdd: Boolean = False);
    procedure IDEStarted; virtual;
    procedure Modification; virtual;
  protected
    class property Reg: TRegistry read FReg;
  protected
    property EnvVars: TStrings read GetEnvVars;
  public
    constructor Create; virtual;
  end;

  TWizardClass = class of TWizard;

  TWizardRegistry = TList<TWizardClass>;
  TWizards = TList<TWizard>;

  TOTAWizard = class;

  TOTAWizardClass = class of TOTAWizard;

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
    class function GetWizardName: string; virtual;
    class function GetWizardVersion: string; virtual;
    class procedure RegisterSplash;
  protected
    procedure ActiveFormChanged; virtual;
    procedure ConfigChanged;
    procedure FileNotification(const ANotifyCode: TOTAFileNotification; const AFileName: string);
    function GetWizardPluginName: string;
    function GetWizardDescription: string; virtual;
    procedure IDEStarted; virtual;
    procedure Modification;
    procedure WizardsCreated; virtual;
    { IOTANotifier }
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;
    { IOTAWizard }
    procedure Execute;
    function GetIDString: string; virtual;
    function GetName: string; virtual;
    function GetState: TWizardState;
    class property Wizard: TOTAWizard read FWizard;
  public
    class function InitializeWizard(const Services: IBorlandIDEServices; RegisterProc: TWizardRegisterProc;
      var TerminateProc: TWizardTerminateProc; const AWizardClass: TOTAWizardClass): Boolean;
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

{ TWizard }

constructor TWizard.Create;
begin
  inherited;
  if FReg = nil then
    CreateReg;
  if FEnvVars = nil then
    FEnvVars := TStringList.Create;
end;

procedure TWizard.CreateReg;
var
  LAccess: Cardinal;
begin
  LAccess := KEY_READ;
  if TOSVersion.Architecture = TOSVersion.TArchitecture.arIntelX64 then
    LAccess := LAccess or KEY_WOW64_64KEY
  else
    LAccess := LAccess or KEY_WOW64_32KEY;
  FReg := TRegistry.Create(LAccess);
  FReg.RootKey := HKEY_CURRENT_USER;
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

procedure TWizard.GetSearchPaths(const APlatform: string; const APaths: TStrings; const AAdd: Boolean = False);
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
  FIDETimer := TTimer.Create(nil);
  FIDETimer.Interval := 50;
  FIDETimer.OnTimer := IDETimerIntervalHandler;
  FIDETimer.Enabled := True;
  RegisterPlugin;
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

procedure TOTAWizard.IDEStarted;
begin
  //
end;

procedure TOTAWizard.IDETimerIntervalHandler(Sender: TObject);
var
  LMainForm: TComponent;
begin
  LMainForm := Application.FindComponent('AppBuilder');
  if not FIsIDEStarted and (LMainForm is TForm) and TForm(LMainForm).Visible then
    NotifyIDEStarted;
  if Screen.ActiveForm <> FActiveForm then
  begin
    FActiveForm := Screen.ActiveForm;
    DoActiveFormChanged;
  end;
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
  // nothing
end;

procedure TOTAWizard.BeforeSave;
begin
  // nothing
end;

procedure TOTAWizard.Destroyed;
begin
  // nothing
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
  // Nothing
end;

procedure TOTAWizard.Execute;
begin
  // Nothing
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
begin
  Result := TOSDevice.GetPackageVersion;
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

