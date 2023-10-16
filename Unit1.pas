unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TForm1 = class(TForm)
    RichEdit1: TRichEdit;
    Memo1: TMemo;
    procedure GetAttr(Line : Integer; AttrString: String);
    function Check_x(NewTask, Sign : string): boolean;
    procedure RichEdit1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure RichEdit1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

//Здесь необходимо описать класс TMyThread для потока:
  TMyThread = class(TThread)
    private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

const
  active_text = clYellow;
  main_text = clBlack;

var
  Form1: TForm1;
  MyThread: TMyThread; // Переменная потока
  K : TPoint; // Переменная для каретки RichEdit'a

implementation

{$R *.dfm}

// Нужно создать процедуру Execute, уже описанную в классе TMyThread
procedure TMyThread.Execute;
begin
// Здесь описывается код, который будет выполняться в потоке

// Запоминаем положение каретки:
  K.Y := Form1.RichEdit1.CaretPos.Y;
  K.X := Form1.RichEdit1.CaretPos.X;
  Form1.Caption := inttostr(K.Y);

// Выделяем строчку c 'x':
  if Form1.Check_x(Form1.richedit1.Lines[K.Y], 'x') = true then
     Form1.GetAttr(K.Y, 'Зачёркнутая');
  if Form1.Check_x(Form1.richedit1.Lines[K.Y], 'x') = false then
     Form1.GetAttr(K.Y, 'Базовая');
// Выделяем строчку с '#':
  if Form1.Check_x(Form1.richedit1.Lines[K.Y], '#') = true then
     Form1.GetAttr(K.Y, 'Заголовок');
  if Form1.Check_x(Form1.richedit1.Lines[K.Y], '#') = false then
     Form1.GetAttr(K.Y, 'Без заголовка');


end;

function TForm1.Check_x(NewTask, Sign : string): boolean;
var
  i, j : integer;
  f_p, s_p : boolean;
  first_part, second_part : string;
begin
  f_p := false;
  s_p := false;
// Если строчка мала:
  if length(NewTask) < 3 then exit;
// Если х в начале:
  if (NewTask[1] = Sign) and
    (NewTask[2] = ' ') then
      begin
        first_part := '';
	   	  second_part := copy(NewTask, 2, length(NewTask)-1);
        f_p := true;
      end;
// Если х в середине, но не за два символа до конца:
  for i := 2 to length(NewTask) - 2 do
    if (NewTask[i] = Sign) and
	    (NewTask[i + 1] = ' ') and
	    (NewTask[i - 1] = ' ')
    then
   	  begin
	      first_part := copy(NewTask, 1, i-1);
	     	second_part := copy(NewTask, i+1, length(NewTask)-i);
        break;     // Выход, чтобы не искал второй икс
      end;
		// проверка первой части:
    if length(first_part) <> 0 then
  	  for i := 1 to length(first_part) do
		    if first_part[i] = ' ' then
			  f_p := true else
			  begin
			    f_p := false;
				  break;
			  end;
		// Проверка второй части:
    if length(second_part) >= 2 then
        for i := 1 to length(second_part) do
		    if second_part[i] = ' ' then
          s_p := false else
          begin
            s_p := true;
            break;
          end;
  if (f_p = true) and
    (s_p = true) then
	  Check_x := true else
	  Check_x := false;
end;

// Назначение атрибутов к указанной строке:
procedure TForm1.GetAttr(Line : Integer; AttrString: String);
begin
  // Line := RichEdit1.CaretPos.Y;
  // Выделяем нужную строку (указана в Line)
  RichEdit1.SetFocus;
  RichEdit1.SelStart  := RichEdit1.Perform(EM_LINEINDEX, Line, 0);
  RichEdit1.SelLength := Length(RichEdit1.Lines[Line]);
  // Присваеваем ей атрибруты:
  if AttrString = 'Зачёркнутая' then
    RichEdit1.SelAttributes.Style := [fsStrikeOut];
  if AttrString = 'Базовая' then
    RichEdit1.SelAttributes.Style := [];
  if AttrString = 'Заголовок' then
    RichEdit1.SelAttributes.Size := 14;
  if AttrString = 'Без заголовка' then
    RichEdit1.SelAttributes.Size := 8;
  // Возвращаем каретку на исходную позицию:
  RichEdit1.CaretPos := K;
end;

procedure TForm1.RichEdit1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
{// Запоминаем положение каретки:
  K.Y := RichEdit1.CaretPos.Y;
  K.X := RichEdit1.CaretPos.X;
// Выделяем строчку c 'x':
  if Check_x(richedit1.Lines[K.Y], 'x') = true then
     GetAttr(K.Y, 'Зачёркнутая');
  if Check_x(richedit1.Lines[K.Y], 'x') = false then
     GetAttr(K.Y, 'Базовая');
// Выделяем строчку с '#':
  if Check_x(richedit1.Lines[K.Y], '#') = true then
     GetAttr(K.Y, 'Заголовок');
  if Check_x(richedit1.Lines[K.Y], '#') = false then
     GetAttr(K.Y, 'Без заголовка');}
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
// Вначале нужно создать экземпляр потока:
  MyThread:=TMyThread.Create(False);
// Параметр False запускает поток сразу после создания, True - запуск впоследствии , методом Resume
// Далее можно указать параметры потока, например приоритет:
  MyThread.Priority:=tpNormal;
// Остановка потока, если понадобится:
//  MyThread.Terminate;


end;

procedure TForm1.RichEdit1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  test_string : string;
  i, j, del_lin : integer;
begin
  del_lin := 0;
  if (Button = mbLeft) and
    (ssDouble in Shift) then
      begin
        test_string := richedit1.Lines[RichEdit1.CaretPos.Y];
        if pos('<<<', test_string) > 0 then
        begin
          for i := RichEdit1.CaretPos.Y+1 to RichEdit1.Lines.Count do
            if RichEdit1.Lines[i] <> '' then
              begin
                memo1.Lines.Add(RichEdit1.Lines[i]);
                del_lin := del_lin + 1;
              end else
              begin
               for j := RichEdit1.CaretPos.Y+1+del_lin-1 {минус один - тогда останется пробел после списка} downto RichEdit1.CaretPos.Y+1 do
                  Richedit1.Lines.Delete(j);
               exit;
              end;
        end;

{               else
                begin
                  for j := RichEdit1.CaretPos.Y+1 to i do
                    // Заменить <<< на >>>
                  StringReplace(richedit1.Lines[RichEdit1.CaretPos.Y], '<<<', '>>>', [RFReplaceAll]);

//                  StringReplace(memo1.text, 'слово', st,[RFReplaceAll]);}
 //               end;



      end;

end;

end.
