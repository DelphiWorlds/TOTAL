unit TotalDemo.FormEnhancer;

interface

uses
  Vcl.Forms;

type
  TFormEnhancer = record
  private
    class procedure EnhanceVariableEntryDialog(const AForm: TForm); static;
  public
    class procedure EnhanceActiveForm; static;
  end;

implementation

uses
  System.SysUtils,
  Vcl.Controls;

const
  cFormsVariableEntryDialogClassName = 'TVariableEntry';

{ TFormEnhancer }

class procedure TFormEnhancer.EnhanceActiveForm;
var
  LForm: TForm;
begin
  LForm := Screen.ActiveForm;
  if LForm <> nil then
  begin
    if LForm.ClassName.Equals(cFormsVariableEntryDialogClassName) then
      EnhanceVariableEntryDialog(LForm);
    // Other "enhancements" can follow, here
  end;
end;

class procedure TFormEnhancer.EnhanceVariableEntryDialog(const AForm: TForm);
var
  LControl: TControl;
begin
  // This method is an example of how an IDE dialog might be "enhanced"
  // It was used for making the Environment Variable Entry dialog resizable in Delphi 10.2 Tokyo (no longer necessary for Delphi 10.3.x +)
  AForm.BorderStyle := TFormBorderStyle.bsSizeable;
  AForm.Width := AForm.Width + 4;
  AForm.Height := AForm.Height + 4;
  AForm.Constraints.MaxHeight := AForm.Height;
  LControl := TControl(AForm.FindComponent('VarName'));
  if LControl <> nil then
    LControl.Anchors := LControl.Anchors + [TAnchorKind.akRight];
  LControl := TControl(AForm.FindComponent('VarValue'));
  if LControl <> nil then
    LControl.Anchors := LControl.Anchors + [TAnchorKind.akRight];
  LControl := TControl(AForm.FindComponent('bOK'));
  if LControl <> nil then
    LControl.Anchors := [TAnchorKind.akBottom, TAnchorKind.akRight];
  LControl := TControl(AForm.FindComponent('bCancel'));
  if LControl <> nil then
    LControl.Anchors := [TAnchorKind.akBottom, TAnchorKind.akRight];
  LControl := TControl(AForm.FindComponent('bHelp'));
  if LControl <> nil then
    LControl.Anchors := [TAnchorKind.akBottom, TAnchorKind.akRight];
end;

end.
