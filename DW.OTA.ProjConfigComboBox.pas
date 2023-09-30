unit DW.OTA.ProjConfigComboBox;

{*******************************************************}
{                                                       }
{         TOTAL - Terrific Open Tools API Library       }
{                                                       }
{*******************************************************}

interface

uses
  // DW
  DW.Proj,
  // TOTAL
  DW.OTA.BaseProjectConfigComboBox;

type
  TProjConfigComboBox = class(TBaseProjectConfigComboBox)
  private
    FFileName: string;
    FProj: IProj;
    procedure SetFileName(const Value: string);
  protected
    procedure DoLoadTargets; override;
  public
    procedure Clear; override;
    function GetSelectedSearchPaths: TArray<string>;
    property FileName: string read FFileName write SetFileName;
  end;

implementation

uses
  // RTL
  System.SysUtils, System.IOUtils,
  // DW
  DW.Proj.Types,
  // TOTAL
  DW.OTA.Types;

{ TProjConfigComboBox }

procedure TProjConfigComboBox.SetFileName(const Value: string);
begin
  if not SameText(Value, FFileName) and TFile.Exists(Value) then
  begin
    FFileName := Value;
    LoadTargets;
  end;
end;

procedure TProjConfigComboBox.Clear;
begin
  inherited;
  FProj := nil;
end;

procedure TProjConfigComboBox.DoLoadTargets;
var
  LConfig: TProjConfig;
  LPlatform: string;
  LPlatforms: TArray<string>;
  LGroup: IProjPropertyGroup;
  LProjectPlatform: TProjectPlatform;
  LTarget: TProjectTarget;
begin
  if FProj = nil then
    FProj := TProj.Create(FFileName)
  else
    FProj.LoadFromFile(FFileName);
  LPlatforms := FProj.GetPlatforms(True);
  for LConfig in FProj.GetConfigs do
  begin
    LTarget := TProjectTarget.Create(LConfig, TProjectPlatform.Win32, True);
    Targets.Add(LTarget);
    Items.Add(LTarget.GetDisplayValue(True));
    for LPlatform in LPlatforms do
    begin
      if FProj.FindPropertyGroup(LConfig.Ident, LPlatform, LGroup) and TProjectPlatformHelper.FindProjectPlatform(LPlatform, LProjectPlatform) then
      begin
        LTarget := TProjectTarget.Create(LConfig, LProjectPlatform, False);
        Targets.Add(LTarget);
        Items.Add(LTarget.GetDisplayValue(True));
      end;
    end;
  end;
end;

function TProjConfigComboBox.GetSelectedSearchPaths: TArray<string>;
var
  LTarget: TProjectTarget;
  LPlatform: string;
begin
  if (FProj <> nil) and (Length(Targets) > 0) and (ItemIndex >= 0) and (ItemIndex < Length(Targets)) then
  begin
    LTarget := Targets[ItemIndex];
    if LTarget.IsAllPlatforms then
      LPlatform := ''
    else
      LPlatform := cProjectPlatformsShort[LTarget.Target];
    Result := FProj.GetProjectPaths(LPlatform, LTarget.Config.Name);
  end;
end;

end.
