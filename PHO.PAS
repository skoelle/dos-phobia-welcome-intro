{$A-,B-,D-,E-,F-,G-,I-,L-,N-,O-,R-,S-,V-,X-}
{$M 16384,0,59360}
uses crt,textgraf,pho_u,pho_u2;
const rot:array[0..1] of integer=(1,0);
      VERSION='1.3';
      FADE_SPEED=10;
      TANZ=10;
      text:array[1..6*TANZ] of string[30]=('PRESENTS'
                                      ,'WELCOME'
                                      ,'---------------'
                                      ,''
                                      ,'PC INTRO BY'
                                      ,'STEFAN KOELLE'
                                      ,'[[[[[[[[[['
                                      ,'[ PHOBIA ['
                                      ,'[  1994  ['
                                      ,'[ """""" ['
                                      ,'[ BY NST ['
                                      ,'[[[[[[[[[['
                                      ,''
                                      ,'CREDITS'
                                      ,'------'
                                      ,'CODING BY'
                                      ,'STEFAN'
                                      ,''
                                      ,''
                                      ,'CREDITS'
                                      ,'------'
                                      ,'GFX BY'
                                      ,'STEFAN'
                                      ,''
                                      ,''
                                      ,'CREDITS'
                                      ,'------'
                                      ,'MUSIC'
                                      ,'RIPPED'
                                      ,''
                                      ,''
                                      ,'CREDITS'
                                      ,'------'
                                      ,'IDEA FROM AN'
                                      ,'AMIGA DEMO'
                                      ,''
                                      ,''
                                      ,'SPECIAL GREETINGS'
                                      ,'----------------'
                                      ,'MAD DOC'
                                      ,'M T L'
                                      ,''
                                      ,''
                                      ,'NORMAL GREETINGS'
                                      ,'---------------'
                                      ,'SATAN CLAUS'
                                      ,'MAJ-SOFT'
                                      ,''
                                      ,''
                                      ,'INFO'
                                      ,'-------'
                                      ,'CODED 1994'
                                      ,'ON 486 DX50'
                                      ,''
                                      ,''
                                      ,'BYE BYE'
                                      ,'------'
                                      ,'PRESS ANY'
                                      ,'KEY'
                                      ,'');
var
 dev,mix,stat,pro,loop : integer;
 md : string;
  i,txtz,txti,j,x,y,k:integer;
  r,ri:real;
  rb:boolean;
  w:word;
  p:vgacolors;
  l:vgacolors;
  cyc:array[0..2] of byte;
  cy2:array[0..2,1..10] of byte;
  s:string;
  ch:char;
  font : array[1..57,0..15,0..17] of byte;
{$L MOD-obj.OBJ} 	        { Link in Object file }
{$F+} 				{ force calls to be 'far'}
procedure modvolume(v1,v2,v3,v4:integer); external ; {Can do while playing}
procedure moddevice(var device:integer); external ;
procedure modsetup(var status:integer;device,mixspeed,pro,loop:integer;var str:string); external ;
procedure modstop; external ;
procedure modinit; external;
{$F-}
procedure ch_pal;
var x,y,i,j:integer;
begin
    inc(k);
    if k=3 then begin
    k:=0;
    for i:=0 to 2 do cyc[i]:=p[94,i];
    for j:=93 downto 80 do
      for i:=0 to 2 do p[j+1,i]:=p[j,i];
    for i:=0 to 2 do p[80,i]:=cyc[i];
    end;
    for y:=0 to 1 do
      for x:=1 to 5 do
      for i:=0 to 2 do cy2[i,x+y*5]:=p[16+x-1+y*25+20,i];
    for y:=0 to 1 do
      for x:=1 to 5 do
      for j:=1 to 4 do
      for i:=0 to 2 do p[35+x+y*25-j*5+5,i]:=p[35+x+y*25-j*5,i];
    for y:=0 to 1 do
      for x:=1 to 5 do
      for i:=0 to 2 do p[16+x-1+y*25,i]:=cy2[i,(x+rot[y]*5)];
    ri:=ri+1;
    if ri>372 then ri:=ri-372;
    if sin(ri*6.3)*15<0 then begin
      r:=r-sin(ri*6.3)*15;
      rb:=FALSE;
    end else begin
      r:=r+sin(ri*6.3)*15;
      rb:=TRUE;
    end;
    if r>20 then begin
      r:=r-20;
    if rb then begin
    for y:=0 to 1 do
      for x:=1 to 5 do
      for i:=0 to 2 do cy2[i,x+y*5]:=p[20+(x-1)*5+y*25,i];
    for y:=0 to 1 do
      for j:=1 to 4 do
      for x:=1 to 5 do
      for i:=0 to 2 do p[20+(x-1)*5+y*25-j+1,i]:=p[20+(x-1)*5+y*25-j,i];
    for y:=0 to 1 do
      for x:=1 to 5 do
      for i:=0 to 2 do p[20+(x-1)*5+y*25-4,i]:=cy2[i,x+rot[y]*5];
    end else begin
    for y:=0 to 1 do
      for x:=1 to 5 do
      for i:=0 to 2 do cy2[i,x+y*5]:=p[16+(x-1)*5+y*25,i];
    for y:=0 to 1 do
      for j:=1 to 4 do
      for x:=1 to 5 do
      for i:=0 to 2 do p[16+(x-1)*5+y*25+j-1,i]:=p[16+(x-1)*5+y*25+j,i];
    for y:=0 to 1 do
      for x:=1 to 5 do
      for i:=0 to 2 do p[20+(x-1)*5+y*25,i]:=cy2[i,x+rot[y]*5];
    end;
    end;
