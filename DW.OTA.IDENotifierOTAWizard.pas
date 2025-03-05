unit DW.OTA.IDENotifierOTAWizard;

{*******************************************************}
{                                                       }
{         TOTAL - Terrific Open Tools API Library       }
{                                                       }
{*******************************************************}

interface

uses
  ToolsAPI,
  DW.OTA.Wizard, DW.OTA.Notifiers;

type
  TIDENotifierOTAWizard = class;

  /// <summary>
  ///  Class for forwarding IDE notifications to the wizard
  /// </summary>
  TIDENotifier = class(TTOTALNotifier, IOTAIDENotifier, IOTAIDENotifier80, ITOTALNotifier)
  private
    [Weak] FWizard: TIDENotifierOTAWizard;
  protected
    { IOTAIDENotifier }
    procedure AfterCompile(Succeeded: Boolean); overload;
    procedure AfterSave;
    procedure BeforeCompile(const Project: IOTAProject; var Cancel: Boolean); overload;
    procedure BeforeSave;
    procedure Destroyed;
    procedure FileNotification(NotifyCode: TOTAFileNotification; const FileName: string; var Cancel: Boolean);
    procedure Modified;
    { IOTAIDENotifier50 }
    procedure AfterCompile(Succeeded: Boolean; IsCodeInsight: Boolean); overload;
    procedure BeforeCompile(const Project: IOTAProject; IsCodeInsight: Boolean; var Cancel: Boolean); overload;
    { IOTAIDENotifier80 }
    procedure AfterCompile(const Project: IOTAProject; Succeeded: Boolean; IsCodeInsight: Boolean); overload;
  public
    constructor Create(const AWizard: TIDENotifierOTAWizard);
    destructor Destroy; override;
    procedure AddNotifier; override;
    procedure RemoveNotifier; override;
  end;

  /// <summary>
  ///  Base OTA Wizard that responds to IDE notifications. Create a descendant of this class for your own add-ins
  /// </summary>
  TIDENotifierOTAWizard = class(TOTAWizard)
  private
    FIDENotifier: ITOTALNotifier;
  protected
    /// <summary>
    ///   Override IDENotifierAfterCompile to be notified when a compile has finished
    /// </summary>
    procedure IDENotifierAfterCompile(const AProject: IOTAProject; const ASucceeded, AIsCodeInsight: Boolean); virtual;
    /// <summary>
    ///   Override IDENotifierAfterSave to be notified after a file is saved
    /// </summary>
    procedure IDENotifierAfterSave; virtual;
    /// <summary>
    ///   Override IDENotifierBeforeCompile to be notified when a compile is about to start
    /// </summary>
    procedure IDENotifierBeforeCompile(const AProject: IOTAProject; const AIsCodeInsight: Boolean; var ACancel: Boolean); virtual;
    /// <summary>
    ///   Override IDENotifierAfterSave to be notified when a file is about to be saved
    /// </summary>
    procedure IDENotifierBeforeSave; virtual;
    procedure IDENotifierDestroyed; virtual;
    /// <summary>
    ///   Override IDENotifierFileNotification to be notified of a TOTAFileNotification
    /// </summary>
    procedure IDENotifierFileNotification(const ANotifyCode: TOTAFileNotification; const AFileName: string); virtual;
    procedure IDEStopped; override;
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

implementation

{ TIDENotifier }

constructor TIDENotifier.Create(const AWizard: TIDENotifierOTAWizard);
begin
  inherited Create;
  FWizard := AWizard;
end;

destructor TIDENotifier.Destroy;
begin
  //
  inherited;
end;

procedure TIDENotifier.Destroyed;
begin
  FWizard.IDENotifierDestroyed;
end;

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

procedure TIDENotifier.AfterCompile(const Project: IOTAProject; Succeeded, IsCodeInsight: Boolean);
begin
  FWizard.IDENotifierAfterCompile(Project, Succeeded, IsCodeInsight);
end;

procedure TIDENotifier.AfterCompile(Succeeded, IsCodeInsight: Boolean);
begin
  //
end;

procedure TIDENotifier.AfterSave;
begin
  FWizard.IDENotifierAfterSave;
end;

procedure TIDENotifier.BeforeCompile(const Project: IOTAProject; var Cancel: Boolean);
begin
  FWizard.IDENotifierBeforeCompile(Project, False, Cancel);
end;

procedure TIDENotifier.BeforeCompile(const Project: IOTAProject; IsCodeInsight: Boolean; var Cancel: Boolean);
begin
  FWizard.IDENotifierBeforeCompile(Project, IsCodeInsight, Cancel);
end;

procedure TIDENotifier.BeforeSave;
begin
  FWizard.IDENotifierBeforeSave;
end;

procedure TIDENotifier.FileNotification(NotifyCode: TOTAFileNotification; const FileName: string; var Cancel: Boolean);
begin
  FWizard.IDENotifierFileNotification(NotifyCode, FileName);
end;

procedure TIDENotifier.Modified;
begin
  // Apparently this is never called?
end;

{ TIDENotifierOTAWizard }

constructor TIDENotifierOTAWizard.Create;
begin
  inherited;
  FIDENotifier := TIDENotifier.Create(Self);
end;

destructor TIDENotifierOTAWizard.Destroy;
begin
  //
  inherited;
end;

procedure TIDENotifierOTAWizard.IDEStopped;
begin
  inherited;
  // FIDENotifier.RemoveNotifier;
end;

procedure TIDENotifierOTAWizard.IDENotifierAfterCompile(const AProject: IOTAProject; const ASucceeded, AIsCodeInsight: Boolean);
begin
  IDEAfterCompile(AProject, ASucceeded, AIsCodeInsight);
end;

procedure TIDENotifierOTAWizard.IDENotifierAfterSave;
begin
  //
end;

procedure TIDENotifierOTAWizard.IDENotifierBeforeCompile(const AProject: IOTAProject; const AIsCodeInsight: Boolean; var ACancel: Boolean);
begin
  IDEBeforeCompile(AProject, AIsCodeInsight, ACancel);
end;

procedure TIDENotifierOTAWizard.IDENotifierBeforeSave;
begin
  //
end;

procedure TIDENotifierOTAWizard.IDENotifierDestroyed;
begin
  //
end;

procedure TIDENotifierOTAWizard.IDENotifierFileNotification(const ANotifyCode: TOTAFileNotification; const AFileName: string);
begin
  // This passes the notification on to the "plugin" wizards
  FileNotification(ANotifyCode, AFileName);
end;

end.
