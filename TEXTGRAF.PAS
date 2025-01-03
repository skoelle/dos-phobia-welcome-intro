        unit TextGraf;
interface
uses dos;
type
  MonitorTyp = (Hercules, EGA, VGA, other);
  VGAColorInfo = array[0..2] of byte;        { eine VGA-Farbe: nur fÅr Demo }
  VGAColors = array[0..255] of VGAColorInfo; { alle VGA-Farben: dito }

  function InitTextGraf: integer;
    { Mu· ganz zu Anfang des Programms, noch im Textmodus aufgerufen
      werden. Ohne das funktioniert der Rest nicht. Ergebnis 0: Alles Ok,
      unbekannter Videotyp: -1, zuwenig Speicher: 1 (Bedarf ca. 12Kb) }
  procedure SetPaletteSave(On: boolean);
    { Mit On = true nach InitTextGraf und im Textmodus aufrufen. Sichert die
      Textpalette und reserviert Speicher fÅr die Grafikpalette, die dann
      automatisch verwendet werden. On = false schaltet diese Automatik
      wieder ab und gibt den Speicher fÅr die Paletten (ca. 1.5Kb) frei.}
  procedure ToText;
    { Schaltet vom Grafik- in den Testmodus. Bildspeicher etc. werden in
      Sicherheit gebracht }
  procedure ToGraph;
    { Schaltet in die Grafik zurÅck. Vorher sollte ein Grafikmodus mit
      ToText verlassen worden sein, um alle Werte zu initialisieren }

  procedure GrafikMode(Mode: byte);
     { nur fÅr das Demoprogramm. Kann gelîscht werden, wenn BGI-Routinen
       (InitGraph) verwendet werden }
  function GetMonTyp: MonitorTyp;
     { dito }
  procedure SetVGAColors(var Colors: VGAColors);
     { dito }
implementation


type
  ScreenArray = array[0..3999] of word;         { Bildspeicher bei 80x25 }
  CharGenArray = array[0..8191] of byte;        { Zeichengenerator }
  ModeType = (Text, Grafik, unknown);

var
  regs: registers;                              { fÅr intr }
  CharGen: CharGenArray absolute $A000:0;       { Adresse Zeichengenerator }
  BMode: byte absolute $40:$49;                 { Bios-Videomode }

const
    VModus: ModeType = unknown;
    VMonitor: MonitorTyp = other;             { Vorgabe: nichts gutes }
    TScreen: ^ScreenArray = nil;        { zeigt in den Bildspeicher }
    ScrBuf: ^ScreenArray = nil;         { speichert Textschirm zwischen }
    CGBuf: ^CharGenArray = nil;         { speichert Zeichengenerator }
    ModeNr: byte = $FF;                 { Kennung fÅr Init }
    TMode: byte = $FF;                  { der zu restaurierende Textmodus }
    GMode: byte = $FF;                  { dito Grafikmodus }
    VGATextPal: ^VGAColors = nil;
    VGAGraphPal: ^VGAColors = nil;

function IsVga: boolean;	{ haben wir VGA }
begin
  with regs do
  begin
    AX:= $1A00; 		{ Display Combination abfragen }
    Intr($10, regs);
    IsVga:= (AL = $1A); 	{ gÅltiger Aufruf }
  end;
end;

function IsEGA: boolean;	{ liegt wenigstens EGA vor }
begin
  with regs do
  begin
    AH:= $12;			{ Funktion $12 }
    BL:= $10;			{ get EGA Information }
    Intr($10, regs);
    IsEga:= (BL <> $10);	{ hat sich was geÑndert ? }
  end;
end;

procedure GetVGAColors(var Colors: VGAColors);
begin
  with regs do
  begin
    ax:= $1017;
    bx:= 0;
    cx:= 255;
    es:= seg(Colors);
    dx:= ofs(Colors);
    intr($10, regs);
  end;
end;

procedure SetVGAColors(var Colors: VGAColors);
begin
  with regs do
  begin
    ax:= $1012;
    bx:= 0;
    cx:= 255;
    es:= seg(Colors);
    dx:= ofs(Colors);
    intr($10, regs);
  end;
end;

procedure NoInitStop;
begin
  writeln('TextGraph ist nicht initialisiert! Benutzen Sie InitTextGraph!');
  halt(2);
end;

procedure HercTextMode;
var i: integer;
    ModeReg: byte absolute 0:$465;
const HData: array[0..13] of byte =  { Timingdaten! Nicht verÑndern! }
        ($61,$50,$52,$0f,$19,$06,$19,$19,$02,$0d,$0b,$0c,0,0);
