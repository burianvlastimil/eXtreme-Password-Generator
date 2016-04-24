unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Spin, Clipbrd, Menus, ComCtrls, MaskEdit, ExtCtrls, Types, Math;

type

  TPassword = class
    private
      FPassword: string;
      function GetConcealed: string;
    public
      constructor Create; reintroduce;
      property Revealed: string read FPassword;
      property Concealed: string read GetConcealed;
  end;

  { TFormMain }

  TFormMain = class(TForm)
    BGenerateList: TButton;
    ChBIncludeDigits: TCheckBox;
    ChBIncludeLowerLetters: TCheckBox;
    ChBIncludeSpecialChars: TCheckBox;
    ChBIncludeUpperLetters: TCheckBox;
    ChBRevealPasswordsWhileHovering: TCheckBox;
    Digits: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    LLength: TLabel;
    ESpecialChars: TEdit;
    Label1: TLabel;
    LDoubleClickInfo: TLabel;
    LBPasswordList: TListBox;
    LowerCharacters: TLabel;
    MICopyPasswordIntoClipboard: TMenuItem;
    PRandSeed: TPanel;
    Panel2: TPanel;
    PMListBox: TPopupMenu;
    SpecialCharacters: TLabel;
    TBDigits: TTrackBar;
    TBLength: TTrackBar;
    TBLowercaseChars: TTrackBar;
    TBSpecialChars: TTrackBar;
    TBUppercaseChars: TTrackBar;
    UDPasswordCharCount: TSpinEdit;
    UDSpecialCharsMax: TSpinEdit;
    UpperCharacters: TLabel;
    procedure BGenerateListClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ChBIncludeLowerLettersChange(Sender: TObject);
    procedure ChBIncludeLowerLettersClick(Sender: TObject);
    procedure ChBIncludeSpecialCharsChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LBPasswordListClick(Sender: TObject);
    procedure LBPasswordListDblClick(Sender: TObject);
    procedure LBPasswordListMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure LBPasswordListMouseLeave(Sender: TObject);
    procedure LBPasswordListMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure MICopyPasswordIntoClipboardClick(Sender: TObject);
    procedure PRandSeedClick(Sender: TObject);
    procedure PRandSeedMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PMListBoxPopup(Sender: TObject);
    procedure TBDigitsChange(Sender: TObject);
    procedure TBDigitsMouseEnter(Sender: TObject);
    procedure TBDigitsMouseLeave(Sender: TObject);
    procedure TBLowercaseCharsChange(Sender: TObject);
    procedure TBLowercaseCharsMouseEnter(Sender: TObject);
    procedure TBLowercaseCharsMouseLeave(Sender: TObject);
    procedure TBUppercaseCharsChange(Sender: TObject);
    procedure TBUppercaseCharsMouseEnter(Sender: TObject);
    procedure TBUppercaseCharsMouseLeave(Sender: TObject);
    procedure TBSpecialCharsChange(Sender: TObject);
    procedure TBSpecialCharsMouseEnter(Sender: TObject);
    procedure TBSpecialCharsMouseLeave(Sender: TObject);
    procedure TBLengthChange(Sender: TObject);
    procedure TBLengthMouseEnter(Sender: TObject);
    procedure TBLengthMouseLeave(Sender: TObject);
    procedure TrackBarChange(Sender: TObject);
    procedure UDPasswordCharCountChange(Sender: TObject);
  private
    FShowSeed: Boolean;
    FDoubleClick: Boolean;
    function PossibleToGeneratePassword: Boolean;
    procedure ChangeRandSeed;
    procedure SatisfyMaxInputs(Sender: TObject);
  public
    function GeneratePassword: string;
    procedure GeneratePasswordList;
  end;

var
  FormMain: TFormMain;

implementation

{$R *.lfm}

const
  SPECIAL_CHARS = '.-_()[]{}/|\!#$%&*+,:;=?@^`~';

constructor TPassword.Create;
begin

  inherited;

  FPassword := FormMain.GeneratePassword;

