unit DW.OTA.ProjectManagerMenu;

{*******************************************************}
{                                                       }
{         TOTAL - Terrific Open Tools API Library       }
{                                                       }
{*******************************************************}

interface

uses
  // RTL
  System.Classes, System.SysUtils,
  // Design
  ToolsAPI,
  // TOTAL
  DW.OTA.Notifiers;

type
  TProjectManagerMenu = class;

  TProjectManagerMenuNotifier = class(TTOTALNotifier, IUnknown, IOTANotifier, IOTAProjectMenuItemCreatorNotifier)
  private
  protected
    procedure AddMenuItem(const AItem: TProjectManagerMenu; const APosition: Integer);
    procedure DoAddMenu(const AProject: IOTAProject; const AIdentList: TStrings; const AProjectManagerMenuList: IInterfaceList;
      AIsMultiSelect: Boolean); virtual;
    procedure DoAddGroupMenu(const AProject: IOTAProject; const AIdentList: TStrings; const AProjectManagerMenuList: IInterfaceList;
      AIsMultiSelect: Boolean); virtual;
    function FindItem(const AProjectManagerMenuList: IInterfaceList; const AVerb: string): Integer;
  public
    { IOTANotifier }
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;
    { IOTAProjectMenuItemCreatorNotifier }
    procedure AddMenu(const AProject: IOTAProject; const AIdentList: TStrings; const AProjectManagerMenuList: IInterfaceList;
      AIsMultiSelect: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddNotifier; override;
    procedure RemoveNotifier; override;
  end;

  TProjectManagerMenu = class(TNotifierObject, IOTALocalMenu, IOTAProjectManagerMenu)
  private
    FCaption: string;
    FExecuteProc: TProc;
    FName: string;
    FParent: string;
    FPosition: Integer;
    FVerb: string;
  public
    { IOTALocalMenu }
    function GetCaption: string; virtual;
    function GetChecked: Boolean; virtual;
    function GetEnabled: Boolean; virtual;
    function GetHelpContext: Integer;
    function GetName: string;
    function GetParent: string;
    function GetPosition: Integer;
    function GetVerb: string;
    procedure SetCaption(const Value: string);
    procedure SetChecked(Value: Boolean);
    procedure SetEnabled(Value: Boolean);
    procedure SetHelpContext(Value: Integer);
    procedure SetName(const Value: string);
    procedure SetParent(const Value: string);
    procedure SetPosition(Value: Integer);
    procedure SetVerb(const Value: string);
    { IOTAProjectManagerMenu }
    function GetIsMultiSelectable: Boolean;
    procedure Execute(const MenuContextList: IInterfaceList); overload;
    function PostExecute(const MenuContextList: IInterfaceList): Boolean;
    function PreExecute(const MenuContextList: IInterfaceList): Boolean;
    procedure SetIsMultiSelectable(Value: Boolean);
  public
    constructor Create(const ACaption, AVerb: string; const APosition: Integer; const AExecuteProc: TProc = nil;
      const AName: string = ''; const AParent: string = '');
  end;

  TProjectManagerMenuSeparator = class(TProjectManagerMenu, IOTAProjectManagerMenu)
  public
    constructor Create(APosition: Integer; const AParent: string = '');
  end;

implementation

uses
  DW.OTA.Helpers;

{ TProjectManagerMenuNotifier }

constructor TProjectManagerMenuNotifier.Create;
begin
  inherited;
  // FIndex := (BorlandIDEServices as IOTAProjectManager).AddMenuItemCreatorNotifier(Self);
end;

destructor TProjectManagerMenuNotifier.Destroy;
begin
  // (BorlandIDEServices as IOTAProjectManager).RemoveMenuItemCreatorNotifier(FIndex);
  inherited;
end;

procedure TProjectManagerMenuNotifier.AddNotifier;
begin
  Index := (BorlandIDEServices as IOTAProjectManager).AddMenuItemCreatorNotifier(Self);
end;

procedure TProjectManagerMenuNotifier.RemoveNotifier;
begin
  (BorlandIDEServices as IOTAProjectManager).RemoveMenuItemCreatorNotifier(Index);
end;

procedure TProjectManagerMenuNotifier.DoAddMenu(const AProject: IOTAProject; const AIdentList: TStrings;
  const AProjectManagerMenuList: IInterfaceList; AIsMultiSelect: Boolean);
begin
  //
end;

procedure TProjectManagerMenuNotifier.DoAddGroupMenu(const AProject: IOTAProject; const AIdentList: TStrings;
  const AProjectManagerMenuList: IInterfaceList; AIsMultiSelect: Boolean);
begin
  //
end;

procedure TProjectManagerMenuNotifier.AddMenu(const AProject: IOTAProject; const AIdentList: TStrings; const AProjectManagerMenuList: IInterfaceList;
  AIsMultiSelect: Boolean);
begin
  if AIdentList.IndexOf(sProjectContainer) > -1 then
    DoAddMenu(AProject, AIdentList, AProjectManagerMenuList, AIsMultiSelect)
  else if AIdentList.IndexOf(sProjectGroupContainer) > -1 then
    DoAddGroupMenu(AProject, AIdentList, AProjectManagerMenuList, AIsMultiSelect);
end;

procedure TProjectManagerMenuNotifier.AddMenuItem(const AItem: TProjectManagerMenu; const APosition: Integer);
begin

end;

function TProjectManagerMenuNotifier.FindItem(const AProjectManagerMenuList: IInterfaceList; const AVerb: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 To AProjectManagerMenuList.Count - 1 Do
  begin
    if CompareText((AProjectManagerMenuList[I] as IOTAProjectManagerMenu).Verb, AVerb) = 0 Then
      Exit(I);
  end;
end;

procedure TProjectManagerMenuNotifier.AfterSave;
begin
  //
end;

procedure TProjectManagerMenuNotifier.BeforeSave;
begin
  //
end;

procedure TProjectManagerMenuNotifier.Destroyed;
begin
  //
end;

procedure TProjectManagerMenuNotifier.Modified;
begin
  //
end;

{ TProjectManagerMenu }

constructor TProjectManagerMenu.Create(const ACaption, AVerb: string; const APosition: Integer; const AExecuteProc: TProc = nil;
  const AName: string = ''; const AParent: string = '');
begin
  inherited Create;
  FCaption := ACaption;
  FName := AName;
  FParent := AParent;
  FPosition := APosition;
  FVerb := AVerb;
  FExecuteProc := AExecuteProc;
end;

procedure TProjectManagerMenu.Execute(const MenuContextList: IInterfaceList);
begin
  if Assigned(FExecuteProc) then
    FExecuteProc;
end;

function TProjectManagerMenu.GetCaption: string;
begin
  Result := FCaption;
end;

function TProjectManagerMenu.GetChecked: Boolean;
begin
  Result := False;
end;

function TProjectManagerMenu.GetEnabled: Boolean;
begin
  Result := True;
end;

function TProjectManagerMenu.GetHelpContext: Integer;
begin
  Result := 0;
end;

function TProjectManagerMenu.GetIsMultiSelectable: Boolean;
begin
  Result := False;
end;

function TProjectManagerMenu.GetName: string;
begin
  Result := FName;
end;

function TProjectManagerMenu.GetParent: string;
begin
  Result := FParent;
end;

function TProjectManagerMenu.GetPosition: Integer;
begin
  Result := FPosition;
end;

function TProjectManagerMenu.GetVerb: string;
begin
  Result := FVerb;
end;

function TProjectManagerMenu.PostExecute(const MenuContextList: IInterfaceList): Boolean;
begin
  Result := False;
end;

function TProjectManagerMenu.PreExecute(const MenuContextList: IInterfaceList): Boolean;
begin
  Result := False;
end;

procedure TProjectManagerMenu.SetCaption(const Value: string);
begin
  FCaption := Value;
end;

procedure TProjectManagerMenu.SetChecked(Value: Boolean);
begin
  // Override GetChecked instead
end;

procedure TProjectManagerMenu.SetEnabled(Value: Boolean);
begin
  // Override GetEnabled instead
end;

procedure TProjectManagerMenu.SetHelpContext(Value: Integer);
begin
  // Override GetHelpContext instead
end;

procedure TProjectManagerMenu.SetIsMultiSelectable(Value: Boolean);
begin
  // Override GetIsMultiSelectable instead
end;

procedure TProjectManagerMenu.SetName(const Value: string);
begin
  // Why would you change the name, after creation? :-)
end;

procedure TProjectManagerMenu.SetParent(const Value: string);
begin
  // Override GetParent instead
end;

procedure TProjectManagerMenu.SetPosition(Value: Integer);
begin
  // Not sure why you would change the position after creation
end;

procedure TProjectManagerMenu.SetVerb(const Value: string);
begin
  // Why would you change the verb, after creation? :-)
end;

{ TProjectManagerMenuSeparator }

constructor TProjectManagerMenuSeparator.Create(APosition: Integer; const AParent: string);
begin
  inherited Create('-', '', APosition, nil, '', AParent);
end;

end.
