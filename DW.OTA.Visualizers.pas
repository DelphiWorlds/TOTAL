unit DW.OTA.Visualizers;

{*******************************************************}
{                                                       }
{         TOTAL - Terrific Open Tools API Library       }
{                                                       }
{*******************************************************}

interface

uses
  ToolsAPI;

type
  IVisualizers = interface(IInterface)
    ['{F73F09FC-9D54-424B-81CA-7599C9E72E88}']
    procedure Add(const AVisualizer: IOTADebuggerVisualizer);
  end;

var
  Visualizers: IVisualizers;

implementation

type
  TVisualizers = class(TInterfacedObject, IVisualizers)
  private
    FItems: TArray<IOTADebuggerVisualizer>;
  public
    { IVisualizers }
    procedure Add(const AVisualizer: IOTADebuggerVisualizer);
  public
    destructor Destroy; override;
  end;

{ TVisualizers }

procedure TVisualizers.Add(const AVisualizer: IOTADebuggerVisualizer);
begin
  FItems := FItems + [AVisualizer];
  (BorlandIDEServices as IOTADebuggerServices).RegisterDebugVisualizer(AVisualizer);
end;

destructor TVisualizers.Destroy;
var
  LVisualizer: IOTADebuggerVisualizer;
begin
  for LVisualizer in FItems do
    (BorlandIDEServices as IOTADebuggerServices).UnregisterDebugVisualizer(LVisualizer);
  inherited;
end;

initialization
  Visualizers := TVisualizers.Create;

end.
