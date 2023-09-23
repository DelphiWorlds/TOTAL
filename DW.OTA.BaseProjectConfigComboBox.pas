unit DW.OTA.BaseProjectConfigComboBox;

{*******************************************************}
{                                                       }
{         TOTAL - Terrific Open Tools API Library       }
{                                                       }
{*******************************************************}

interface

uses
  // RTL
  System.Types, System.Classes,
  // Win
  Winapi.Messages,
  // Vcl
  Vcl.Controls, Vcl.StdCtrls,
  // DW
  DW.Proj.Types,
  // TOTAL
  DW.OTA.Types;

const
  cProjectPlatformsShort: array[TProjectPlatform] of string = (
    'Android', 'Android64',
    'iOSDevice32', 'iOSDevice64', 'iOSSimARM64',
    'Linux64',
    'OSX32', 'OSX64', 'OSXARM64',
    'Win32', 'Win64'
  );

type
  TProjectPlatformHelper = record
    class function FindProjectPlatform(const AShortName: string; out APlatform: TProjectPlatform): Boolean; static;
  end;

  TProjectTarget = record
    Config: TProjConfig;
    Target: TProjectPlatform;
    IsAllPlatforms: Boolean;
    constructor Create(const AConfig: TProjConfig; const ATarget: TProjectPlatform; const AIsAllPlatforms: Boolean);
    function GetDisplayValue(const ANeedExtended: Boolean): string;
  end;

  TProjectTargets = TArray<TProjectTarget>;

  TProjectTargetsHelper = record helper for TProjectTargets
    procedure Add(const ATarget: TProjectTarget);
  end;

  TBaseProjectConfigComboBox = class(TComboBox)
  private
    FTargets: TProjectTargets;
  protected
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
    procedure DoLoadTargets; virtual;
    property Targets: TProjectTargets read FTargets;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Clear; override;
    procedure LoadTargets;
  end;

implementation

uses
  System.SysUtils, System.IOUtils,
  Winapi.Windows,
  {$IF Defined(EXPERT)}
  BrandingAPI,
  {$ENDIF}
  Vcl.Graphics;

const
  cProjectPlatformsLong: array[TProjectPlatform] of string = (
    'Android 32-bit', 'Android 64-bit',
    'iOS 32-bit', 'iOS 64-bit', 'iOS Simulator ARM 64-bit',
    'Linux 64-bit',
    'macOS 32-bit', 'macOS 64-bit', 'macOS ARM 64-bit',
    'Windows 32-bit', 'Windows 64-bit'
  );

{ TProjectPlatformHelper }

class function TProjectPlatformHelper.FindProjectPlatform(const AShortName: string; out APlatform: TProjectPlatform): Boolean;
var
  LPlatform: TProjectPlatform;
begin
  Result := False;
  for LPlatform := Low(TProjectPlatform) to High(TProjectPlatform) do
  begin
    if SameText(cProjectPlatformsShort[LPlatform], AShortName) then
    begin
      APlatform := LPlatform;
      Result := True;
      Break;
    end;
  end;
end;

{ TProjectTargetsHelper }

procedure TProjectTargetsHelper.Add(const ATarget: TProjectTarget);
begin
  Self := Self + [ATarget];
end;

{ TProjectTarget }

constructor TProjectTarget.Create(const AConfig: TProjConfig; const ATarget: TProjectPlatform; const AIsAllPlatforms: Boolean);
begin
  Config := AConfig;
  Target := ATarget;
  IsAllPlatforms := AIsAllPlatforms;
end;

function TProjectTarget.GetDisplayValue(const ANeedExtended: Boolean): string;
begin
  if Config.Name = 'Base' then
    Result := 'All Configurations'
  else
    Result := Config.Name + ' Configuration';
  if not IsAllPlatforms then
  begin
    if ANeedExtended then
      Result := Format('%s - %s', [Result, cProjectPlatformsLong[Target]])
    else
      Result := cProjectPlatformsLong[Target]
  end;
end;

{ TBaseProjectConfigComboBox }

constructor TBaseProjectConfigComboBox.Create(AOwner: TComponent);
begin
  inherited;
  Style := csOwnerDrawFixed;
end;

procedure TBaseProjectConfigComboBox.Clear;
begin
  inherited;
  FTargets := [];
end;

procedure TBaseProjectConfigComboBox.LoadTargets;
begin
  Clear;
  DoLoadTargets;
  if Length(Targets) > 24 then
    DropDownCount := 24
  else
    DropDownCount := Length(Targets);
  if Items.Count > 0 then
    ItemIndex := 0;
end;

procedure TBaseProjectConfigComboBox.DoLoadTargets;
begin
  //
end;

procedure TBaseProjectConfigComboBox.DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  LTarget: TProjectTarget;
begin
  TControlCanvas(Canvas).UpdateTextFlags;
  {$IF Defined(EXPERT)}
  if (ThemeProperties <> nil) and (odSelected in State) then
  begin
    Canvas.Brush.Color := ThemeProperties.StyleServices.GetSystemColor(clHighlight);
    Canvas.Font.Color := ThemeProperties.StyleServices.GetSystemColor(clHighlightText);
  end;
  {$ENDIF}
  Canvas.FillRect(Rect);
  if Index >= 0 then
  begin
    LTarget := FTargets[Index];
    if (odComboBoxEdit in State) or not DroppedDown then
    begin
      Canvas.Font.Style := Canvas.Font.Style - [fsBold];
      Canvas.TextOut(Rect.Left, Rect.Top, LTarget.GetDisplayValue(True));
    end
    else
    begin
      if LTarget.IsAllPlatforms then
        Canvas.Font.Style := Canvas.Font.Style + [fsBold]
      else
        Canvas.Font.Style := Canvas.Font.Style - [fsBold];
      Canvas.TextOut(Rect.Left + (Ord(not LTarget.IsAllPlatforms) * 16), Rect.Top, LTarget.GetDisplayValue(odComboBoxEdit in State));
    end;
    {$IF Defined(EXPERT)}
    if (ThemeProperties <> nil) and (odFocused in State) then
      DrawFocusRect(Canvas.Handle, Rect);
    {$ENDIF}
  end;
end;

end.
