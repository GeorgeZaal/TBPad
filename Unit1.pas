unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Grids, ExtCtrls, Buttons, Menus, MMSystem;

type
  TForm1 = class(TForm)
    RichEdit1: TRichEdit;
    SGrid: TStringGrid;
    Timer1: TTimer;
    StatusBar1: TStatusBar;
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    Lb_Time: TLabel;
    Bevel1: TBevel;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    OpenDialog1: TOpenDialog;
    procedure RichEdit1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure StatusBar1DblClick(Sender: TObject);
  private
    procedure GetAttr(Line : Integer; AttrString : String);
    procedure ReSearch;
    procedure ToTable;
    procedure Start;
    procedure Stop;
    procedure _Pause;
    procedure SetRichEdit;
    procedure PlaySignal;
    function Check_New_Task(NewTask : string): boolean;
    function Test_Shift: boolean;
    function Show_Time: string;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  K : TPoint; // ���������� ��� ������� RichEdit'a
  WorkString : String; // ���������� ��� ������� ������
  col_work_items : integer; // ���������� ������� �������
  total_sec : integer; // ����� ����������� ������
  num_item_in_work : integer; // ����������� ������ �������
  pause : boolean;

implementation

{$R *.dfm}

// ������� �������� ������������ ������ ��������/����������� ������
function TForm1.Check_New_Task(NewTask : string): boolean;
var
  _i, _t : integer;
  _time : string;
begin
  _t:=0;   // *** ��� ������ ���� ��� ��������, Ũ ���� �������� � ���������� ������! ***
  _time := Copy(NewTask, Pos(' -- ', NewTask)+4, Length(NewTask) - (Pos(' -- ', NewTask)+3));
  for _i := 1 to Length(_time) do
    case _time[_i] of '0'..'9' : inc(_t);
    end;
// ���� 1) ������ ������ ����� ��������� � ������� ������ 0 � ������ 4,
// � 2) ���������� ���� �� ������ ����� ����� ���� ����,
// ������, ������� �����������:
  if (Length(_time) > 0) and
    (Length(_time) < 4) and
	(Length(_time) = _t) then
	  Check_New_Task := true
  else
    Check_New_Task := false;
// ������� ��������������: 1) c������ ������� 2) �������� �������� ������ �/��� 3) ��� ���������� ������� 3) ����� - ����
  if (Length(NewTask) > 80) or
    (Length(NewTask)- _t <= 4 ) or
    (Pos(' -- ', NewTask) = 0) or
    (_time = '0') then
	  Check_New_Task := false;
end;

// ���������� ��������� � ��������� ������:
procedure TForm1.GetAttr(Line : Integer; AttrString: String);
begin
  // Line := RichEdit1.CaretPos.Y;
  // �������� ������ ������ (������� � Line)
  RichEdit1.SetFocus;
  RichEdit1.SelStart  := RichEdit1.Perform(EM_LINEINDEX, Line, 0);
  RichEdit1.SelLength := Length(RichEdit1.Lines[Line]);
  // ����������� �� ���������:
  if AttrString = '�������' then
//    RichEdit1.SelAttributes.Color := clRed;
    RichEdit1.SelAttributes.Style := [fsBold];
  if AttrString = '�������' then
//    RichEdit1.SelAttributes.Color := clBlack;
    RichEdit1.SelAttributes.Style := [];
  if AttrString = '�������' then
    RichEdit1.SelAttributes.Color := clRed;
  if AttrString = '���������' then
    RichEdit1.SelAttributes.Color := clBlack;
  // ���������� ������� �� �������� �������:
  RichEdit1.CaretPos := K;
end;

procedure TForm1.RichEdit1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // ���������� ��������� �������:
  K.Y := RichEdit1.CaretPos.Y;
  K.X := RichEdit1.CaretPos.X;
  // ���������� �������� ������ � ������� ����������:
  WorkString := RichEdit1.Lines[RichEdit1.CaretPos.Y];
  // ���������:
//  caption := '������ - ' + inttostr(RichEdit1.CaretPos.Y) + ' : ' + WorkString;
  // ��������� ������� ������:
  // �������� ������ ����������� �� �������� ������ � �������,
  // � ����� ������ ��� �������:
  if Test_Shift = true then exit;                         // ����� �� ������ ��������
  if (Key = VK_RETURN) or
    (Key = VK_BACK) or
    (Key = VK_PRIOR) or
    (Key = VK_NEXT) or
    (Key = VK_DELETE) or
    (Key = VK_SPACE) or
    (Key = VK_RIGHT) or
    (Key = VK_LEFT) then