begin
  port[$3bf]:= 0;	{ Config Reg: HalfMode: eine Seite (3 fÅr Full Mode) }
  port[$3b8]:= $21;	{ Mode Control: Dunkel, Text, 80x25 }
  for i:= 0 to 13 do	{ die Timing-Daten komplett }
  begin
    port[$3b4]:= i;		{ Index Laden (Register einblenden) }
    port[$3b5]:= HData[i];	{ Wert schreiben }
  end;
  port[$3b8]:= $29;	{ ModeControl: Hell, Text, 80x25 }
  ModeReg:= $29;	{ im BIOS-Ram protokollieren }
end;

procedure HercGraphMode;
var i: integer;
    ModeReg: byte absolute 0:$465;
const HData: array[0..13] of byte =  { Timingdaten! Nicht verÑndern! }
	($35,$2d,$2e,$07,$5b,$02,$57,$57,$02,$03,0,0,0,0);
begin
  port[$3bf]:= 1;	{ Config Reg: HalfMode: eine Seite (3 fÅr Full Mode) }
  port[$3b8]:= 2;	{ Mode Control: Dunkel, Grafik, Seite 0 }
  for i:= 0 to 13 do	{ die Timing-Daten komplett }
  begin
    port[$3b4]:= i;		{ Index Laden (Register einblenden) }
    port[$3b5]:= HData[i];	{ Wert schreiben }
  end;
  port[$3b8]:= $0a;			{ ModeControl: Hell, Grafik, Seite 0 }
  ModeReg:= $0a;			{ im BIOS-Ram protokollieren }
end;

procedure GrafikMode(Mode: byte); { Setzt den Videomodus, nur fÅr Demo }
var i: integer;
begin
  if VMonitor <> Hercules then	{ alle au·er Hercules sind sehr einfach }
  with regs do
  begin
    AX:= Mode;			{ AH:= 0; AL:= Mode }
    Intr($10, regs);
  end
  else
  begin
    HercGraphMode;
    fillchar(ptr($B000,0)^, $8000, 0);	{ Clearscreen }
  end;
end;

function GetMonTyp: MonitorTyp; { Zugriffsfunktion, nur fÅr das Demo }
begin
  GetMonTyp:= VMonitor;
end;

procedure ToTextVGA;    { sichert den Teil des Grafik-Bildspeichers, der }
var b: byte;            { vom Zeichengenerator Åberschrieben wird }
begin
  regs.ax:= $90;        { Standardmodus setzen um Zugriff sicherzustellen }
  intr($10, regs);      { Bildspeicher bleibt erhalten }
  Port[$3ce]:= 4;       { Read Map Select holen }
  b:= Port[$3cf];       { lesen }
  Port[$3cf]:= 2;       { Plane 2 ein }
  CGBuf^:= CharGen;     { Grafikinhalt von Zeichengenerator sichern }
  Port[$3cf]:= b;       { Wert zurÅck }
end;

procedure ToTextEGA;    { wie oben jedoch Variante fÅr EGA, }
var b: byte;            { deren Register nicht lesbar sind }
begin
  regs.ax:= $90;        { Standardmodus setzen um Zugriff sicherzustellen }
  intr($10, regs);      { Bildspeicher bleibt erhalten }
  Port[$3ce]:= 4;       { Read Map Select holen }
  Port[$3cf]:= 2;       { Plane 2 ein }
  CGBuf^:= CharGen;     { Grafikinhalt von Zeichengenerator sichern }
  Port[$3cf]:= 0;       { Default zurÅck }
end;

procedure ToGraphVGA;   { Åberschreibt den Zeichengenerator mit }
var b: byte;            {  gesicherten Grafikinhalt }
begin
  regs.ax:= $90;        { Standardmodus setzen um Zugriff sicherzustellen }
  intr($10, regs);      { Bildspeicher bleibt erhalten }
  Port[$3C4]:= 2;       { Map Mask Register holen }
  b:= Port[$3c5];       { lesen }
  Port[$3c5]:= 4;       { Plane 2 ein }
  CharGen:= CGBuf^;     { Zeichengenerator zurÅck }
  Port[$3c5]:= b;       { Wert zurÅck }
end;

procedure ToGraphEGA;   { wie oben jedoch Variante fÅr EGA, }
var b: byte;            { deren Register nicht lesbar sind }
begin
  regs.ax:= $90;        { Standardmodus setzen um Zugriff sicherzustellen }
  intr($10, regs);      { Bildspeicher bleibt erhalten }
  Port[$3C4]:= 2;       { Map Mask Register holen }
  Port[$3c5]:= 4;       { Plane 2 ein }
  CharGen:= CGBuf^;     { Zeichengenerator kopieren }
  Port[$3c5]:= 0;       { Default zurÅck }
end;