end;

function TPassword.GetConcealed: string;

var
  S: string;
  I: Integer;

begin

  S := Revealed;

  for I := 1 to Length(S) do begin

    if Odd(I) then Continue;

    S[I] := '*';

  end;

  Result := S;

end;

function TFormMain.PossibleToGeneratePassword: Boolean;
begin

  Result := ChBIncludeDigits.Checked or ChBIncludeLowerLetters.Checked or ChBIncludeUpperLetters.Checked;

end;

procedure TFormMain.FormCreate(Sender: TObject);
begin

  Randomize;

  FShowSeed := False;

  FDoubleClick := False;

  ESpecialChars.Text := SPECIAL_CHARS;

end;

procedure TFormMain.FormShow(Sender: TObject);
begin

  GeneratePasswordList;

end;

procedure TFormMain.LBPasswordListClick(Sender: TObject);
begin

  if not FDoubleClick then begin

    LDoubleClickInfo.Caption := 'Double-click to copy password into clipboard';
    LDoubleClickInfo.Font.Style := [];

  end;

  FDoubleClick := False;

end;

procedure TFormMain.LBPasswordListDblClick(Sender: TObject);
begin

  FDoubleClick := True;

  if LBPasswordList.ItemIndex > -1 then
    MICopyPasswordIntoClipboardClick(nil);

end;

procedure TFormMain.LBPasswordListMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

  if LBPasswordList.Count > 0 then begin

    LBPasswordList.ItemIndex := LBPasswordList.ItemAtPos(Point(X, Y), True);

    if LBPasswordList.ItemIndex = -1 then
       LBPasswordList.ItemIndex := LBPasswordList.Count - 1;

  end;

end;

procedure TFormMain.LBPasswordListMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);

var
  I: Integer;
  HoverIndex: Integer;
  PasswordsCollection: TStringList;

begin

  PasswordsCollection := TStringList.Create;

  try

    for I := 0 to LBPasswordList.Count - 1 do
      PasswordsCollection.AddObject('', LBPasswordList.Items.Objects[I]);

    HoverIndex := LBPasswordList.ItemAtPos(Point(X, Y), True);

    if HoverIndex > -1 then begin

      LBPasswordList.Clear;

      for I := 0 to PasswordsCollection.Count - 1 do begin

        if (I = HoverIndex) and ChBRevealPasswordsWhileHovering.Checked
          then
            LBPasswordList.Items.AddObject((PasswordsCollection.Objects[I] as TPassword).Revealed, PasswordsCollection.Objects[I])
          else
            LBPasswordList.Items.AddObject((PasswordsCollection.Objects[I] as TPassword).Concealed, PasswordsCollection.Objects[I]);

      end;

    end else begin

      LBPasswordList.Items.AddObject((PasswordsCollection.Objects[PasswordsCollection.Count - 1] as TPassword).Concealed, PasswordsCollection.Objects[PasswordsCollection.Count - 1]);

      LBPasswordList.Items.Delete(PasswordsCollection.Count - 1);

    end;

  finally

    PasswordsCollection.Free;

  end;

end;

procedure TFormMain.LBPasswordListMouseLeave(Sender: TObject);

var
  I: Integer;
  PasswordsCollection: TStringList;

begin

  PasswordsCollection := TStringList.Create;

  try

    for I := 0 to LBPasswordList.Count - 1 do
      PasswordsCollection.AddObject('', LBPasswordList.Items.Objects[I]);

    LBPasswordList.Clear;

    for I := 0 to PasswordsCollection.Count - 1 do
      LBPasswordList.Items.AddObject((PasswordsCollection.Objects[I] as TPassword).Concealed, PasswordsCollection.Objects[I]);

  finally

    PasswordsCollection.Free;

  end;

end;

procedure TFormMain.MICopyPasswordIntoClipboardClick(Sender: TObject);
begin

  if LBPasswordList.ItemIndex > -1 then begin

    Clipboard.AsText := (LBPasswordList.Items.Objects[LBPasswordList.ItemIndex] as TPassword).Revealed;

    LDoubleClickInfo.Caption := 'Password has been copied into clipboard';
    LDoubleClickInfo.Font.Style := [fsbold];

  end;