//    (ssCtrl in Shift) or
//    (KEY = VK_INSERT) then
    begin
      if Check_New_Task(WorkString) = true then GetAttr(K.Y, '�������') else GetAttr(K.Y, '�������');
      // ���� ������ � ������� �����������, �� - ��������� ����������:
      if Check_New_Task(RichEdit1.Lines[K.Y - 1]) = true then GetAttr(K.Y - 1, '�������') else GetAttr(K.Y - 1, '�������');
    end;
  if (Key = VK_UP) then
    if Check_New_Task(RichEdit1.Lines[K.Y + 1]) = true then GetAttr(K.Y + 1, '�������') else GetAttr(K.Y + 1, '�������');
  if (Key = VK_DOWN) then
    if Check_New_Task(RichEdit1.Lines[K.Y - 1]) = true then GetAttr(K.Y - 1, '�������') else GetAttr(K.Y - 1, '�������');
// *** �������� �������� ����� �������� ����� ������� � pgDowm/Up ***
end;

// ������������ ����� ��������:
procedure TForm1.ReSearch;
var
  i : integer;
begin
  // ���������� ��������� �������:
  K.Y := RichEdit1.CaretPos.Y;
  K.X := RichEdit1.CaretPos.X;
  // ���� ��������:
  col_work_items := 0;
  for i := 0 to RichEdit1.Lines.Count do
    if Check_New_Task(RichEdit1.Lines[i]) = true then
      begin
        GetAttr(i, '�������');
        col_work_items := col_work_items + 1;
      end
      else
        GetAttr(i, '�������');
  // ���������� ������� �� �������� �������:
  RichEdit1.CaretPos := K;
end;

// �������� �� ������� ����:
function TForm1.Test_Shift:boolean;
Var
  State : TKeyboardState;
Begin
  GetKeyboardState(State);
  If ((State[16] and 128) <> 0) Then
    Test_Shift := true
  Else
    Test_Shift := false;
End;

// ��������� � �������:
procedure TForm1.ToTable;
var
  i, j, onpos, t_time : integer;
  Itm : string;
begin
  research;
  if col_work_items = 0 then   // �������� �� ������� �����. ���� ��� - �� ���������
    exit;
  i := 0;
  j := 0;
  t_time := 0;
  SGrid.RowCount := col_work_items;
  for i := 0 to RichEdit1.Lines.Count do
    begin
    if Check_New_Task(RichEdit1.Lines[i]) = true then
      begin
       Itm := RichEdit1.Lines[i];      // Itm - ��� �������� ������ � ���������� ����
       SGrid.Cells[0, j] := IntToStr(i);   // ����� ������ � ������������ �������
       SGrid.Cells[2, j] := Copy(Itm, Pos(' -- ', Itm)+4, Length(Itm) - (Pos(' -- ', Itm)+3));   // �����
       onPos := AnsiPos(' -- ', Itm);  // �������� �� ���� ������ ����� ������� ������ � --:
       SetLength(Itm, onPos - 1);
       SGrid.Cells[1, j] := Itm;       // ���������
       SGrid.Cells[3, j] := '';        // ������� � �����������
       SGrid.Cells[2, j] := inttostr(strtoint(SGrid.Cells[2, j]) * 60); // �������� �� 60 ������ �����
       j := j + 1;
      end;
    end;
  // ���������� ����������:
  for i := 0 to SGrid.RowCount-1 do
    if StrToInt(SGrid.Cells[0, i]) = RichEdit1.CaretPos.Y then
      SGrid.Cells[3, i] := '*';
  // ���� ����� ���, �� ������� ������� ��� ������� (����� � �����-������ ������ ������ ����� �������)
  if col_work_items = 0 then
    begin
      SGrid.Cells[0, 0] := '';
      SGrid.Cells[1, 0] := '';
      SGrid.Cells[2, 0] := '';
      SGrid.Cells[3, 0] := '';
      StatusBar1.Panels[0].Text := '���������� �����: ';
      StatusBar1.Panels[1].Text := '����� �����: ';
    end else
    begin
      // ���� ������ ����, �� - ���������� � ���������:
      StatusBar1.Panels[0].Text := '���������� �����: ' + inttostr(SGrid.RowCount);
      for i := 0 to SGrid.RowCount-1 do
        t_time := t_time + strtoint(SGrid.Cells[2, i]);
      if t_time < 3600 then
        StatusBar1.Panels[1].Text := '����� �����: ' + inttostr(t_time div 60) + ' ���.'
      else
        StatusBar1.Panels[1].Text := '����� �����: ' + inttostr((t_time div 60) div 60) + ' �., ' + inttostr((t_time div 60) mod 60) + ' ���.';
    end;
