unit TotalDemo.Resources;

interface

uses
  System.SysUtils, System.Classes, System.ImageList, Vcl.ImgList, Vcl.Controls, System.Actions, Vcl.ActnList;

type
  TResources = class(TDataModule)
    ActionList: TActionList;
    Demo1Action: TAction;
    ImageList: TImageList;
    Demo2Action: TAction;
    procedure Demo1ActionExecute(Sender: TObject);
    procedure Demo2ActionExecute(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  Resources: TResources;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  ToolsAPI,
  DW.OTA.Helpers;

{ TWziardResources }

constructor TResources.Create(AOwner: TComponent);
var
  LServices: INTAServices;
begin
  inherited;
  LServices := BorlandIDEServices as INTAServices;
  LServices.AddImages(ImageList);
  LServices.AddActionMenu('', Demo1Action, nil);
  LServices.AddActionMenu('', Demo2Action, nil);
end;

procedure TResources.Demo1ActionExecute(Sender: TObject);
begin
  // Does nothing
end;

procedure TResources.Demo2ActionExecute(Sender: TObject);
begin
  // Does nothing
end;

end.
