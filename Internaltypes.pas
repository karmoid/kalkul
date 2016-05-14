unit InternalTypes;
interface
uses Windows,
	regexpr,
	SysUtils;

type TUInt64 = class
	private
		FValue : UInt64;
		function GetFromByteToHR : string;
		function GetFromKByteToHR : string;
	public
		constructor Create(Val : UInt64);
		property Value: UInt64 read FValue write FValue;
		function Add(Val : UInt64) : UInt64;
		property FromByteToHR : String Read GetFromByteToHR;
		property FromKByteToHR : String Read GetFromKByteToHR;
end;

type TFileInfo = class
	private
		fnbfile : UInt64;
		fminsize, fmaxsize, ftotalsize : UInt64;
		fminCreateDT, fminAccessDT, fminModifyDT: TDateTime;
		fmaxCreateDT, fmaxAccessDT, fmaxModifyDT: TDateTime;
		// Procedure ExploitInfo(Info : TSearchRec; var CDT,ADT,MDT : TDateTime; var SZ : UInt64);
		Procedure SetMinMaxDate(SDate : TDateTime; var Mindate, maxDate : TDateTime);
		function SetNewSize(SZ : UInt64) : uInt64;
	public
		constructor Create;
		function GetData : string;
		function GetJSON : AnsiString;
		property nbfile: uInt64 read Fnbfile write Fnbfile;
		property minSize: UInt64 read FMinSize write FMinSize;
		property MaxSize: UInt64 read FMaxSize write FMaxSize;
		property TotalSize: UInt64 read FTotalSize write FTotalSize;
		property MinCreateDT: TDateTime read FMinCreateDT write FMinCreateDT;
		property MinAccessDT: TDateTime read FMinAccessDT write FMinAccessDT;
		property MinModifyDT: TDateTime read FMinModifyDT write FMinModifyDT;
		property MaxCreateDT: TDateTime read FMaxCreateDT write FMaxCreateDT;
		property MaxAccessDT: TDateTime read FMaxAccessDT write FMaxAccessDT;
		property MaxModifyDT: TDateTime read FMaxModifyDT write FMaxModifyDT;
	end;

type TFileInfoArray = class
	private
		fArray : Array of Tfileinfo;
		function GetFileInfo(Index : Integer) : TFileInfo;
		Procedure SetFileInfo(Index : Integer; Fi : TFileInfo);
		function GetCount : Integer;
	public
		constructor Create();
		function TakeAccount(Info : TSearchRec; LimIndex : Integer) : uInt64;
		function GetData : string;
		function GetJSON : AnsiString;
		property FileInfo[Index : Integer] : TFileInfo read GetFileInfo write SetFileInfo;
		property Count : Integer read GetCount;
	end;

function getTimeStampString : String;
function GetSizeHRb(fSize : uInt64): WideString;
function GetSizeHRk(fSize : uInt64): WideString;
function EvaluateUnity(Valyou : string): UInt64;
function NormalizePath(S : String) : String;
function GetComputerNetName: string;
function XMLDateTime2DateTime(const XMLDateTime: AnsiString): TDateTime;
function DateTime2XMLDateTime(const vDateTime: TDateTime): AnsiString;
function RegularExpression(ExtValue : AnsiString): Boolean;
function GetExtensionTypeFromRegExp(ExtValue : AnsiString; fName : AnsiString; GName : AnsiString) : Ansistring;
function GetDiskSize(drive: Char; var free_size, total_size: Int64): Boolean;


const virguleLast : array[Boolean] of string = ('',',');
const cTrueFalse : array[Boolean] of string = ('False','True');
var SizeLimit : integer = 0;
const cIntlDateTimeStor = 'yyyy-mm-dd hh:mm:ss';    // for storage
const cIntlDateTimeDisp = 'yyyy-mm-dd hh:mm:ss';  // for display
const cIntlDateDisp     = 'yyyy-mm-dd';  // for display
const cIntlDateFile     = 'yyyymmddhhnnss';  // for file
var Regex: TRegExpr;
implementation
uses DateUtils,
     StrUtils;

function GetDiskSize(drive: Char; var free_size, total_size: Int64): Boolean;
var
  RootPath: array[0..4] of Char;
  RootPtr: PChar;
  current_dir: string;
