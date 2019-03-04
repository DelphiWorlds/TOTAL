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
  if LForm = nil then
    Exit; // <======
  if LForm.ClassName.Equals(cFormsVariableEntryDialogClassName) then
    EnhanceVariableEntryDialog(LForm);
  // Other "enhancements" can follow, here
end;

class procedure TFormEnhancer.EnhanceVariableEntryDialog(const AForm: TForm);
var
  LEdit: TControl;
begin
  AForm.BorderStyle := TFormBorderStyle.bsSizeable;
  AForm.Width := AForm.Width + 4;
  AForm.Height := AForm.Height + 4;
  AForm.Constraints.MaxHeight := AForm.Height;
  LEdit := TControl(AForm.FindComponent('VarName'));
  if LEdit <> nil then
    LEdit.Anchors := LEdit.Anchors + [TAnchorKind.akRight];
  LEdit := TControl(AForm.FindComponent('VarValue'));
  if LEdit <> nil then
    LEdit.Anchors := LEdit.Anchors + [TAnchorKind.akRight];
  LEdit := TControl(AForm.FindComponent('bOK'));
  if LEdit <> nil then
    LEdit.Anchors := [TAnchorKind.akBottom, TAnchorKind.akRight];
  LEdit := TControl(AForm.FindComponent('bCancel'));
  if LEdit <> nil then
    LEdit.Anchors := [TAnchorKind.akBottom, TAnchorKind.akRight];
  LEdit := TControl(AForm.FindComponent('bHelp'));
  if LEdit <> nil then
    LEdit.Anchors := [TAnchorKind.akBottom, TAnchorKind.akRight];
end;

end.
