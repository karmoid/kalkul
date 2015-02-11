unit filekind;

interface
uses SysUtils,
    Classes,
	Contnrs,
	suminfo;

type 
	TFileKind = class
		constructor Create(); 
		destructor Destroy; override;
	protected
		fextension : WideString;
		fname : WideString;
		fTypes : TStringList;
		fUnknown : TStringList;
		fHarray : TFPObjectHashTable;
	private
		function GetExtension : WideString;
		procedure SetExtension(value : WideString);
		function GetTypeExtension(key : string): WideString;
	public	
		property Extension: WideString read GetExtension write SetExtension;
		property Name: WideString read fname write fname;
		procedure AddExtension(vname : WideString; value : WideString);
		function AddSizeExtension(key : string; size : Integer; WithDetails: Boolean): Integer;
		property TypeExtension[key : string] : WideString read GetTypeExtension;
		procedure DumpContents;
	end; 

implementation

var Somme : Cardinal;

type TCardinal = class
	private
		FValue : Cardinal;
	public
		constructor Create(Val : Cardinal);
		property Value: Cardinal read FValue write FValue;	
		function Add(Val : Cardinal) : Cardinal;
end;

constructor TCardinal.Create(Val : Cardinal);
	begin
		fValue := Val;
	end;

function TCardinal.Add(Val : Cardinal): Cardinal;
	begin
		FValue := FValue + Val;
		Result := FValue;
	end;	

constructor TFileKind.Create();
begin
	fTypes := TStringList.Create();
	fUnknown := TStringList.Create();
	fTypes.Duplicates := dupIgnore;
	fUnknown.Duplicates := dupIgnore;
	fHarray := TFPObjectHashTable.Create();
end;

destructor TFileKind.Destroy;
begin
	fHarray.free;
	fTypes.free;
	fUnknown.free;
	inherited Destroy;
end;

function TFileKind.GetTypeExtension(key : string): WideString;
begin
	Result := fTypes.ValueFromIndex[((fHarray.items[Lowercase(key)]) as TCardinal).value];
end;

function TFileKind.AddSizeExtension(key : string; size : Integer; WithDetails: Boolean): Integer;
var i : integer;
var Int : TCardinal;
begin
	Int := fHarray.items[Lowercase(key)] as TCardinal;
	if Assigned(Int) then
	  i := Int.Value
	else
	begin
	  i := 0;
	  writeln('Key ' + Key + ' not found. Size = '+IntToStr(Size));
	end;

	Result := (fTypes.Objects[i] as TSumInformation).AddSize(size);
	if (i = 0) and (WithDetails) then 
	begin
	  	writeln('Key ' + Key + ' on ajoute Size = '+IntToStr(Size)+ ' index '+ IntToStr(i));
		if (fUnknown.IndexOf(key)=-1) then
			fUnknown.add(key);
		i := fUnknown.IndexOf(key);
		if Not Assigned(fUnknown.Objects[i]) then
			fUnknown.Objects[i] := TCardinal.Create(size)
		else
			(fUnknown.Objects[i] as TCardinal).Add(size);
		Somme := Somme + Size;	
	end;
end;

procedure TFileKind.AddExtension(vname : WideString; value : WideString);
var i : integer;
begin
	i := fTypes.IndexOf(vname);
	if i = -1 then i := fTypes.add(vname);
	fHarray.add(Lowercase(value), TCardinal.Create(i));
	fTypes.Objects[i] := TSumInformation.Create(vname);
	//Writeln('added ' + Value + ' on fTypes[' + IntToStr(i) + '] ' + Name);
end;

function TFileKind.GetExtension : WideString;
	begin
	result := fextension
	end;

procedure TFileKind.SetExtension(value : WideString);
	begin
	fextension := value;
	end;

procedure TFileKind.DumpContents();
var i : Integer;	
	begin
	for i := 0 to pred(fUnknown.count) do
		begin
		if (fUnknown.Objects[i] as TCardinal).Value div (1024*1024)>1 then
			WriteLn(fUnknown.ValueFromIndex[i]+' '+IntToStr((fUnknown.Objects[i] as TCardinal).Value div (1024*1024))+' Mb');		
		end;

	Writeln;
	Writeln('Type:':25 , 'Size (KiB)':25,  'Size (Human)':25);
	for i := 0 to pred(fTypes.count) do
		Writeln(fTypes.ValueFromIndex[i]:25, (fTypes.Objects[i] as TSumInformation).Size:25,  (fTypes.Objects[i] as TSumInformation).SizeHumanReadable:25);
	Writeln('Somme = ' + IntToStr(Somme));
	end;

end.