unit DW.OTA.CustomMessage;

{*******************************************************}
{                                                       }
{         TOTAL - Terrific Open Tools API Library       }
{                                                       }
{*******************************************************}

interface

uses
  System.Types,
  ToolsAPI,
  Vcl.Graphics;

type
  TCustomMessage = class(TInterfacedObject, IOTACustomMessage, INTACustomDrawMessage)
  private
    FColumnNumber: Integer;
    FFileName: string;
    FLineNumber: Integer;
    FLineText: string;
  public
    { IOTACustomMessage }
    function GetColumnNumber: Integer;
    function GetFileName: string;
    function GetLineNumber: Integer;
    function GetLineText: string;
    procedure ShowHelp; virtual;
    { INTACustomDrawMessage }
    function CalcRect(Canvas: TCanvas; MaxWidth: Integer; Wrap: Boolean): TRect; virtual;
    procedure Draw(Canvas: TCanvas; const Rect: TRect; Wrap: Boolean); virtual;
  public
    constructor Create(const ALineText: string; const AFileName: string = ''; const ALineNumber: Integer = 0; const AColumnNumber: Integer = 0);
  end;

  TTextStyle = record
    Bold: Boolean;
    Italic: Boolean;
    Underline: Boolean;
    Color: TColor;
  end;

// Uses same scheme as HTML for bold <b>, italic <i> and underline <u>
// Uses a tag with # for colors, e.g.: <#FF4455>
// Needs a closing tag for each opening tag, e.g. <b>This is bold and <#FF0000>this part is in red</#></b>

  THighlightedCustomMessage = class(TCustomMessage)
  private
    procedure DrawText(const ACanvas: TCanvas; const AX, AY: Integer; const AText: string; const AStyle: TTextStyle);
  public
    procedure Draw(Canvas: TCanvas; const Rect: TRect; Wrap: Boolean); override;
  end;

implementation

uses
  System.SysUtils;

{ TCustomMessage }

constructor TCustomMessage.Create(const ALineText: string; const AFileName: string = ''; const ALineNumber: Integer = 0;
  const AColumnNumber: Integer = 0);
begin
  inherited Create;
  FLineText := ALineText;
  FFileName := AFileName;
  FLineNumber := ALineNumber;
  FColumnNumber := AColumnNumber;
end;

function TCustomMessage.CalcRect(Canvas: TCanvas; MaxWidth: Integer; Wrap: Boolean): TRect;
begin
  Result := Canvas.ClipRect;
  Result.Bottom := Result.Top + Canvas.TextHeight('W');
  Result.Right := Result.Left + Canvas.TextWidth(FLineText);
end;

procedure TCustomMessage.Draw(Canvas: TCanvas; const Rect: TRect; Wrap: Boolean);
begin
  Canvas.TextOut(Rect.Left, Rect.Top, FLineText);
end;

function TCustomMessage.GetColumnNumber: Integer;
begin
  Result := FColumnNumber;
end;

function TCustomMessage.GetFileName: string;
begin
  Result := FFileName;
end;

function TCustomMessage.GetLineNumber: Integer;
begin
  Result := FLineNumber;
end;

function TCustomMessage.GetLineText: string;
begin
  Result := FLineText;
end;

procedure TCustomMessage.ShowHelp;
begin
  //
end;

{ THighlightedCustomMessage }

procedure THighlightedCustomMessage.Draw(Canvas: TCanvas; const Rect: TRect; Wrap: Boolean);
var
  LStyle: TTextStyle;
  LText: string;
  I, LStartPos, LEndPos, LX: Integer;
  LDefaultColor: TColor;

  function ExtractTag(var APos: Integer): string;
  var
    LTagEnd: Integer;
  begin
    Inc(APos);
    LTagEnd := APos;
    while (LTagEnd <= Length(FLineText)) and (FLineText.Chars[LTagEnd] <> '>') do
      Inc(LTagEnd);
    Result := Copy(FLineText, APos + 1, LTagEnd - APos);
    APos := LTagEnd + 1;
  end;

  procedure ApplyTagStyle(const LTag: string);
  begin
    if LTag = 'b' then
      LStyle.Bold := True
    else if LTag = '/b' then
      LStyle.Bold := False
    else if LTag = 'i' then
      LStyle.Italic := True
    else if LTag = '/i' then
      LStyle.Italic := False
    else if LTag = 'u' then
      LStyle.Underline := True
    else if LTag = '/u' then
      LStyle.Underline := False
    else if Copy(LTag, 1, 1) = '#' then
      LStyle.Color := StringToColor('$' + Copy(LTag, 2, 6))
    else if LTag = '/#' then
      LStyle.Color := LDefaultColor;
  end;

begin
  LDefaultColor := Canvas.Font.Color;
  LStyle.Bold := False;
  LStyle.Italic := False;
  LStyle.Underline := False;
  LStyle.Color := LDefaultColor;
  LX := Rect.Left;
  I := 0;
  while I < Length(FLineText) do
  begin
    if FLineText.Chars[I] <> '<' then
    begin
      LStartPos := I;
      while (I < Length(FLineText)) and (FLineText.Chars[I] <> '<') do
        Inc(I);
      LEndPos := I - 1;
      LText := Copy(FLineText, LStartPos + 1, LEndPos - LStartPos + 1);
      DrawText(Canvas, LX, Rect.Top, LText, LStyle);
      LX := LX + Canvas.TextWidth(LText);
    end
    else
      ApplyTagStyle(ExtractTag(I));
  end;
end;

procedure THighlightedCustomMessage.DrawText(const ACanvas: TCanvas; const AX, AY: Integer; const AText: string; const AStyle: TTextStyle);
begin
  ACanvas.Font.Style := [];
  if AStyle.Bold then ACanvas.Font.Style :=
    ACanvas.Font.Style + [fsBold];
  if AStyle.Italic then
    ACanvas.Font.Style := ACanvas.Font.Style + [fsItalic];
  if AStyle.Underline then
    ACanvas.Font.Style := ACanvas.Font.Style + [fsUnderline];
  ACanvas.Font.Color := AStyle.Color;
  ACanvas.TextOut(AX, AY, AText);
end;

end.
