unit TotalDemo.DockWindowForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  {$IF Defined(EXPERT)} DockForm, {$ENDIF}
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TDockWindowForm = class({$IF Defined(EXPERT)}TDockableForm{$ELSE}TForm{$ENDIF})
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DockWindowForm: TDockWindowForm;

implementation

{$R *.dfm}

end.