function InitTextGraf: integer; { ermittelt Monitor, setzt Variablen, }
begin                           {  reserviert Speicher }
  InitTextGraf:= 0;
  if ModeNr <> $FF then exit;           { wurde schon aufgerufen, alles ok }
  InitTextGraf:= -1;                    { Fehlervorgabe: falsche Karte }
  if IsEGA then VMonitor:= EGA;         { EGA ? }
  if IsVGA then VMonitor:= VGA;         { oder VGA ? }
  TMode:= BMode and $7f;
  if TMode = 7 then
  begin
    TScreen:= ptr($B000,0);     { Bildspeicheradresse Text mono setzen }
    if VMonitor = other then    { keines von beiden: }
    begin
      VMonitor:= Hercules;      { dann Hercules, (evtl Probleme mit CGA-Mono)}
      GMode:= 7;                { Modi alle 7 }
    end;
  end else
    TScreen:= ptr($B800,0);     { Bildspeicheradresse Text farbig setzen }
  if VMonitor = other then exit;        { was anderes? geht nicht! }
  InitTextGraf:= 1;                     { Fehlervorgabe: kein Speicher }
  if VMonitor in [EGA, VGA] then
  begin                                 { Vorgaben fÅr EGA & VGA }
    GMode:= $10;                        { Grafik 640x350 }
    if MaxAvail >= sizeof(CGBuf) then   { Speicher fÅr Puffer belegen }
      New(CGBuf)
    else
      exit;                             { raus mit Fehler 1 }
  end;
  if MaxAvail >= sizeof(ScrBuf) then    { noch mehr }
    New(ScrBuf)
  else
    exit;                               { raus mit Fehler 1 }
  ModeNr:= TMode;                       { Initialisierung merken }
  InitTextGraf:= 0;                     { alles ok }
end;

procedure SetPaletteSave(On: boolean);
             { aktiviert oder deaktiviert die automatische Palettensicherung }
begin
  if ModeNr = $FF then NoInitStop;    { schon Init ? }
  if On then
  begin
    if VGATextPal = nil then            { gibts schon ? }
      new(VGATextPal);                  { nein, neu }
    if VGAGraphPal = nil then           { dito Grafikpalette }
      new(VGAGraphPal);
    GetVGAColors(VGATextPal^);          { Textfarben holen }
  end else
  begin
    if VGATextPal <> nil then           { was da ? }
    begin
      dispose(VGATextPal);              { freigeben }
      VGATextPal:= nil;                 { und kennzeichnen }
    end;
    if VGAGraphPal <> nil then          { andere auch }
    begin
      dispose(VGAGraphPal);
      VGAGraphPal:= nil;
    end;
  end;
end;

procedure ToText;       { Schaltet in Textmodus, bringt, was Åberschrieben }
begin                   {  wird in Sicherheit }
  if ModeNr = $FF then NoInitStop;    { schon Init ? }
  GMode:= BMode;                { Grafikmodus merken }
  case VMonitor of
    VGA: begin
           if VGAGraphPal <> nil then
             GetVGAColors(VGAGraphPal^);
           ToTextVGA;             { Zeichengeneratorbereich sichern }
         end;
    EGA: ToTextEGA;
  end; {case}
  if VMonitor = Hercules then
    HercTextMode        { Hercules Textmodus ohne Bildspeicher lîschen }
  else
  begin
    regs.ax:= TMode or $80; { Text, Bit 7 = 1: Bildspeicher nicht lîschen }
    intr($10, regs);
    if (VMonitor = VGA) and (VGATextPal <> nil) then
        SetVGAColors(VGATextPal^);
  end;
  scrbuf^:= TScreen^;    { Grafikinhalt von Textschirm sichern }
  VModus:= Text;
end;

procedure ToGraph;     { versucht den Grafikmodus zu restaurieren }
begin
  if ModeNr = $FF then NoInitStop;    { schon Init ? }
  TMode:= BMode;
  TScreen^:= ScrBuf^;   { Grafikinhalt zurÅck in Textbildschirm fÅllen }
  case VMonitor of
    VGA: begin
           if VGATextPal <> nil then
             GetVGAColors(VGATextPal^);
           ToGraphVGA;    { dito Zeichengenerator }
         end;
    EGA: ToGraphEGA;
  end; {case}
  if VMonitor = Hercules then
    HercGraphMode               { Hercules handmade Grafikmodus }
  else
  begin
    regs.ax:= GMode or $80; { Text, Bit 7 = 1: Bildspeicher nicht lîschen }
    intr($10, regs);
    if (VMonitor = VGA) and (VGAGraphPal <> nil) then
        SetVGAColors(VGAGraphPal^);
  end;
  VModus:= Grafik;
end;

end.
