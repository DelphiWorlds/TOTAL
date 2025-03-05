unit DW.Menus.Helpers;

{*******************************************************}
{                                                       }
{         TOTAL - Terrific Open Tools API Library       }
{                                                       }
{*******************************************************}

interface

uses
  System.Classes,
  Vcl.Menus;

type
  TMenuItemHelper = class helper for TMenuItem
  public
    class function CreateWithAction(const AOwner: TComponent; const ACaption: string; const AHandler: TNotifyEvent;
      const AImageIndex: Integer = -1): TMenuItem;
    class function CreateSeparator(const AOwner: TComponent; const AIndex: Integer = -1): TMenuItem;
  public
    function FindMenuByCaption(const ACaption: string; out AItem: TMenuItem): Boolean;
    procedure Sort(const AToSeparator: Boolean = False);
  end;

implementation

uses
  // RTL
  System.SysUtils,
  // Vcl
  Vcl.ActnList;

{ TMenuItemHelper }

class function TMenuItemHelper.CreateSeparator(const AOwner: TComponent; const AIndex: Integer = -1): TMenuItem;
var
  LParent: TMenuItem;
begin
  Result := nil;
  LParent := TMenuItem(AOwner);
  if (LParent.Count > 0) and ((AIndex <> -1) or (LParent.Items[LParent.Count - 1].Caption <> '-')) then
  begin
    Result := TMenuItem.Create(AOwner);
    Result.Caption := '-';
    if AIndex > -1 then
      LParent.Insert(AIndex, Result)
    else
      LParent.Insert(TMenuItem(AOwner).Count, Result);
  end;
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

function TMenuItemHelper.FindMenuByCaption(const ACaption: string; out AItem: TMenuItem): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Count - 1 do
  begin
    if string(Items[I].Caption).Equals(ACaption) then
    begin
      AItem := Items[I];
      Exit(True);
    end;
  end;
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
