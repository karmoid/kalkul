unit InternalTypes;
interface
uses Windows,
	SysUtils;

type TUInt64 = class
	private
		FValue : UInt64;
		function GetFromByteToHR : string;
		function GetFromKByteToHR : string;
	public
		constructor Create(Val : Cardinal);
		property Value: UInt64 read FValue write FValue;	
		function Add(Val : Cardinal) : UInt64;
		property FromByteToHR : String Read GetFromByteToHR;
		property FromKByteToHR : String Read GetFromKByteToHR;
end;

type TFileInfo = class
	private
		fnbfile : UInt64;
		fminsize, fmaxsize, ftotalsize : UInt64;
		fminCreateDT, fminAccessDT, fminModifyDT: TDateTime;
		fmaxCreateDT, fmaxAccessDT, fmaxModifyDT: TDateTime;
		function FileTimeToDTime(FTime: TFileTime): TDateTime;
		Procedure ExploitInfo(Info : TSearchRec; var CDT,ADT,MDT : TDateTime; var SZ : UInt64);
		Procedure SetMinMaxDate(SDate : TDateTime; var Mindate, maxDate : TDateTime);
		function SetNewSize(SZ : UInt64) : uInt64;
	public
		constructor Create;
		function TakeAccount(Info : TSearchRec) : uInt64;
		function GetData : string;
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

function GetSizeHRb(fSize : uInt64): WideString;
function GetSizeHRk(fSize : uInt64): WideString;
function EvaluateUnity(Valyou : string): UInt64;
function NormalizePath(S : String) : String;
// function FileTimeToDTime(FTime: TFileTime): TDateTime;

implementation
uses StrUtils;

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

Procedure TFileInfo.ExploitInfo(Info : TSearchRec; var CDT,ADT,MDT : TDateTime; var SZ : UInt64);
begin
	with info do
	begin
		CDT := FileTimeToDTime(FindData.ftCreationTime);
		ADT := FileTimeToDTime(FindData.ftLastAccessTime);
		MDT := FileTimeToDTime(FindData.ftLastWriteTime);
		SZ := Size;
	end;	
end;

function Tfileinfo.GetData : string;
begin
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

function TFileInfo.TakeAccount(Info : TSearchRec) : uInt64;
var CDT,ADT,MDT : TDateTime;
var SZ : UInt64;
begin
	with info do
		ExploitInfo(info, CDT,ADT,MDT,SZ);
	nbfile := nbfile + 1;	
	SetMinMaxDate(CDT,fMinCreateDT,fMaxCreateDT);
	SetMinMaxDate(ADT, fMinAccessDT,fmaxAccessDT);
	SetMinMaxDate(MDT,fminModifyDT,fmaxModifyDT);
	Result := SetNewSize(SZ);
end;

function TFileInfo.FileTimeToDTime(FTime: TFileTime): TDateTime;
var
  LocalFTime: TFileTime;
  STime: TSystemTime;
begin
  FileTimeToLocalFileTime(FTime, LocalFTime);
  FileTimeToSystemTime(LocalFTime, STime);
  Result := SystemTimeToDateTime(STime);
end;


// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// Procedure interne utilitaire
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
function EvaluateUnity(Valyou : String): UInt64;
var Valeur : Integer;
	Unite : UInt64;
	Pos : Word;
	begin
		Result := 0;
		Val(Valyou,Valeur,Pos);
		if Pos <> 0 then
		begin
			// write('on va tester '+lowercase(Valyou[Pos]));
			case lowercase(Valyou[Pos]) of
				'b': Unite := 1;
				'k': Unite := 1 << 10;
				'm': Unite := 1 << 20;
				'g': Unite := 1 << 30;
				't': Unite := 1 << 40;
				else 
					Unite := 0;
			end;
			// writeln(' unite = '+IntToStr(Unite));
		end;	
		Val(LeftStr(Valyou,Pos-1),Valeur,Pos);
		if (Unite>0) and (Pos = 0) then
			Result := Unite * Valeur;	
	end;

// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// Procedure interne utilitaire
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
function GetSizeHRAny(fSize : uInt64; IndexV : Integer): WideString;
const Units : array[1..5] of string = ('','Kib','Mib','Gib','Tib');
var index : Integer;
	isize : UInt64;
	divider : UInt64;
begin
	divider := 1;
	index := IndexV;
	isize := fsize;
	while (index<=5) and (isize>1024) do
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

constructor TUInt64.Create(Val : Cardinal);
	begin
		fValue := Val;
	end;

function TUInt64.Add(Val : Cardinal): UInt64;
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