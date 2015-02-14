unit InternalTypes;
interface

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

function GetSizeHRb(fSize : uInt64): WideString;
function GetSizeHRk(fSize : uInt64): WideString;

implementation
uses StrUtils,
	 SysUtils;

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



end.