end;

procedure TFormMain.PRandSeedClick(Sender: TObject);

var
  RandSeedStr: string;

begin

  FShowSeed := not FShowSeed;

  RandSeedStr := IntToStr(RandSeed);

  if not FShowSeed
    then PRandSeed.Caption := 'Seed = ' + RandSeedStr[1]  + '******' + RandSeedStr[Length(RandSeedStr)]
    else PRandSeed.Caption := 'Seed = ' + RandSeedStr;

end;

procedure TFormMain.GeneratePasswordList;
begin

  BGenerateList.Click;

end;

procedure TFormMain.ChangeRandSeed;

var
  RandSeedStr: string;

begin

  RandSeed := RandomRange(Low(RandSeed), High(RandSeed));

  RandSeedStr := IntToStr(RandSeed);

  if not FShowSeed
    then PRandSeed.Caption := 'Seed = ' + RandSeedStr[1]  + '******' + RandSeedStr[Length(RandSeedStr)]
    else PRandSeed.Caption := 'Seed = ' + RandSeedStr;


   GeneratePasswordList;

end;

procedure TFormMain.PRandSeedMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin

  ChangeRandSeed;

end;

procedure TFormMain.PMListBoxPopup(Sender: TObject);
begin

  MICopyPasswordIntoClipboard.Enabled := LBPasswordList.ItemIndex > -1;

end;

procedure TFormMain.SatisfyMaxInputs(Sender: TObject);

          function NormalizedPosition(const Pos: Integer): Integer;
          begin

            if Pos = -1
              then Result := 0
              else Result := Pos;

          end;

begin



    if Sender <> TBLength then begin

        if (Sender as TTrackBar).Position > TBLength.Position then
          TBLength.Position := (Sender as TTrackBar).Position;

    end else
  begin




      // nejdrive kontrolujeme, zda nektery progressBar nema vyssi hodnotu nez je delka klice
      // pokud nektery progressBar ma vyssi hodnotu, nez je delka klice, pak ho omezime na onu delku klice - spravne nebo spatne?


   if    (TBDigits.Position > TBLength.Position)
     then  TBDigits.Position := TBLength.Position;


      if    (TBLowercaseChars.Position > TBLength.Position)
     then  TBLowercaseChars.Position := TBLength.Position;



         if    (TBUppercaseChars.Position > TBLength.Position)
     then  TBUppercaseChars.Position := TBLength.Position;



            if    (TBSpecialChars.Position > TBLength.Position)
     then  TBSpecialChars.Position := TBLength.Position;


{      (TBLowercaseChars.Position > TBLength.Position)       or
      (TBUppercaseChars.Position > TBLength.Position)         or
      (TBSpecialChars.Position > TBLength.Position)             then
 }


//      if position > TBLength.Position then
  //       TBLength.Position := (sender as ttrackbar).Position;



    end;


    if  (NormalizedPosition(TBDigits.Position)      +
         NormalizedPosition(TBLowercaseChars.Position) +
         NormalizedPosition(TBUppercaseChars.Position)   +
         NormalizedPosition(TBSpecialChars.Position)) >  TBLength.Position then begin


               if TBLength.Position < 128 then

//                 try to increase length
                   TBLength.Position := TBLength.Position + 1;



    end;











end;

procedure TFormMain.TBDigitsChange(Sender: TObject);
begin

  SatisfyMaxInputs(TBDigits);

  GeneratePasswordList;

end;

procedure TFormMain.TBLowercaseCharsChange(Sender: TObject);
begin

  SatisfyMaxInputs(TBLowercaseChars);

  GeneratePasswordList;

end;

procedure TFormMain.TBUppercaseCharsChange(Sender: TObject);
begin

  SatisfyMaxInputs(TBUppercaseChars);

  GeneratePasswordList;

end;

