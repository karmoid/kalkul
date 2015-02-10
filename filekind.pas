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
		procedure MyIterMethod (Item: TObject; const Key: string;
								var Continue: Boolean);
		function GetHashContent : WideString;
		function GetTypeExtension(key : string): WideString;
	public	
		property Extension: WideString read GetExtension write SetExtension;
		property Name: WideString read fname write fname;
		property HashContent : WideString read GetHashContent ;
		procedure AddExtension(name : WideString; value : WideString);
		function AddSizeExtension(key : string; size : Integer; WithDetails: Boolean): Integer;
		property TypeExtension[key : string] : WideString read GetTypeExtension;
		procedure DumpContents;
	end; 

implementation
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
	Result := fTypes.ValueFromIndex[Longint(fHarray.items[Lowercase(key)])];
end;

function TFileKind.AddSizeExtension(key : string; size : Integer; WithDetails: Boolean): Integer;
var i : integer;
begin
	i := Longint(fHarray.items[Lowercase(key)]);
	Result := (fTypes.Objects[i] as TSumInformation).AddSize(size);
	if (i = 0) and (WithDetails) then 
	begin
		if (fUnknown.IndexOf(key)=-1) then
			fUnknown.add(key);
		i := fUnknown.IndexOf(key);
		fUnknown.Objects[i] := TObject(Longint(fUnknown.Objects[i]) + size);
	end;
end;

procedure TFileKind.AddExtension(name : WideString; value : WideString);
var i : integer;
begin
	i := fTypes.IndexOf(name);
	if i = -1 then i := fTypes.add(name);
	fHarray.add(Lowercase(value), TObject(i));
	fTypes.Objects[i] := TSumInformation.Create(name);
	//Writeln('added ' + Value + ' on fTypes[' + IntToStr(i) + '] ' + Name);
end;

function TFileKind.GetHashContent : WideString;
var i : integer;
	begin
		result := '';
		for i := 0 to pred(fTypes.count) do
		begin
			Result := Result + '\n' + fTypes.ValueFromIndex[i] + '\t' + IntToStr((fTypes.Objects[i] as TSumInformation).Size);
		end;
	end;

procedure TFileKind.MyIterMethod (Item: TObject; const Key: string;
								var Continue: Boolean);
	begin
		Writeln('in Iter Method : Item(' + fTypes.Names[Longint(@Item)] + ') - ' + Key);
		Continue := True;
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
		if Longint(fUnknown.Objects[i]) div (1024*1024)>1 then
			WriteLn(fUnknown.ValueFromIndex[i]+' '+IntToStr(Longint(fUnknown.Objects[i]) div (1024*1024))+' Mb');		
		end;

	Writeln;
	Writeln('Type:':25 , 'Size (KiB)':25,  'Size (Human)':25);
	for i := 0 to pred(fTypes.count) do
		Writeln(fTypes.ValueFromIndex[i]:25, (fTypes.Objects[i] as TSumInformation).Size:25,  (fTypes.Objects[i] as TSumInformation).SizeHumanReadable:25);
	end;

end.