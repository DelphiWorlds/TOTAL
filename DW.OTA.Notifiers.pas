unit DW.OTA.Notifiers;

interface

uses
  ToolsAPI;

type
  TIDENotifier = class(TInterfacedObject, IOTAIDENotifier)
  private
//    FIndex: Integer;
//    FProject: IOTAProject;
  protected
    { IOTAIDENotifier }
    procedure AfterCompile(Succeeded: Boolean);
    procedure BeforeCompile(const Project: IOTAProject; var Cancel: Boolean);
    procedure FileNotification(NotifyCode: TOTAFileNotification; const FileName: string; var Cancel: Boolean);
  end;

implementation

{ TIDENotifier }

procedure TIDENotifier.AfterCompile(Succeeded: Boolean);
begin

end;

procedure TIDENotifier.BeforeCompile(const Project: IOTAProject; var Cancel: Boolean);
begin

end;

procedure TIDENotifier.FileNotification(NotifyCode: TOTAFileNotification; const FileName: string; var Cancel: Boolean);
begin

end;

end.
