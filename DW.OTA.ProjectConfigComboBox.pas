unit DW.OTA.ProjectConfigComboBox;

{*******************************************************}
{                                                       }
{         TOTAL - Terrific Open Tools API Library       }
{                                                       }
{*******************************************************}

interface

uses
  // ToolsAPI
  ToolsAPI, PlatformAPI,
  // TOTAL
  DW.OTA.BaseProjectConfigComboBox;

type
  TOTAProjectConfigComboBox = class(TBaseProjectConfigComboBox)
  private
    FPlatforms: IOTAProjectPlatforms;
    FConfigs: TArray<IOTABuildConfiguration>;
    procedure AddConfig(const AConfig: IOTABuildConfiguration);
    procedure AddConfigPlatform(const AConfig: IOTABuildConfiguration);
    function GetSelectedConfig: IOTABuildConfiguration;
  protected
    procedure DoLoadTargets; override;
  public
    procedure Clear; override;
    property SelectedConfig: IOTABuildConfiguration read GetSelectedConfig;
  end;

implementation

uses
  // RTL
  System.SysUtils,
  // DW
  DW.Proj.Types,
  // TOTAL
  DW.OTA.Helpers, DW.OTA.Types;

{ TOTAProjectConfigComboBox }

procedure TOTAProjectConfigComboBox.AddConfigPlatform(const AConfig: IOTABuildConfiguration);
var
  LTarget: TProjectTarget;
  LProjectPlatform: TProjectPlatform;
begin
  LProjectPlatform := TProjectPlatform.Win32;
  TProjectPlatformHelper.FindProjectPlatform(AConfig.Platform, LProjectPlatform);
  LTarget := TProjectTarget.Create(TProjConfig.Create(AConfig.Name, ''), LProjectPlatform, AConfig.Platform = '');
  Targets.Add(LTarget);
  Items.Add(LTarget.GetDisplayValue(True));
  FConfigs := FConfigs + [AConfig];
end;

procedure TOTAProjectConfigComboBox.Clear;
begin
  inherited;
  FConfigs := [];
end;

procedure TOTAProjectConfigComboBox.AddConfig(const AConfig: IOTABuildConfiguration);
var
  I: Integer;
  LPlatform: string;
begin
  AddConfigPlatform(AConfig);
  for LPlatform in FPlatforms.EnabledPlatforms do
    AddConfigPlatform(AConfig.PlatformConfiguration[LPlatform]);
  for I := 0 to AConfig.ChildCount -1 do
    AddConfig(AConfig.Children[I]);
end;

procedure TOTAProjectConfigComboBox.DoLoadTargets;
var
  LProject: IOTAProject;
  LConfigs: IOTAProjectOptionsConfigurations;
begin
  LProject := TOTAHelper.GetActiveProject;
  if (LProject <> nil) and Supports(LProject, IOTAProjectPlatforms, FPlatforms)
    and Supports(LProject.ProjectOptions, IOTAProjectOptionsConfigurations, LConfigs) then
  begin
    AddConfig(LConfigs.BaseConfiguration);
  end;
end;

function TOTAProjectConfigComboBox.GetSelectedConfig: IOTABuildConfiguration;
begin
  Result := nil;
  if (ItemIndex > -1) and (ItemIndex < Length(FConfigs)) then
    Result := FConfigs[ItemIndex];
end;

end.
