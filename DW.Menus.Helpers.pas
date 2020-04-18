unit DW.Menus.Helpers;

interface

uses
  System.Classes,
  Vcl.Menus;

type
  TMenuItemHelper = class helper for TMenuItem
  public
    class function CreateWithAction(const AOwner: TComponent; const ACaption: string; const AHandler: TNotifyEvent;
      const AImageIndex: Integer = -1): TMenuItem;
    class function CreateSeparator(const AOwner: TComponent): TMenuItem;
    procedure Sort(const AToSeparator: Boolean = False);
  end;

implementation

uses
  Vcl.ActnList;

{ TMenuItemHelper }

class function TMenuItemHelper.CreateSeparator(const AOwner: TComponent): TMenuItem;
begin
  Result := TMenuItem.Create(AOwner);
  Result.Caption := '-';
  TMenuItem(AOwner).Insert(TMenuItem(AOwner).Count, Result);
end;

class function TMenuItemHelper.CreateWithAction(const AOwner: TComponent; const ACaption: string; const AHandler: TNotifyEvent;
  const AImageIndex: Integer = -1): TMenuItem;
var
  LAction: TAction;
begin
  Result := TMenuItem.Create(AOwner);
  LAction := TAction.Create(Result);
  LAction.Caption := ACaption;
  LAction.OnExecute := AHandler;
  Result.Action := LAction;
//  if AInsert and (AOwner is TMenuItem) then
//    TMenuItem(AOwner).Insert(TMenuItem(AOwner).Count, Result);
  Result.ImageIndex := AImageIndex;
end;

// A variation of: http://embarcadero.newsgroups.archived.at/public.delphi.language.delphi.win32/200912/0912166323.html
procedure TMenuItemHelper.Sort;
var
  I, J: Integer;
begin
  for I := 0 to Count - 2 do
  begin
    for J := I + 1 to Count - 1 do
    begin
      if Items[J].Caption < Items[I].Caption then
        Items[J].MenuIndex := Items[I].MenuIndex;
    end;
  end;
end;

end.