end;
procedure writeline(wly : integer; wls : string);
var i,x,y,num,wlx:integer;
begin
  wlx:=160-length(wls)*9+14;
  for i:=1 to length(wls) do
  for x:=0 to 15 do for y:=0 to 17 do begin
    if wls[i]<>' ' then begin
    case wls[i] of
      'A'..'Z':num:=ord(wls[i])-64;
      '0'..'9':num:=ord(wls[i])-19;
      '*':num:=39;
      '"':num:=40;
      '!':num:=41;
      '$':num:=42;
      ':':num:=43;
      '.':num:=44;
      ',':num:=45;
      '\':num:=46;
      '?':num:=47;
      '-':num:=48;
      '+':num:=49;
      '=':num:=50;
      '[':num:=51;
      ']':num:=52;
      '%':num:=53;
      '(':num:=54;
      ')':num:=55;
    end;
    if font[num,x,y]<>0 then mem[$A000:(wly+y)*word(320)+wlx+x+(i-1)*16]:=font[num,x,y];
    end;
  end;
end;
procedure writeback(wly : integer; wls : string);
var i,x,y,num,wlx:integer;
begin
  wlx:=160-length(wls)*9+14;
  for i:=1 to length(wls) do
  for x:=0 to 15 do for y:=0 to 17 do begin
    if wls[i]<>' ' then begin
    case wls[i] of
      'A'..'Z':num:=ord(wls[i])-64;
      '0'..'9':num:=ord(wls[i])-19;
      '*':num:=39;
      '"':num:=40;
      '!':num:=41;
      '$':num:=42;
      ':':num:=43;
      '.':num:=44;
      ',':num:=45;
      '\':num:=46;
      '?':num:=47;
      '-':num:=48;
      '+':num:=49;
      '=':num:=50;
      '[':num:=51;
      ']':num:=52;
      '%':num:=53;
      '(':num:=54;
      ')':num:=55;
    end;
    if (font[num,x,y]<>0) then mem[$A000:(wly+y)*word(320)+wlx+x+(i-1)*16]
                             :=mem[seg(phopic):ofs(phopic)+(wly+y)*word(320)+wlx+x+(i-1)*16];
    end;
  end;