end;

procedure TForm1.Start;
var
  i : integer;
begin

totable;

RichEdit1.ReadOnly := true;

SpeedButton1.Enabled := false;

if SGrid.Cells[0, 0] = '' then exit;

if pause = false then
  begin
  // ���� ����� ����������� ������:
  for i := 0 to SGrid.RowCount-1 do
    if SGrid.Cells[3, i] = '*' then
      begin
        total_sec := strtoint(SGrid.Cells[2, i]);
        num_item_in_work := i;
        GetAttr(strtoint(SGrid.Cells[0, i]), '�������');
          // ��������� ������:
  timer1.Enabled := true;
      end;
  end
  else
  begin
    pause := false;
    // ��������� ������:
    timer1.Enabled := true;
  end;
end;

// ������� ������� � ������ ��:��
function Tform1.Show_Time: string;
var
  _min, _sec : integer;
  _min_full, _sec_full : string;
begin
  _min := total_sec div 60;
  _sec := total_sec mod 60;
  // ��������� ���� � �������, ���� �����:
  if _min < 10 then
    _min_full := '0' + inttostr(_min)
  else
    _min_full := inttostr(_min);
  // ��������� ���� � ��������, ���� �����:
  if _sec < 10 then
    _sec_full := '0' + inttostr(_sec)
  else
    _sec_full := inttostr(_sec);
  // ������� �����:
  Show_Time := _min_full + ':' + _sec_full;
end;

// ��������� ������������ �������:
procedure TForm1.PlaySignal;
var
  addr_snd : pchar;
begin
  addr_snd := PChar(GetCurrentDir() + '\k_tone.wav');
  PlaySound(addr_snd, 0, SND_FILENAME);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  i : integer;
begin
  total_sec := total_sec - 1;
//                label1.Caption := inttostr(total_sec);
  lb_time.Caption := Show_Time;
  // ���� ������ ���������, �� ��� � ����������:
  if (total_sec = 0) and (SGrid.RowCount = num_item_in_work + 1) then
    begin
      timer1.Enabled := false;
      lb_time.Caption := '00:00';
      GetAttr(strtoint(SGrid.Cells[0, num_item_in_work]), '���������');
      PlaySignal;
    end;
  // ���� ������ �� ���������, �� ��� � ����������:
  if (total_sec = 0) and (SGrid.RowCount <> num_item_in_work + 1) then
    begin
      // ������� ������ � �����������:
      for i := 0 to SGrid.RowCount - 1 do SGrid.Cells[3, i] := '';
      // ������������� ������� �� ����� ����� ����������:
      SGrid.Cells[3, num_item_in_work + 1] := '*';
      // ������ ���� ����� �������:
      num_item_in_work := num_item_in_work + 1;
      // ������������� �� ���� ����� �����:
      total_sec := strtoint(SGrid.Cells[2, num_item_in_work]);
      // ����������� ������� ������:
      GetAttr(strtoint(SGrid.Cells[0, num_item_in_work]), '�������');
      // ����������� ������ ���������� �������:
      GetAttr(strtoint(SGrid.Cells[0, num_item_in_work - 1]), '���������');
      // ��������� ������:
      K.X := 0;
      K.Y := strtoint(SGrid.Cells[0, num_item_in_work]);
      RichEdit1.CaretPos := K;
      // ����������� ����:
      PlaySignal;
    end;
end;

procedure TForm1._Pause;
begin
  pause := true;
  Timer1.Enabled := false;
  SpeedButton1.Enabled := true;
  richedit1.Enabled := true;
end;

procedure TForm1.SetRichEdit;
begin
  richedit1.Font.Size := 15;
  richedit1.Font.Charset := ANSI_CHARSET;
  richedit1.Font.Name := 'Calibri';
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  pause := false;
  SetRichEdit;
end;

procedure TForm1.Stop;
begin
   Timer1.Enabled := false;
   SpeedButton1.Enabled := true;
   richedit1.Enabled := true;
   GetAttr(strtoint(SGrid.Cells[0, num_item_in_work]), '���������');
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  Start;
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
  _Pause;
end;

procedure TForm1.SpeedButton3Click(Sender: TObject);
begin
  Stop;
end;

procedure TForm1.N7Click(Sender: TObject);
begin
  SetRichEdit;
  if OpenDialog1.Execute = true then
    RichEdit1.Lines.LoadFromFile(Opendialog1.FileName);
  SetRichEdit;
end;

procedure TForm1.StatusBar1DblClick(Sender: TObject);
begin
  ToTable;
end;

end.
