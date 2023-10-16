object Form1: TForm1
  Left = 192
  Top = 124
  Width = 1142
  Height = 656
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object RichEdit1: TRichEdit
    Left = 112
    Top = 136
    Width = 369
    Height = 217
    Lines.Strings = (
      'RichEdit1')
    TabOrder = 0
    OnKeyUp = RichEdit1KeyUp
    OnMouseDown = RichEdit1MouseDown
  end
  object Memo1: TMemo
    Left = 768
    Top = 224
    Width = 185
    Height = 305
    TabOrder = 1
  end
end