begin
  RootPath[0] := Drive;
  RootPath[1] := ':';
  RootPath[2] := '\';
  RootPath[3] := #0;
  RootPtr := RootPath;
  current_dir := GetCurrentDir;
  if SetCurrentDir(drive + ':\') then
  begin
    GetDiskFreeSpaceEx(RootPtr, Free_size, Total_size, nil);
    // this to turn back to original dir
    SetCurrentDir(current_dir);
    Result := True;
  end
  else
  begin
    Result := False;
    Free_size  := -1;
    Total_size := -1;
  end;
end;

function RegularExpression(ExtValue : AnsiString): Boolean;
begin
	Result := ((copy(ExtValue,1,1) = '/') or
				(copy(ExtValue,1,2) = '~/')) and
	    		(copy(ExtValue,Length(ExtValue),1)='/');
end;

function GetExtensionTypeFromRegExp(ExtValue : AnsiString; fName : AnsiString; GName : AnsiString) : Ansistring;
var match : boolean;
var ExpR : Ansistring;
begin
	result := '';
	if RegularExpression(ExtValue) then
	begin
		match := ExtValue[1]='~';
		if match then
		begin
			ExpR := copy(ExtValue,3,Length(ExtValue)-3);
			// writeln('On vient de trouver un Match avec '+ExpR);
  			Regex.Expression := ExpR;
  			regex.Exec(fname);
  			if regex.SubExprMatchCount = 1 then
  			begin
  				Result := GName+'_'+regex.Match[1];
  				// writeln('-> ', Result);
  			end;
		end
		else
		begin
			ExpR := copy(ExtValue,2,Length(ExtValue)-2);
			// writeln('On vient de trouver un scan avec '+ExpR);
  			Regex.Expression := ExpR;
				// writeln('RegEx sur ',fname,' avec ',ExpR);
  			if regex.Exec(fname) then
  			begin
  				Result := GName;
  				// writeln('->',Result);
  			end;

		end;
	end;
end;

function getTimeStampString : String;
begin
	Result := FormatDateTime(cIntlDateFile,Now);
end;

function XMLDateTime2DateTime(const XMLDateTime: AnsiString): TDateTime;
var
  DateOnly: String;
  TimeOnly: String;
  TPos: Integer;
begin
	TPos := Pos(' ', XMLDateTime);
	if TPos <> 0 then
	begin
    	DateOnly := Copy(XMLDateTime, 1, TPos - 1);
    	TimeOnly := Copy(XMLDateTime, TPos + 1, Length(XMLDateTime));
		TPos := Pos(' ', TimeOnly);
		if TPos <> 0 then
			TimeOnly := Copy(TimeOnly, 1, TPos - 1);
  		Result := ScanDateTime('yyyy-mm-dd hh:nn:ss', DateOnly+' '+TimeOnly);
	end
	else
	begin
    	DateOnly := XMLDateTime;
		Result := ScanDateTime('yyyy-mm-dd', DateOnly);
	end;
end;


function DateTime2XMLDateTime(const vDateTime: TDateTime): AnsiString;
var offset : integer;
const Signs : array[-1..1] of char = ('+',' ','-');
begin
	offset := GetLocalTimeOffset;
	Result := FormatDateTime(cIntlDateTimeStor,vDateTime)+' '+Signs[Offset div abs(offset)]+Format('%.4d',[offset div 60*-100]);
end;

function FileTimeToDTime(FTime: TFileTime): TDateTime;
var
  LocalFTime: TFileTime;
  STime: TSystemTime;
begin
  FileTimeToLocalFileTime(FTime, LocalFTime);
  FileTimeToSystemTime(LocalFTime, STime);
  Result := SystemTimeToDateTime(STime);
end;

Procedure ExploitInfo(Info : TSearchRec; var CDT,ADT,MDT : TDateTime; var SZ : UInt64);
begin
	with info do
	begin
		CDT := FileTimeToDTime(FindData.ftCreationTime);
		ADT := FileTimeToDTime(FindData.ftLastAccessTime);
		MDT := FileTimeToDTime(FindData.ftLastWriteTime);
		SZ := Size;
	end;
end;

function GetComputerNetName: string;
var
  buffer: ShortString;
  size: dword;
begin
  size := 250;
  buffer := StringOfChar(' ',sizeOf(buffer));
  if GetComputerName(@Buffer[1], size) then
  begin
    Result := StrPas(@buffer[1]);

  end
  else
    Result := ''
end;

constructor TFileInfoArray.Create();
begin
	SetLength(fArray,SizeLimit);
end;

function TFileInfoArray.GetFileInfo(Index : Integer) : TFileInfo;
begin
	Result := fArray[Index];
end;

Procedure TFileInfoArray.SetFileInfo(Index : Integer; Fi : TFileInfo);
begin
	fArray[index] := Fi;
end;

function TFileInfoArray.GetCount : Integer;
begin
	Result := SizeLimit;
end;

function TFileInfoArray.GetData : string;
var i : integer;
begin
	Result := 'FileInfoArray : ';
	for i := 0 to pred(Count) do
	if Assigned(FileInfo[i]) then
		Result := Result + IntToStr(i) + '-' +FileINfo[i].GetData;
end;

function TFileInfoArray.GetJSON : Ansistring;
var i : integer;
var virg : String = '';
begin
	Result := '"FileInfoArray" : [';
	for i := 0 to pred(Count) do
	if Assigned(FileInfo[i]) then
	begin
		Result := Result + virg + '{ "Index": '+IntToStr(i)+', '+FileINfo[i].GetJSON+' }';
		virg := ', ';
	end;
	Result := Result + ']';
end;

constructor Tfileinfo.Create;
begin
	fMinCreateDT := maxDateTime;
	fMinAccessDT := maxDateTime;
	fMinModifyDT := maxDateTime;
	fMaxCreateDT := minDateTime;
	fMaxAccessDT := minDateTime;
	fMaxModifyDT := minDateTime;
	fmaxsize := 0;
	fminsize := high(uInt64);
	fnbfile := 0;
	ftotalsize := 0;
end;

function Tfileinfo.GetData : string;
begin
	if nbfile=0 then
		Result := 'NbF:0'
	else
		Result := 'MinCD:'+DateTimeToStr(MinCreateDT)+', '+
			  'MaxCD:'+DateTimeToStr(MaxCreateDT)+', '+
			  'MinAD:'+DateTimeToStr(MinAccessDT)+', '+
			  'MaxAD:'+DateTimeToStr(MaxAccessDT)+', '+
			  'MinMD:'+DateTimeToStr(MinModifyDT)+', '+
			  'MaxMD:'+DateTimeToStr(MaxModifyDT)+', '+
			  'NbF:'+IntToStr(nbfile)+', '+
			  'minSize:'+GetSizeHRb(minSize)+', '+
			  'maxSize:'+GetSizeHRb(maxSize)+', '+
			  'TotalSize:'+GetSizeHRb(TotalSize);
end;

function Tfileinfo.GetJSON : AnsiString;
begin
	Result := '"MinCreateDT" : "'+DateTime2XMLDateTime(MinCreateDT)+'", '+
			  '"MaxCreateDT" : "'+DateTime2XMLDateTime(MaxCreateDT)+'", '+
			  '"MinAccessDT" : "'+DateTime2XMLDateTime(MinAccessDT)+'", '+
			  '"MaxAccessDT" : "'+DateTime2XMLDateTime(MaxAccessDT)+'", '+
			  '"MinModifyDT" : "'+DateTime2XMLDateTime(MinModifyDT)+'", '+
			  '"MaxModifyDT" : "'+DateTime2XMLDateTime(MaxModifyDT)+'", '+
			  '"NbFile" : '+IntToStr(nbfile)+', '+
			  '"MinSize" : '+IntToStr(minSize)+', '+
			  '"MaxSize" : '+IntToStr(maxSize)+', '+
			  '"TotalSize" : '+IntToStr(TotalSize);
end;



function TFileInfo.SetNewSize(SZ : UInt64) : uInt64;
begin
	TotalSize := TotalSize + SZ;
	if SZ<minSize then
		minSize := SZ;
	if SZ>MaxSize then
		MaxSize := SZ;
	result := TotalSize;
end;

Procedure TFileInfo.SetMinMaxDate(SDate : TDateTime; var Mindate, maxDate : TDateTime);
begin
	if SDate>maxDate then
		maxDate := SDate;
	if SDate<Mindate then
		Mindate := SDate;
end;

function TFileInfoArray.TakeAccount(Info : TSearchRec; LimIndex : Integer) : uInt64;
var CDT,ADT,MDT : TDateTime;
var SZ : UInt64;
begin
	ExploitInfo(info, CDT,ADT,MDT,SZ);
	if not Assigned(FileInfo[LimIndex]) then
	  FileInfo[LimIndex] := TFileInfo.Create;
	with FileInfo[LimIndex] do
	begin
		nbfile := nbfile + 1;
		SetMinMaxDate(CDT,fMinCreateDT,fMaxCreateDT);
		SetMinMaxDate(ADT, fMinAccessDT,fmaxAccessDT);
		SetMinMaxDate(MDT,fminModifyDT,fmaxModifyDT);
		Result := SetNewSize(SZ);
	end;
end;

function StrToUInt64(const S: String): UInt64;
var c: cardinal;
    P: PChar;
begin
  P := @S[1];
  if P=nil then begin
    result := 0;
    exit;
  end;
  if ord(P^) in [1..32] then repeat inc(P) until not(ord(P^) in [1..32]);
  c := ord(P^)-48;
  if c>9 then
    result := 0 else begin
    result := c;
    inc(P);
    repeat
      c := ord(P^)-48;
      if c>9 then
        break else
        result := result*10+c;
      inc(P);
    until false;
  end;
end;

// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// Procedure interne utilitaire
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
function EvaluateUnity(Valyou : String): UInt64;
var Valeur : UInt64;
	Unite : UInt64;
	Pos : Word;
	begin
		Result := 0;
		Pos := 1;
		while Pos<=Length(Valyou) do
		begin
			if not (Valyou[Pos] in ['0'..'9']) then
			  Break;
			Inc(Pos);
		end;
		try
			if Pos<=Length(Valyou) then
			begin
				// write('on va tester '+lowercase(Valyou[Pos]));
				case lowercase(Valyou[Pos]) of
					'b': Unite := 1;
					'k': Unite := 1 << 10;
					'm': Unite := 1 << 20;
					'g': Unite := 1 << 30;
					't': Unite := 1 << 40;
					'p': Unite := 1 << 50;
					else
						Unite := 0;
				end;
				Valeur := StrToUInt64(LeftStr(Valyou,Pos-1));
			end
			else
			begin
				unite := 1;
				Valeur := StrToUInt64(Valyou);
			end;
			Result := Unite * Valeur;
		except on e: EConvertError do
				writeln('Exception ConvertError on ('+ValYou+') : Pos=',Pos,', "',e.message,'"');
		end;
	end;

// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// Procedure interne utilitaire
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
function GetSizeHRAny(fSize : uInt64; IndexV : Integer): WideString;
const Units : array[1..6] of string = ('','Kib','Mib','Gib','Tib','Pib');
var index : Integer;
	isize : UInt64;
	divider : UInt64;
begin
	divider := 1;
	index := IndexV;
	isize := fsize;
	while (index<=6) and (isize>1024) do
	begin
		index := index + 1;
		isize := isize div 1024;
		divider := divider << 10;
	end;
	result := IntToStr(isize);
	if (isize>0) and (fSize mod (isize*divider) > 0) then
	begin
		Result := Result + ',' + LeftStr(IntToStr(fSize mod (isize*divider))+'00',3);
	end;
	Result := Result + ' ' + Units[index]
end;

// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// Expression en forme Humaine
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
function GetSizeHRb(fSize : uInt64): WideString;
begin
	Result := GetSizeHRAny(fSize,1);
end;

// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// Expression en forme Humaine
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
function GetSizeHRk(fSize : uInt64): WideString;
begin
	Result := GetSizeHRAny(fSize,2);
end;

constructor TUInt64.Create(Val : UInt64);
	begin
		fValue := Val;
	end;

function TUInt64.Add(Val : UInt64): UInt64;
	begin
		FValue := FValue + Val;
		Result := FValue;
	end;

function TUInt64.GetFromByteToHR : string;
begin
	Result := GetSizeHRb(fValue);
end;

function TUInt64.GetFromKByteToHR : string;
begin
	Result := GetSizeHRk(fValue);
end;

function NormalizePath(S : String) : String;
begin
	Result := LowerCase(S);
	if Result[Length((Result))]<>'\' then Result := Result + '\';
end;

end.
