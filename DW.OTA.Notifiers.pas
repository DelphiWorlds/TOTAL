unit DW.OTA.Notifiers;

{*******************************************************}
{                                                       }
{         TOTAL - Terrific Open Tools API Library       }
{                                                       }
{*******************************************************}

interface

uses
  // RTL
  System.Generics.Collections, System.Classes, System.Types,
  // Design
  DockForm, ToolsAPI, StructureViewAPI,
  // Vcl
  Vcl.Graphics;

type
  ITOTALNotifier = interface(IInterface)
    ['{85CA09CC-370C-4FAB-9A42-4687A6550328}']
    function GetIndex: Integer;
    procedure AddNotifier;
    procedure RemoveNotifier;
    procedure SetIndex(const AValue: Integer);
  end;

  ITOTALModuleTracker = interface(IInterface)
    ['{38C0E273-C75A-450A-8F7E-5787BEF9A348}']
    procedure AfterRename(const OldFileName, NewFileName: string);
  end;

  TTOTALNotifier = class(TNotifierObject, ITOTALNotifier)
  private
    FIndex: Integer;
  protected
    { ITOTALNotifier }
    procedure AddNotifier; virtual; abstract;
    function GetIndex: Integer;
    procedure RemoveNotifier; virtual; abstract;
    procedure SetIndex(const AValue: Integer);
  protected
    property Index: Integer read GetIndex write SetIndex;
  public
    constructor Create;
  end;

  TDebuggerNotifier = class(TTOTALNotifier, IOTADebuggerNotifier, IOTADebuggerNotifier90)
  protected
    { IOTADebuggerNotifier }
    procedure ProcessCreated(const Process: IOTAProcess); virtual;
    procedure ProcessDestroyed(const Process: IOTAProcess); virtual;
    procedure BreakpointAdded(const Breakpoint: IOTABreakpoint); virtual;
    procedure BreakpointDeleted(const Breakpoint: IOTABreakpoint); virtual;
    { IOTADebuggerNotifier90 }
    procedure BreakpointChanged(const Breakpoint: IOTABreakpoint); virtual;
    procedure CurrentProcessChanged(const Process: IOTAProcess); virtual;
    procedure ProcessStateChanged(const Process: IOTAProcess); virtual;
    function BeforeProgramLaunch(const Project: IOTAProject): Boolean; virtual;
    procedure ProcessMemoryChanged; virtual;
  public
    procedure AddNotifier; override;
    procedure RemoveNotifier; override;
  end;

  TIDENotifier = class(TTOTALNotifier, IOTAIDENotifier)
  protected
    { IOTAIDENotifier }
    procedure AfterCompile(Succeeded: Boolean); virtual;
    procedure BeforeCompile(const Project: IOTAProject; var Cancel: Boolean); virtual;
    procedure FileNotification(NotifyCode: TOTAFileNotification; const FileName: string; var Cancel: Boolean); virtual;
  public
    procedure AddNotifier; override;
    procedure RemoveNotifier; override;
  end;

  TEditServicesNotifier = class(TTOTALNotifier, INTAEditServicesNotifier)
  protected
    procedure EditWindowClosed(const EditWindow: INTAEditWindow); virtual;
    procedure EditWindowOpened(const EditWindow: INTAEditWindow); virtual;
  protected
    { INTAEditServicesNotifier }
    procedure DockFormRefresh(const EditWindow: INTAEditWindow; DockForm: TDockableForm);
    procedure DockFormUpdated(const EditWindow: INTAEditWindow; DockForm: TDockableForm);
    procedure DockFormVisibleChanged(const EditWindow: INTAEditWindow; DockForm: TDockableForm);
    procedure EditorViewActivated(const EditWindow: INTAEditWindow; const EditView: IOTAEditView); virtual;
    procedure EditorViewModified(const EditWindow: INTAEditWindow; const EditView: IOTAEditView); virtual;
    procedure WindowActivated(const EditWindow: INTAEditWindow);
    procedure WindowCommand(const EditWindow: INTAEditWindow; Command, Param: Integer; var Handled: Boolean);
    procedure WindowNotification(const EditWindow: INTAEditWindow; Operation: TOperation);
    procedure WindowShow(const EditWindow: INTAEditWindow; Show, LoadedFromDesktop: Boolean);
  public
    procedure AddNotifier; override;
    procedure RemoveNotifier; override;
  end;

  TEditViewNotifier = class(TTOTALNotifier, INTAEditViewNotifier)
  private
    FView: IOTAEditView;
  public
   { INTAEditViewNotifier }
    procedure BeginPaint(const View: IOTAEditView; var FullRepaint: Boolean); virtual;
    procedure EditorIdle(const View: IOTAEditView);
    procedure EndPaint(const View: IOTAEditView);
    procedure PaintLine(const View: IOTAEditView; LineNumber: Integer; const LineText: PAnsiChar; const TextWidth: Word;
      const LineAttributes: TOTAAttributeArray; const Canvas: TCanvas; const TextRect: TRect; const LineRect: TRect; const CellSize: TSize); virtual;
  public
    constructor Create(const AView: IOTAEditView);
    destructor Destroy; override;
    procedure AddNotifier; override;
    procedure RemoveNotifier; override;
    property View: IOTAEditView read FView;
  end;

  TStructureViewNotifier = class(TTOTALNotifier, IOTAStructureNotifier)
  public
    { IOTAStructureNotifier }
    procedure DefaultNodeAction(const Node: IOTAStructureNode);
    procedure NodeEdited(const Node: IOTAStructureNode);
    procedure NodeFocused(const Node: IOTAStructureNode);
    procedure NodeSelected(const Node: IOTAStructureNode);
    procedure StructureChanged(const Context: IOTAStructureContext); virtual;
    procedure VisibleChanged(Visible: WordBool);
  public
    procedure AddNotifier; override;
    procedure RemoveNotifier; override;
  end;

  TNonRefInterfacedObject = class(TObject, IInterface)
  protected
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  end;

  TModuleNotifier = class(TNonRefInterfacedObject, IOTANotifier, IOTAModuleNotifier, IOTAModuleNotifier80, IOTAModuleNotifier90)
  private
    [Weak] FTracker: ITOTALModuleTracker;
  protected
    { IOTANotifier }
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;
    { IOTAModuleNotifier }
    function CheckOverwrite: Boolean;
    procedure ModuleRenamed(const ANewName: string);
    { IOTAModuleNotifier80 }
    function AllowSave: Boolean;
    function GetOverwriteFileName(Index: Integer): string;
    function GetOverwriteFileNameCount: Integer;
    procedure SetSaveFileName(const FileName: string);
    { IOTAModuleNotifier90 }
    procedure AfterRename(const OldFileName, NewFileName: string);
    procedure BeforeRename(const OldFileName, NewFileName: string);
  public
    constructor Create(const ATracker: ITOTALModuleTracker);
  end;

