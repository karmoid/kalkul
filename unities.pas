unit unities;
interface
uses Classes,
	InternalTypes;

type
	TUnityList = class(TStringList)
	private
		function GetNames(Index : Integer) : String;
		procedure SetNames(Index : Integer; Value : String);
		function GetValues(Index : Integer) : UInt64;
		procedure SetValues(Index : Integer; Value : UInt64);

	public
		procedure AddUnity(Valyou : string);
		function GetJSON : string;
		property Names [Index : Integer] : String read GetNames write SetNames;
		property Values [Index : Integer] : UInt64 read GetValues write SetValues;
	end;

implementation
uses SysUtils;
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// Ajout d'une unité à la liste.
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
procedure TunityList.AddUnity(Valyou : string);
	begin
		AddObject(Valyou, TUint64.Create(EvaluateUnity(Valyou)));
	end;

// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// Expression en forme Humaine
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
function TunityList.GetNames(Index : Integer) : String;
begin
	Result := Strings[Index];
end;

// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// Expression en forme Humaine
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
procedure TunityList.SetNames(Index : Integer; Value : String);
begin
	Strings[Index] := Value;	
end;

// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// Expression en forme Humaine
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
function TunityList.GetValues(Index : Integer) : UInt64;
begin
	Result := TUint64(Objects[Index]).Value;
end;

// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// Expression en forme Humaine
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
procedure TunityList.SetValues(Index : Integer; Value : UInt64);
begin
	TUint64(Objects[Index]).Value := Value;
end;

function TunityList.GetJSON : string;
var i : Integer;
var Virg : String = '';
begin
	Result := '"Unities" : [';
	for i:=0 to pred(count) Do
	begin
		Result := Result + Virg+ '{ "Name": "'+Strings[i]+'", "Value": '+IntToStr(Values[i])+' }';
		Virg := ', ';
	end;
	Result := Result + ']';
end;

end.