unit DW.OTA.Wizard;

{*******************************************************}
{                                                       }
{         TOTAL - Terrific Open Tools API Library       }
{                                                       }
{*******************************************************}

{$I DW.GlobalDefines.inc}

interface

uses
  // RTL
  System.Generics.Collections, System.Classes,
  // Design
  ToolsAPI, DeskUtil, DeskForm,
  // VCL
  Vcl.Forms, Vcl.ExtCtrls, Vcl.ActnList, Vcl.ActnPopup, Vcl.Menus;

type
  /// <summary>
  ///  Base Wizard. Create descendants of this class to act as "sub-wizards" of your OTA Wizard
  /// </summary>
  TWizard = class(TInterfacedObject)
  protected
    procedure ActiveFormChanged; virtual;
    procedure ConfigChanged; virtual;
    function DebuggerBeforeProgramLaunch(const Project: IOTAProject): Boolean; virtual;
    procedure DebuggerProcessCreated(const AProcess: IOTAProcess); virtual;
    procedure FileNotification(const ANotifyCode: TOTAFileNotification; const AFileName: string); virtual;
    function GetRSVersion: string;
    function HookedEditorMenuPopup(const AMenuItem: TMenuItem): Boolean; virtual;
    procedure IDEAfterCompile(const AProject: IOTAProject; const ASucceeded, AIsCodeInsight: Boolean); virtual;
    procedure IDEBeforeCompile(const AProject: IOTAProject; const AIsCodeInsight: Boolean; var ACancel: Boolean); virtual;
    procedure IDEStarted; virtual;
    procedure IDEStopped; virtual;
    procedure Modification; virtual;
    procedure PeriodicTimer; virtual;
    procedure ProjectChanged; virtual;
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
    class procedure DestroyWizards;
    class procedure Terminate; static;
  private
    FActiveForm: TForm;
    FIsIDEStarted: Boolean;
    FPeriodicInterval: Cardinal;
    FTimer: TTimer;
    procedure CreateWizards;
    procedure DoActiveFormChanged;
    procedure TimerIntervalHandler(Sender: TObject);
    procedure NotifyIDEStarted;
    procedure NotifyIDEStopped;
    procedure NotifyPeriodicTimer;
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
    /// <summary>
    ///   Provides class-based access to the instance of the add-in
    /// </summary>
    class property Wizard: TOTAWizard read FWizard;
  protected
    /// <summary>
    ///   Called when the active form of the IDE changes
    /// </summary>
    procedure ActiveFormChanged; virtual;
    /// <summary>
    ///   Call ConfigChanged to notify the "sub-wizards" that the configuration has changed
    /// </summary>
    procedure ConfigChanged; virtual;
    function DebuggerBeforeProgramLaunch(const AProject: IOTAProject): Boolean; virtual;
    /// <summary>
    ///   Called when the debugger creates a process
    /// </summary>
    procedure DebuggerProcessCreated(const AProcess: IOTAProcess);
    /// <summary>
    ///   Call FileNotification to notify the "sub-wizards" of the TOTAFileNotification
    /// </summary>
    procedure FileNotification(const ANotifyCode: TOTAFileNotification; const AFileName: string);
    /// <summary>
    ///   Finds the popup that shows when right-clicking the editor
    /// </summary>
    function FindEditorPopup(out APopup: TPopupActionBar): Boolean;
    /// <summary>
    ///   Returns the plugin name and version
    /// </summary>
    function GetWizardPluginName: string;
    /// <summary>
    ///   Override this function with the description of your add-in
    /// </summary>
    function GetWizardDescription: string; virtual;
    /// <summary>
    ///   Call HookedEditorMenu to notify the "sub-wizards" that they can now add items to the wizard's menu item
    /// </summary>
    procedure HookedEditorMenuPopup(const AMenuItem: TMenuItem);
    /// <summary>
    ///   Called when the IDE has finished compiling the specified project
    /// </summary>
    procedure IDEAfterCompile(const AProject: IOTAProject; const ASucceeded, AIsCodeInsight: Boolean);
    /// <summary>
    ///   Called when the IDE is about to compile the specified project
    /// </summary>
    procedure IDEBeforeCompile(const AProject: IOTAProject; const AIsCodeInsight: Boolean; var ACancel: Boolean);
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
    procedure PeriodicTimer; virtual;
    /// <summary>
    ///   Call Modification to notify the "sub-wizards" that a modification has occurred
    /// </summary>
    procedure Modification;
    procedure ProjectChanged;
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
  public
    /// <summary>
    ///   Creates an instance of a dockable form and performs the necessary initialization
    /// </summary>
    class procedure CreateDockableForm(var AForm; const AClass: TDesktopFormClass);
    /// <summary>
    ///   Destroys an instance of a dockable form and performs the necessary finalization
    /// </summary>
    class procedure FreeDockableForm(var AForm);
    /// <summary>
    ///   Override this function if necessary to provide the add-in's version (default is Major.Minor.Release)
    /// </summary>
    class function GetWizardVersion: string; virtual;
    /// <summary>
    ///   Override this function if necessary to provide the add-in's license info
    /// </summary>
    class function GetWizardLicense: string; virtual;
    /// <summary>
    ///   Call InitializeWizard from the function named as WizardEntryPoint that is exported by your add-in
    /// </summary>
    /// <remarks>
    ///   Refer to the export section at the end of the TotalDemo.OTAWizard unit
    /// </remarks>
    class function InitializeWizard(const Services: IBorlandIDEServices; RegisterProc: TWizardRegisterProc;
      var TerminateProc: TWizardTerminateProc; const AWizardClass: TOTAWizardClass): Boolean;
    /// <summary>
    ///   Call RegisterDesktopForm somewhere
    /// </summary>
    // class procedure RegisterDesktopFormClass(const AClass: TDesktopFormClass);
    // class procedure RegisterDesktopForm(var AForm);
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
  System.SysUtils, System.Win.Registry,
  // Windows
  Winapi.Windows,
  // DW
  DW.OTA.Registry, DW.OTA.Helpers, DW.Menus.Helpers, DW.OSDevice;

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
  //