procedure TFormMain.TBSpecialCharsChange(Sender: TObject);
begin

  SatisfyMaxInputs(TBSpecialChars);

  GeneratePasswordList;

end;

procedure TFormMain.TBDigitsMouseEnter(Sender: TObject);
begin

  Digits.Font.Style := [fsBold];

end;

procedure TFormMain.TBDigitsMouseLeave(Sender: TObject);
begin

  Digits.Font.Style := [];

end;

procedure TFormMain.TBLowercaseCharsMouseEnter(Sender: TObject);
begin

  LowerCharacters.Font.Style := [fsBold];

end;

procedure TFormMain.TBLowercaseCharsMouseLeave(Sender: TObject);
begin

  LowerCharacters.Font.Style := [];

end;

procedure TFormMain.TBUppercaseCharsMouseEnter(Sender: TObject);
begin

  UpperCharacters.Font.Style := [fsBold];

end;

procedure TFormMain.TBUppercaseCharsMouseLeave(Sender: TObject);
begin

  UpperCharacters.Font.Style := [];

end;

procedure TFormMain.TBSpecialCharsMouseEnter(Sender: TObject);
begin

  SpecialCharacters.Font.Style := [fsBold];

end;

procedure TFormMain.TBSpecialCharsMouseLeave(Sender: TObject);
begin

  SpecialCharacters.Font.Style := [];

end;

procedure TFormMain.TBLengthChange(Sender: TObject);

var
  PasswordLength: Integer;

begin

  UDPasswordCharCount.Value := TBLength.Position;

  PasswordLength := TBLength.Position;

  if PasswordLength < 16 then
         UDPasswordCharCount.Color := clRed else
         if PasswordLength < 32 then
           UDPasswordCharCount.Color := clYellow else
         if PasswordLength < 64 then
           UDPasswordCharCount.Color := $0000A500 else
         if PasswordLength > 64 then
           UDPasswordCharCount.Color := clLime;


    SatisfyMaxInputs(TBLength);

     GeneratePasswordList;

end;

procedure TFormMain.TBLengthMouseEnter(Sender: TObject);
begin
  LLength.Font.Style := [fsBold];
end;

procedure TFormMain.TBLengthMouseLeave(Sender: TObject);
begin
  LLength.Font.Style := [];
end;

procedure TFormMain.TrackBarChange(Sender: TObject);
begin
end;

procedure TFormMain.UDPasswordCharCountChange(Sender: TObject);
begin
   TBLength.Position := UDPasswordCharCount.Value;
end;

function TFormMain.GeneratePassword: string;

type
  TPasswordChar = (pcLowerLetter, pcUpperLetter, pcDigit, pcSpecialChar);
  TPasswordCharSet = set of TPasswordChar;
  TLowerLetter = 'a'..'z';
  TUpperLetter = 'A'..'Z';
  TDigit = '0'..'9';

var
  PasswordCharSet: TPasswordCharSet;
  RandomPasswordCharType: TPasswordChar;
  PasswordChar: Char;
  Password: string;
  I, MaxOrd, MinOrd, SpecialCharCount: Integer;
  MaxTPasswordCharInt: Integer;