implementation

{ TTOTALNotifier }

constructor TTOTALNotifier.Create;
begin
  inherited;
  AddNotifier;
end;

function TTOTALNotifier.GetIndex: Integer;
begin
  Result := FIndex;
end;

procedure TTOTALNotifier.SetIndex(const AValue: Integer);
begin
  FIndex := AValue;
end;

{ TDebuggerNotifier }

procedure TDebuggerNotifier.AddNotifier;
begin
  Index := (BorlandIDEServices as IOTADebuggerServices).AddNotifier(Self);
end;

procedure TDebuggerNotifier.RemoveNotifier;
begin
  (BorlandIDEServices as IOTADebuggerServices).RemoveNotifier(Index);
end;

function TDebuggerNotifier.BeforeProgramLaunch(const Project: IOTAProject): Boolean;
begin
  Result := True;
end;

procedure TDebuggerNotifier.BreakpointAdded(const Breakpoint: IOTABreakpoint);
begin
  //
end;

procedure TDebuggerNotifier.BreakpointChanged(const Breakpoint: IOTABreakpoint);
begin
  //
end;

procedure TDebuggerNotifier.BreakpointDeleted(const Breakpoint: IOTABreakpoint);
begin
  //
end;

procedure TDebuggerNotifier.CurrentProcessChanged(const Process: IOTAProcess);
begin
  //
end;

procedure TDebuggerNotifier.ProcessCreated(const Process: IOTAProcess);
begin
  //
end;

procedure TDebuggerNotifier.ProcessDestroyed(const Process: IOTAProcess);
begin
  //
end;

procedure TDebuggerNotifier.ProcessMemoryChanged;
begin
  //
end;

procedure TDebuggerNotifier.ProcessStateChanged(const Process: IOTAProcess);
begin
  //
end;

{ TIDENotifier }

procedure TIDENotifier.AddNotifier;
begin
  Index := (BorlandIDEServices as IOTAServices).AddNotifier(Self);
end;

procedure TIDENotifier.RemoveNotifier;
begin
  (BorlandIDEServices as IOTAServices).RemoveNotifier(Index);
end;

procedure TIDENotifier.AfterCompile(Succeeded: Boolean);
begin
  //
end;

procedure TIDENotifier.BeforeCompile(const Project: IOTAProject; var Cancel: Boolean);
begin
  //
end;

procedure TIDENotifier.FileNotification(NotifyCode: TOTAFileNotification; const FileName: string; var Cancel: Boolean);
begin
  //
end;

{ TEditServicesNotifier }

procedure TEditServicesNotifier.AddNotifier;
begin
  Index := (BorlandIDEServices as IOTAEditorServices).AddNotifier(Self);
end;

procedure TEditServicesNotifier.RemoveNotifier;
begin
  (BorlandIDEServices as IOTAEditorServices).RemoveNotifier(Index);
end;

procedure TEditServicesNotifier.DockFormRefresh(const EditWindow: INTAEditWindow; DockForm: TDockableForm);
begin

end;

procedure TEditServicesNotifier.DockFormUpdated(const EditWindow: INTAEditWindow; DockForm: TDockableForm);
begin

end;

