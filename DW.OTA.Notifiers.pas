unit DW.OTA.Notifiers;

interface

uses
  ToolsAPI;

type
  TIDENotifier = class(TInterfacedObject, IOTAIDENotifier)
  private
    FIndex: Integer;
  public
    { IOTAIDENotifier }
    procedure AfterCompile(Succeeded: Boolean); virtual;
    procedure AfterSave; virtual;
    procedure BeforeCompile(const Project: IOTAProject; var Cancel: Boolean); virtual;
    procedure BeforeSave; virtual;
    procedure Destroyed; virtual;
    procedure FileNotification(NotifyCode: TOTAFileNotification; const FileName: string; var Cancel: Boolean); virtual;
    procedure Modified; virtual;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TDebuggerNotifier = class(TNotifierObject, IOTADebuggerNotifier90)
  private
    FIndex: Integer;
  public
    { IOTANotifier }
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;
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
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TIDENotifier }

constructor TIDENotifier.Create;
begin
  inherited Create;
  FIndex := (BorlandIDEServices as IOTAServices).AddNotifier(Self);
end;

destructor TIDENotifier.Destroy;
begin
  (BorlandIDEServices as IOTAServices).RemoveNotifier(FIndex);
  inherited;
end;

procedure TIDENotifier.Destroyed;
begin
  //
end;

procedure TIDENotifier.AfterCompile(Succeeded: Boolean);
begin
  //
end;

procedure TIDENotifier.AfterSave;
begin
  //
end;

procedure TIDENotifier.BeforeCompile(const Project: IOTAProject; var Cancel: Boolean);
begin
  //
end;

procedure TIDENotifier.BeforeSave;
begin
  //
end;

procedure TIDENotifier.FileNotification(NotifyCode: TOTAFileNotification; const FileName: string; var Cancel: Boolean);
begin
  //
end;

procedure TIDENotifier.Modified;
begin
  // Apparently this is never called?
end;

{ TDebuggerNotifier }

constructor TDebuggerNotifier.Create;
begin
  inherited;
  FIndex := (BorlandIDEServices as IOTADebuggerServices).AddNotifier(Self as IOTADebuggerNotifier);
end;

destructor TDebuggerNotifier.Destroy;
begin
  (BorlandIDEServices as IOTADebuggerServices).RemoveNotifier(FIndex);
  inherited;
end;

procedure TDebuggerNotifier.AfterSave;
begin
  //
end;

function TDebuggerNotifier.BeforeProgramLaunch(const Project: IOTAProject): Boolean;
begin
  Result := True;
end;

procedure TDebuggerNotifier.BeforeSave;
begin
  //
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

procedure TDebuggerNotifier.Destroyed;
begin
  //
end;

procedure TDebuggerNotifier.Modified;
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

end.
