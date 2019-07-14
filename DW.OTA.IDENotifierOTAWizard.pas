unit DW.OTA.IDENotifierOTAWizard;

{*******************************************************}
{                                                       }
{         DelphiWorlds Open Tools API Support           }
{                                                       }
{          Copyright(c) 2019 David Nottage              }
{              All rights reserved                      }
{                                                       }
{*******************************************************}

{$I DW.GlobalDefines.inc}

interface

uses
  // Design
  ToolsAPI,
  // DW
  DW.OTA.Wizard;

type
  TIDENotifierOTAWizard = class;

  /// <summary>
  ///  Class for forwarding IDE notifications to the wizard
  /// </summary>
  TIDENotifier = class(TInterfacedObject, IOTAIDENotifier)
  private
    FIndex: Integer;
    FWizard: TIDENotifierOTAWizard;
  protected
    { IOTAIDENotifier }
    procedure AfterCompile(Succeeded: Boolean);
    procedure AfterSave;
    procedure BeforeCompile(const Project: IOTAProject; var Cancel: Boolean);
    procedure BeforeSave;
    procedure Destroyed;
    procedure FileNotification(NotifyCode: TOTAFileNotification; const FileName: string; var Cancel: Boolean);
    procedure Modified;
  public
    constructor Create(const AWizard: TIDENotifierOTAWizard);
    destructor Destroy; override;
  end;

  /// <summary>
  ///  Base OTA Wizard that responds to IDE notifications. Create a descendant of this class for your own add-ins
  /// </summary>
  TIDENotifierOTAWizard = class(TOTAWizard)
  private
    FIDENotifier: TIDENotifier;
  protected
    /// <summary>
    ///   Override IDENotifierAfterCompile to be notified when a compile has finished
    /// </summary>
    procedure IDENotifierAfterCompile(Succeeded: Boolean); virtual;
    /// <summary>
    ///   Override IDENotifierAfterSave to be notified after a file is saved
    /// </summary>
    procedure IDENotifierAfterSave; virtual;
    /// <summary>
    ///   Override IDENotifierBeforeCompile to be notified when a compile is about to start
    /// </summary>
    procedure IDENotifierBeforeCompile(const Project: IOTAProject; var Cancel: Boolean); virtual;
    /// <summary>
    ///   Override IDENotifierAfterSave to be notified when a file is about to be saved
    /// </summary>
    procedure IDENotifierBeforeSave; virtual;
    procedure IDENotifierDestroyed; virtual;
    /// <summary>
    ///   Override IDENotifierFileNotification to be notified of a TOTAFileNotification
    /// </summary>
    procedure IDENotifierFileNotification(const ANotifyCode: TOTAFileNotification; const AFileName: string); virtual;
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

implementation

uses
  DW.OSLog;

{ TIDENotifier }

constructor TIDENotifier.Create(const AWizard: TIDENotifierOTAWizard);
begin
  inherited Create;
  FWizard := AWizard;
  FIndex := (BorlandIDEServices as IOTAServices).AddNotifier(Self);
end;

destructor TIDENotifier.Destroy;
begin
  TOSLog.d('TIDENotifier.Destroy');
  (BorlandIDEServices as IOTAServices).RemoveNotifier(FIndex);
  inherited;
end;

procedure TIDENotifier.Destroyed;
begin
  FWizard.IDENotifierDestroyed;
end;

procedure TIDENotifier.AfterCompile(Succeeded: Boolean);
begin
  FWizard.IDENotifierAfterCompile(Succeeded);
end;

procedure TIDENotifier.AfterSave;
begin
  FWizard.IDENotifierAfterSave;
end;

procedure TIDENotifier.BeforeCompile(const Project: IOTAProject; var Cancel: Boolean);
begin
  FWizard.IDENotifierBeforeCompile(Project, Cancel);
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

procedure TIDENotifierOTAWizard.IDENotifierAfterCompile(Succeeded: Boolean);
begin
  //
end;

procedure TIDENotifierOTAWizard.IDENotifierAfterSave;
begin
  //
end;

procedure TIDENotifierOTAWizard.IDENotifierBeforeCompile(const Project: IOTAProject; var Cancel: Boolean);
begin
  //
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