procedure TEditServicesNotifier.DockFormVisibleChanged(const EditWindow: INTAEditWindow; DockForm: TDockableForm);
begin

end;

procedure TEditServicesNotifier.EditorViewActivated(const EditWindow: INTAEditWindow; const EditView: IOTAEditView);
begin

end;

procedure TEditServicesNotifier.EditorViewModified(const EditWindow: INTAEditWindow; const EditView: IOTAEditView);
begin

end;

procedure TEditServicesNotifier.EditWindowClosed(const EditWindow: INTAEditWindow);
begin

end;

procedure TEditServicesNotifier.EditWindowOpened(const EditWindow: INTAEditWindow);
begin

end;

procedure TEditServicesNotifier.WindowActivated(const EditWindow: INTAEditWindow);
begin

end;

procedure TEditServicesNotifier.WindowCommand(const EditWindow: INTAEditWindow; Command, Param: Integer; var Handled: Boolean);
begin

end;

procedure TEditServicesNotifier.WindowNotification(const EditWindow: INTAEditWindow; Operation: TOperation);
begin
  case Operation of
    opInsert:
      EditWindowOpened(EditWindow);
    opRemove:
      EditWindowClosed(EditWindow);
  end;
end;

procedure TEditServicesNotifier.WindowShow(const EditWindow: INTAEditWindow; Show, LoadedFromDesktop: Boolean);
begin

end;

{ TEditViewNotifier }

constructor TEditViewNotifier.Create(const AView: IOTAEditView);
begin
  inherited Create;
  FView := AView;
  FView.AddNotifier(Self);
end;

destructor TEditViewNotifier.Destroy;
begin

  inherited;
end;

procedure TEditViewNotifier.AddNotifier;
begin

end;

procedure TEditViewNotifier.RemoveNotifier;
begin

end;

procedure TEditViewNotifier.BeginPaint(const View: IOTAEditView; var FullRepaint: Boolean);
begin
  //
end;

procedure TEditViewNotifier.EditorIdle(const View: IOTAEditView);
begin
  //
end;

procedure TEditViewNotifier.EndPaint(const View: IOTAEditView);
begin
  //
end;

procedure TEditViewNotifier.PaintLine(const View: IOTAEditView; LineNumber: Integer; const LineText: PAnsiChar; const TextWidth: Word;
  const LineAttributes: TOTAAttributeArray; const Canvas: TCanvas; const TextRect, LineRect: TRect; const CellSize: TSize);
begin
  //
end;

{ TStructureViewNotifier }

procedure TStructureViewNotifier.AddNotifier;
begin
  Index := (BorlandIDEServices as IOTAStructureView).AddNotifier(Self);
end;

procedure TStructureViewNotifier.RemoveNotifier;
begin
  (BorlandIDEServices as IOTAStructureView).RemoveNotifier(Index);
end;

procedure TStructureViewNotifier.DefaultNodeAction(const Node: IOTAStructureNode);
begin
  //
end;

procedure TStructureViewNotifier.NodeEdited(const Node: IOTAStructureNode);
begin
  //
end;

procedure TStructureViewNotifier.NodeFocused(const Node: IOTAStructureNode);
begin
  //
end;

procedure TStructureViewNotifier.NodeSelected(const Node: IOTAStructureNode);
begin
  //
end;

procedure TStructureViewNotifier.StructureChanged(const Context: IOTAStructureContext);
begin
  //
end;

procedure TStructureViewNotifier.VisibleChanged(Visible: WordBool);
begin
  //
end;

{ TNonRefInterfacedObject }

function TNonRefInterfacedObject.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE;
end;

function TNonRefInterfacedObject._AddRef: Integer;
begin
  Result := -1;
end;

function TNonRefInterfacedObject._Release: Integer;
begin
  Result := -1;
end;

{ TModuleNotifier }

constructor TModuleNotifier.Create(const ATracker: ITOTALModuleTracker);
begin
  inherited Create;
  FTracker := ATracker;
end;

procedure TModuleNotifier.Destroyed;
begin
  //
end;

procedure TModuleNotifier.AfterRename(const OldFileName, NewFileName: String);
begin
  if FTracker <> nil then
    FTracker.AfterRename(OldFileName, NewFileName);
end;

procedure TModuleNotifier.AfterSave;
begin

end;

function TModuleNotifier.AllowSave: Boolean;
begin
  Result := True;
end;

procedure TModuleNotifier.BeforeRename(const OldFileName, NewFileName: String);
begin
  //
end;

procedure TModuleNotifier.BeforeSave;
begin
  //
end;

function TModuleNotifier.CheckOverwrite: Boolean;
begin
  Result := True;
end;

function TModuleNotifier.GetOverwriteFileName(Index: Integer): String;
begin
  Result := '';
end;

function TModuleNotifier.GetOverwriteFileNameCount: Integer;
begin
  Result := 0;
end;

procedure TModuleNotifier.Modified;
begin
  //
end;

procedure TModuleNotifier.ModuleRenamed(const ANewName: string);
begin
  //
end;

procedure TModuleNotifier.SetSaveFileName(const FileName: String);
begin
  //
end;

end.