end;
procedure CLI; inline( $FA );                { Interrupts unterdrcken }
procedure STI; inline( $FB );             { Interrupts wieder erlauben }
begin
  CLI;
  modinit;
  clrscr;
  writeln('PHOB­A Intro');
  writeln('------------');
  writeln;
  writeln('F1 -PC Speaker     (10000 kHz)');
  writeln('F2 -PC Speaker     (20000 kHz)');
  writeln('F3 -SoundBlaster   (10000 kHz)');
  writeln('F4 -SoundBlaster   (20000 kHz)');
  writeln('F5 -D/A Wandler    (10000 kHz)');
  writeln('F6 -D/A Wandler    (20000 kHz)');
  writeln('F7 -Disney Source  (10000 kHz)');
  writeln('F8 -Disney Source  (20000 kHz)');
  writeln('F9 -PC Speaker     (????? kHz)');
  writeln('F10-SoundBlaster   (????? kHz)');
  writeln('ESC-No Sound');
  writeln;
  writeln('Press F1-F10 or ESC...');
  i:=1;
  repeat
    ch:=readkey;
    if ch=#27 then begin
      i:=0;
      dev:=255;
    end;
    if ch='+' then begin
      clrscr;
      writeln('Intro by: Stefan Koelle of Phobia * Version '+VERSION);
      writeln('Intro skipped !!!');
      STI;
      halt(1);
    end;
    if ch=#0 then begin
      ch:=readkey;
      if (ord(ch)>58) and (ord(ch)<69) then i:=0;
    end;
  until i=0;
  case ord(ch) of
    59:begin
         dev := 0;
         mix := 10000;
       end;
    60:begin
         dev := 0;
         mix := 20000;
       end;
    61:begin
         dev := 7;
         mix := 10000;
       end;
    62:begin
         dev := 7;
         mix := 20000;
       end;
    63:begin
         dev := 1;
         mix := 10000;
       end;
    64:begin
         dev := 1;
         mix := 20000;
       end;
    65:begin
         dev := 11;
         mix := 10000;
       end;
    66:begin
         dev := 11;
         mix := 20000;
       end;
    67:begin
         dev := 0;
         writeln;
         write('Enter Sample-Frequence (<=44000 kHz): ');
         readln(mix);
       end;
    68:begin
         dev := 7;
         writeln;
         write('Enter Sample-Frequence (<=20000 kHz): ');
         readln(mix);
       end;
  end;
  if (dev<>255) then begin
  if paramcount=1 then begin
    md:=paramstr(1);
  end else begin
    md:='pho.rsc';
  end;
  pro := 0; {Leave at 0}
  loop :=4; {4 means mod will play forever}
  modvolume (255,255,255,255);    { Full volume }
  end;
  case InitTextGraf of
     1: begin end;
  end;
  GrafikMode($13);
  for w:=0 to 63999 do mem[$A000:w]:=0;
  for i:=0 to 255 do for j:=0 to 2 do
    l[i,j]:=0;
  setvgacolors(l);
  for w:=0 to 63999 do mem[$A000:w]:=mem[seg(phofnt):ofs(phofnt)+w];
  for j:=0 to 1 do for i:=0 to 18 do
  for x:=0 to 15 do for y:=0 to 17 do
    font[i+j*19+1,x,y]:=mem[$A000:(y+j*18+1)*word(320) + x+i*16];
  j:=2; for i:=0 to 18 do
  for x:=0 to 15 do for y:=0 to 17 do
    font[i+j*19+1,x,y]:=mem[$A000:(y+j*18+2)*word(320) + x+i*16];
  for w:=0 to 63999 do mem[$A000:w]:=mem[seg(phopic):ofs(phopic)+w];
  for i:=1 to 6 do
  writeline(53+i*20,text[i]);

  move(mem[seg(phopal):ofs(phopal)],p,sizeof(p));
  k:=0;ri:=0;r:=0;
  for x:=(40 div FADE_SPEED) downto 0 do begin
  ch_pal;
  for i:=0 to 255 do for j:=0 to 2 do begin
    l[i,j]:=p[i,j]-x*FADE_SPEED;
    if l[i,j]>p[i,j] then l[i,j]:=0;
  end;
  repeat until port[$3da] and 8 = 8;
  setvgacolors(l);
  end;
  ch:='@';
  txtz:=0;txti:=0;
  if (dev<>255) then modsetup ( stat, dev, mix, pro, loop, md );
  STI;
  repeat
    inc(txtz);
    if txtz>150 then begin
      txtz:=0;
      j:=txti;
      inc(txti);
      if txti=TANZ then txti:=0;
      for i:=1 to 6 do begin
        ch_pal;
        setvgacolors(p);
        writeback(53+i*20,text[i+j*6]);
        ch_pal;
        setvgacolors(p);
        writeline(53+i*20,text[i+txti*6]);
      end;
    end;
    inc(k);
    if k=3 then begin
    k:=0;
    for i:=0 to 2 do cyc[i]:=p[94,i];
    for j:=93 downto 80 do
      for i:=0 to 2 do p[j+1,i]:=p[j,i];
    for i:=0 to 2 do p[80,i]:=cyc[i];
    end;
    for y:=0 to 1 do
      for x:=1 to 5 do
      for i:=0 to 2 do cy2[i,x+y*5]:=p[16+x-1+y*25+20,i];
    for y:=0 to 1 do
      for x:=1 to 5 do
      for j:=1 to 4 do
      for i:=0 to 2 do p[35+x+y*25-j*5+5,i]:=p[35+x+y*25-j*5,i];
    for y:=0 to 1 do
      for x:=1 to 5 do
      for i:=0 to 2 do p[16+x-1+y*25,i]:=cy2[i,(x+rot[y]*5)];
    ri:=ri+1;
    if ri>372 then ri:=ri-372;
    if sin(ri*6.3)*15<0 then begin
      r:=r-sin(ri*6.3)*15;
      rb:=FALSE;
    end else begin
      r:=r+sin(ri*6.3)*15;
      rb:=TRUE;
    end;
    if r>20 then begin
      r:=r-20;
    if rb then begin
    for y:=0 to 1 do
      for x:=1 to 5 do
      for i:=0 to 2 do cy2[i,x+y*5]:=p[20+(x-1)*5+y*25,i];
    for y:=0 to 1 do
      for j:=1 to 4 do
      for x:=1 to 5 do
      for i:=0 to 2 do p[20+(x-1)*5+y*25-j+1,i]:=p[20+(x-1)*5+y*25-j,i];
    for y:=0 to 1 do
      for x:=1 to 5 do
      for i:=0 to 2 do p[20+(x-1)*5+y*25-4,i]:=cy2[i,x+rot[y]*5];
    end else begin
    for y:=0 to 1 do
      for x:=1 to 5 do
      for i:=0 to 2 do cy2[i,x+y*5]:=p[16+(x-1)*5+y*25,i];
    for y:=0 to 1 do
      for j:=1 to 4 do
      for x:=1 to 5 do
      for i:=0 to 2 do p[16+(x-1)*5+y*25+j-1,i]:=p[16+(x-1)*5+y*25+j,i];
    for y:=0 to 1 do
      for x:=1 to 5 do
      for i:=0 to 2 do p[20+(x-1)*5+y*25,i]:=cy2[i,x+rot[y]*5];
    end;
    end;
    repeat until port[$3da] and 8 = 8;
    setvgacolors(p);
  until keypressed;
  ch:=readkey;
  CLI;
  if (dev<>255) then modstop;
  for x:=1 to (40 div FADE_SPEED) do begin
  ch_pal;
  for i:=0 to 255 do for j:=0 to 2 do begin
    if p[i,j]<FADE_SPEED then p[i,j]:=0 else dec(p[i,j],FADE_SPEED);
  end;
  repeat until port[$3da] and 8 = 8;
  setvgacolors(p);
  end;
  for w:=0 to 63999 do mem[$A000:w]:=0;
  TEXTMODE(co80);
  clrscr;
  writeln('Intro by: Stefan Koelle of Phobia * Version '+VERSION);
  STI;
end.