end;

function TWizard.DebuggerBeforeProgramLaunch(const Project: IOTAProject): Boolean;
begin
  Result := True;
end;

procedure TWizard.DebuggerProcessCreated(const AProcess: IOTAProcess);
begin
  //
end;

procedure TWizard.FileNotification(const ANotifyCode: TOTAFileNotification; const AFileName: string);
begin
  //
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
  LReg: TRegistry;
begin
  LReg := TBDSRegistry.Current;
  if LReg.OpenKey(TOTAHelper.GetRegKey + '\Library\' + APlatform, False) then
  try
    LPaths := TStringList.Create;
    try
      LPaths.Text := StringReplace(LReg.GetDataAsString('Search Path'), ';', #13#10, [rfReplaceAll]);
      if AAdd then
        APaths.AddStrings(LPaths)
      else
        APaths.Assign(LPaths);
    finally
      LPaths.Free;
    end;
  finally
    LReg.CloseKey;
  end;
end;

function TWizard.HookedEditorMenuPopup(const AMenuItem: TMenuItem): Boolean;
begin
  Result := False;
end;

procedure TWizard.Modification;
begin
  //
end;

procedure TWizard.PeriodicTimer;
begin
  //
end;

procedure TWizard.ProjectChanged;
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

procedure TWizard.IDEBeforeCompile(const AProject: IOTAProject; const AIsCodeInsight: Boolean; var ACancel: Boolean);
begin
  //
end;

procedure TWizard.IDEStarted;
begin
  //
end;

procedure TWizard.IDEStopped;
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
  FTimer := TTimer.Create(nil);
  FTimer.Interval := 50;
  FTimer.OnTimer := TimerIntervalHandler;
  FTimer.Enabled := True;
end;

destructor TOTAWizard.Destroy;
begin
  if FPluginIndex > 0 then
    (BorlandIDEServices as IOTAAboutBoxServices).RemovePluginInfo(FPluginIndex);
  FTimer.Free;
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

function TOTAWizard.DebuggerBeforeProgramLaunch(const AProject: IOTAProject): Boolean;
var
  LWizard: TWizard;
begin
  Result := True;
  if FWizards <> nil then
  begin
    for LWizard in FWizards do
    try
      Result := LWizard.DebuggerBeforeProgramLaunch(AProject);
    except
      // Swallow any exceptions caused by wizards
    end;
  end;
end;

procedure TOTAWizard.DebuggerProcessCreated(const AProcess: IOTAProcess);
var
  LWizard: TWizard;
begin
  if FWizards <> nil then
  begin
    for LWizard in FWizards do
      LWizard.DebuggerProcessCreated(AProcess);
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

procedure TOTAWizard.IDEBeforeCompile(const AProject: IOTAProject; const AIsCodeInsight: Boolean; var ACancel: Boolean);
var
  LWizard: TWizard;
begin
  if FWizards <> nil then
  begin
    for LWizard in FWizards do
    try
      LWizard.IDEBeforeCompile(AProject, AIsCodeInsight, ACancel);
    except
      // Swallow any exceptions caused by wizards
    end;
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

procedure TOTAWizard.PeriodicTimer;
begin
  //
end;

procedure TOTAWizard.ProjectChanged;
var
  LWizard: TWizard;
begin
  if FWizards <> nil then
  begin
    for LWizard in FWizards do
      LWizard.ProjectChanged;
  end;
end;

function TOTAWizard.FindEditorPopup(out APopup: TPopupActionBar): Boolean;
var
  LComponent: TComponent;
begin
  Result := False;
  if TOTAHelper.FindComponentGlobal('EditorLocalMenu', LComponent) and (LComponent is TPopupActionBar) then
  begin
    APopup := TPopupActionBar(LComponent);
    Result := True;
  end;
end;

procedure TOTAWizard.TimerIntervalHandler(Sender: TObject);
var
  LMainForm: TComponent;
  LTerminated: Boolean;
begin
  LTerminated := Application.Terminated;
  if not LTerminated then
  begin
    LMainForm := Application.FindComponent('AppBuilder');
    if not FIsIDEStarted and (LMainForm is TForm) and TForm(LMainForm).Visible then
      NotifyIDEStarted;
    if Screen.ActiveForm <> FActiveForm then
    begin
      FActiveForm := Screen.ActiveForm;
      DoActiveFormChanged;
    end;
    if FIsIDEStarted then
    begin
      Inc(FPeriodicInterval, FTimer.Interval);
      if FPeriodicInterval >= 100 then
        NotifyPeriodicTimer;
    end;
  end
  else if FIsIDEStarted then
    NotifyIDEStopped;
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

procedure TOTAWizard.NotifyIDEStopped;
var
  LWizard: TWizard;
begin
  IDEStopped;
  if FWizards <> nil then
  begin
    for LWizard in FWizards do
      LWizard.IDEStopped;
  end;
end;

procedure TOTAWizard.NotifyPeriodicTimer;
var
  LWizard: TWizard;
begin
  PeriodicTimer;
  if FWizards <> nil then
  begin
    for LWizard in FWizards do
      LWizard.PeriodicTimer;
  end;
  FPeriodicInterval := 0;
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
  end;
  WizardsCreated;
end;

class procedure TOTAWizard.DestroyWizards;
var
  LWizard: TWizard;
begin
  if FWizards <> nil then
  begin
    for LWizard in FWizards do
      LWizard.Free;
    FWizards.Free;
    FWizards := nil;
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

procedure TOTAWizard.HookedEditorMenuPopup(const AMenuItem: TMenuItem);
var
  LWizard: TWizard;
  LIndex: Integer;
begin
  if FWizards <> nil then
  begin
    for LWizard in FWizards do
    begin
      LIndex := AMenuItem.Count - 1;
      if LWizard.HookedEditorMenuPopup(AMenuItem) and (LIndex > -1) then
        TMenuItem.CreateSeparator(AMenuItem, LIndex);
    end;
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

class function TOTAWizard.GetWizardLicense: string;
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

class procedure TOTAWizard.CreateDockableForm(var AForm; const AClass: TDesktopFormClass);
var
  LForm: TCustomForm;
begin
  TCustomForm(AForm) := AClass.Create(nil);
  LForm := TCustomForm(AForm);
  if @RegisterFieldAddress <> nil then
    RegisterFieldAddress(LForm.Name, @AForm);
  RegisterDesktopFormClass(AClass, LForm.Name, LForm.Name);
end;

class procedure TOTAWizard.FreeDockableForm(var AForm);
var
  LForm: TCustomForm;
begin
  LForm := TCustomForm(AForm);
  if Assigned(LForm) then
  begin
    if @UnRegisterFieldAddress <> nil then
      UnregisterFieldAddress(@AForm);
    LForm.Free;
    TCustomForm(AForm) := nil;
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
    FPluginIndex := LServices.AddPluginInfo(GetWizardPluginName, GetWizardDescription, LBitmapHandle, False, GetWizardLicense, GetWizardVersion);
  end;
end;

class procedure TOTAWizard.RegisterSplash;
var
  LBitmapHandle: HBITMAP;
begin
  LBitmapHandle := LoadBitmap(HInstance, 'SplashScreenBitmap');
  if LBitmapHandle > 0 then
    SplashScreenServices.AddPluginBitmap(GetWizardName, LBitmapHandle, False, GetWizardLicense, GetWizardVersion);
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
  DestroyWizards;
  (BorlandIDEServices as IOTAWizardServices).RemoveWizard(FIndex);
end;

end.
