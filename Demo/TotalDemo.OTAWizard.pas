unit TotalDemo.OTAWizard;

interface

implementation

uses
  ToolsAPI,
  Vcl.Menus,
  DW.OTA.Wizard, DW.OTA.IDENotifierOTAWizard, DW.OTA.Helpers,
  TotalDemo.Consts, TotalDemo.FormEnhancer;

type
  TDemoOTAWizard = class(TIDENotifierOTAWizard)
  private
    FMenuItem: TMenuItem;
    procedure AddMenu;
  protected
    class function GetWizardName: string; override;
  protected
    procedure ActiveFormChanged; override;
    function GetIDString: string; override;
    function GetName: string; override;
    function GetWizardDescription: string; override;
    procedure IDEStarted; override;
    procedure WizardsCreated; override;
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

{ TDemoOTAWizard }

constructor TDemoOTAWizard.Create;
begin
  inherited;
  AddMenu;
end;

destructor TDemoOTAWizard.Destroy;
begin
  FMenuItem.Free;
  inherited;
end;

procedure TDemoOTAWizard.AddMenu;
var
  LToolsMenuItem: TMenuItem;
begin
  if TOTAHelper.FindToolsMenu(LToolsMenuItem) then
  begin
    FMenuItem := TMenuItem.Create(nil);
    FMenuItem.Name := cTOTALDemoMenuItemName;
    FMenuItem.Caption := 'TOTAL Demo';
    LToolsMenuItem.Insert(0, FMenuItem);
  end;
end;

procedure TDemoOTAWizard.IDEStarted;
begin
  inherited;

end;

procedure TDemoOTAWizard.WizardsCreated;
begin
  inherited;

end;

procedure TDemoOTAWizard.ActiveFormChanged;
begin
  inherited;
  TFormEnhancer.EnhanceActiveForm;
end;

// Unique identifier
function TDemoOTAWizard.GetIDString: string;
begin
  Result := 'com.delphiworlds.totaldemowizard';
end;

function TDemoOTAWizard.GetName: string;
begin
  Result := GetWizardName;
end;

function TDemoOTAWizard.GetWizardDescription: string;
begin
  Result := 'Demo of a Delphi IDE Wizard using TOTAL';
end;

class function TDemoOTAWizard.GetWizardName: string;
begin
  Result := 'TOTAL Demo';
end;

function Initialize(const Services: IBorlandIDEServices; RegisterProc: TWizardRegisterProc;
  var TerminateProc: TWizardTerminateProc): Boolean; stdcall;
begin
  Result := TOTAWizard.InitializeWizard(Services, RegisterProc, TerminateProc, TDemoOTAWizard);
end;

exports
  Initialize name WizardEntryPoint;

initialization
  TDemoOTAWizard.RegisterSplash;

end.