begin

  PasswordCharSet := [];

  if ChBIncludeLowerLetters.Checked then
    Include(PasswordCharSet, pcLowerLetter);

  if ChBIncludeUpperLetters.Checked then
    Include(PasswordCharSet, pcUpperLetter);

  if ChBIncludeDigits.Checked then
    Include(PasswordCharSet, pcDigit);

  if ChBIncludeSpecialChars.Checked then
    Include(PasswordCharSet, pcSpecialChar);

  Password := '';

  SpecialCharCount := 0;

  for I := 1 to UDPasswordCharCount.Value do begin

    repeat

      MaxTPasswordCharInt := Integer(High(TPasswordChar));

      RandomPasswordCharType := TPasswordChar(Random(MaxTPasswordCharInt + 1));

    until (RandomPasswordCharType in PasswordCharSet) and
          (not ((RandomPasswordCharType = pcSpecialChar) and ((SpecialCharCount >= UDSpecialCharsMax.Value) or
                                                        (I = 1) or
                                                        (I = UDPasswordCharCount.Value))));

    case RandomPasswordCharType of

      pcLowerLetter: begin
        MaxOrd := Ord(High(TLowerLetter));
        MinOrd := Ord(Low(TLowerLetter));
      end;

      pcUpperLetter: begin
        MaxOrd := Ord(High(TUpperLetter));
        MinOrd := Ord(Low(TUpperLetter));
      end;

      pcDigit: begin
        MaxOrd := Ord(High(TDigit));
        MinOrd := Ord(Low(TDigit));
      end;

      pcSpecialChar: begin
        PasswordChar := ESpecialChars.Text[Random(Length(ESpecialChars.Text)) + 1];
        Inc(SpecialCharCount);
      end;

    end;

    if RandomPasswordCharType <> pcSpecialChar then
      PasswordChar := Chr(Random(MaxOrd - MinOrd + 1) + MinOrd);

    Password := Password + PasswordChar;

  end;

  Result := Password;

end;

function GetLBTextWidth(AText: string): integer;

var
  bmp: TBitmap;
  c: tcanvas;

begin
  c := tcanvas.create;
  bmp := TBitmap.Create;
  try
    bmp.Canvas.Font.Name := FormMain.LBPasswordList.Font.Name;
    bmp.Canvas.Font.Size := FormMain.LBPasswordList.Font.Size;
    result := bmp.Canvas.TextWidth(AText);
  finally
    bmp.free;
    c.Free;
  end;
end;

procedure TFormMain.BGenerateListClick(Sender: TObject);

var
  I: Integer;
  //S: string;
  PaswdObject: TPassword;
  NewWidth: INteger;

begin


  i := 0;

  while  LBPasswordList.count > 0 do begin

   if  LBPasswordList.Items.Objects[I] is TPassword then  begin

      (LBPasswordList.Items.Objects[I] as TPassword).Free;

      LBPasswordList.Items.Delete(I);

    end;

  end;






//  LBPasswordList.Clear;

  if not PossibleToGeneratePassword then begin

    Exit;

  end;

  {
  while  LBPasswordList.count > 0 do begin

   if  LBPasswordList.Items.Objects[I] is TPassword then

      (LBPasswordList.Items.Objects[I] as TPassword).Free;



      if LBPasswordList.items.Objects.Count > 0 then


  end;
}


  for I := 1 to 5 do begin



    PaswdObject := TPassword.Create;

   // S := GeneratePassword;

    LBPasswordList.AddItem(PaswdObject.Concealed, PaswdObject);

    LBPasswordList.ClientWidth := GetLBTextWidth(PaswdObject.Revealed) + 16;

    NewWidth := max(574, LBPasswordList.Width + LBPasswordList.ClientWidth);

    Panel2.ClientWidth := NewWidth;

    FormMain.ClientWidth := Panel2.Width;


  end;
end;

procedure TFormMain.Button1Click(Sender: TObject);
begin
end;

procedure TFormMain.ChBIncludeLowerLettersChange(Sender: TObject);
begin

end;

procedure TFormMain.ChBIncludeLowerLettersClick(Sender: TObject);
begin
  if (sender as tcheckbox).Checked then
    (sender as tcheckbox).font.color := clgreen else
    (sender as tcheckbox).font.color := clmaroon;

   GeneratePasswordList;
end;

procedure TFormMain.ChBIncludeSpecialCharsChange(Sender: TObject);
begin

end;

{
procedure TFormMain.PMPasswordListPopup(Sender: TObject);
begin
  PMPasswordList_CopyToClipboard.Enabled := LBPasswordList.ItemIndex > -1;
end;

procedure TFormMain.PMPasswordList_CopyToClipboardClick(Sender: TObject);
begin
  Clipboard.AsText := LBPasswordList.Items[LBPasswordList.ItemIndex];
end;
}
end.

