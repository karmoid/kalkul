unit filekind;

interface
uses SysUtils,
    Classes,
	Contnrs,
	Extensions,
	ExtensionTypes,
	suminfo;

type 
	TFileKind = class
		constructor Create(); 
		destructor Destroy; override;
	protected
		// a terme on doit utiliser l'objet ExtensionTypes pour partager les données
		// avec d'autre objet
		fextension : WideString;
		fname : WideString;
		fTypes : TStringList;
		fUnknown : TStringList;
		fHarray : TFPObjectHashTable;
		// New model - C.m. 08 03 2015
		fExtensions : TExtensions;
		fExtensionTypes : TExtensionTypes;
	private
		function GetExtension : WideString;
		procedure SetExtension(value : WideString);
		function GetTypeExtension(key : string): WideString;
	public	
		property Extension: WideString read GetExtension write SetExtension;
		property Name: WideString read fname write fname;
		procedure AddTypeExtension(vname : WideString);		
		procedure AddExtension(vname : WideString; value : WideString);
		function AddSizeExtension(key : string; size : Cardinal; WithDetails: Boolean): UInt64;
		property TypeExtension[key : string] : WideString read GetTypeExtension;
		procedure DumpStats;
		procedure DumpUnknown;
	end; 

implementation
uses IniMangt,
	 InternalTypes;

var Somme : UInt64;

constructor TFileKind.Create();
begin
	fTypes := TStringList.Create();
	fUnknown := TStringList.Create();
	fTypes.Duplicates := dupIgnore;
	fUnknown.Duplicates := dupIgnore;
	fHarray := TFPObjectHashTable.Create();
	fExtensionTypes := TExtensionTypes.Create();
	fExtensions := TExtensions.Create();
end;

destructor TFileKind.Destroy;
begin
	fHarray.free;
	fTypes.free;
	fUnknown.free;
	fExtensionTypes.free;
	fExtensions.free;
	inherited Destroy;
end;

function TFileKind.GetTypeExtension(key : string): WideString;
begin
	Result := fTypes.ValueFromIndex[((fHarray.items[Lowercase(key)]) as TUInt64).value];
end;

function TFileKind.AddSizeExtension(key : string; size : Cardinal; WithDetails: Boolean): UInt64;
var i : Integer;
var Int : TUInt64;
begin
	// Writeln('Ladies & Gentlemen, entering '+Key);
	Int := fHarray.items[Lowercase(key)] as TUInt64;
	if Assigned(Int) then
	begin
		i := Int.Value;
		// writeln('Key ' + Key + ' found. Index ' + IntToStr(Int.Value) + ' & Size = ' + IntToStr(Size));
	end	
	else
	begin
	  i := 0;
	  // writeln('Key ' + Key + ' not found. Size = '+IntToStr(Size));
	end;
	Result := (fTypes.Objects[i] as TSumInformation).AddSize(size);
	// Writeln('Result sera = {'+IntToStr(Result)+'}');
	if (i = 0) and (WithDetails) then 
	begin
	  	// writeln('Key ' + Key + ' on ajoute Size = '+IntToStr(Size)+ ' index '+ IntToStr(i));
		if (fUnknown.IndexOf(key)=-1) then
			fUnknown.add(key);
		i := fUnknown.IndexOf(key);
		if Not Assigned(fUnknown.Objects[i]) then
			fUnknown.Objects[i] := TUInt64.Create(size)
		else
			(fUnknown.Objects[i] as TUInt64).Add(size);
		Somme := Somme + Size;	
	end;
end;


procedure TFileKind.AddTypeExtension(vname : WideString);
begin
	fExtensionTypes.AddUnique(vname);
end;

procedure TFileKind.AddExtension(vname : WideString; value : WideString);
var i : Integer;
begin
	// fExtensionTypes.AddUnique(vname);	
	fExtensions.AddExtensionType(Lowercase(value),vname);
	i := fTypes.IndexOf(vname);
	if i = -1 then i := fTypes.add(vname);
	fHarray.add(Lowercase(value), TUInt64.Create(i));
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

procedure TFileKind.DumpUnknown();
var i : Integer;	
	begin
	Writeln;
	for i := 0 to pred(fUnknown.count) do
		begin
		if (fUnknown.Objects[i] as TUInt64).Value div (1024*1024*100)>1 then
			WriteLn(fUnknown.ValueFromIndex[i]+' '+GetSizeHRb((fUnknown.Objects[i] as TUInt64).Value));		
		end;
	// Writeln('Somme Unknown = ' + GetSizeHRb(Somme));
	end;

procedure TFileKind.DumpStats();
var i : Integer;	
	begin
	Writeln;
	Writeln('Type:':25 , 'Size (KiB)':25,  'Size (Human)':25);
	for i := 0 to pred(fTypes.count) do
		Writeln(fTypes.ValueFromIndex[i]:25, (fTypes.Objects[i] as TSumInformation).Size:25,  (fTypes.Objects[i] as TSumInformation).SizeHumanReadable:25);

	Writeln;
	Writeln('Value:':25 , '':25,  'Name:':25);
	for i := 0 to pred(fExtensions.count) do
		Writeln(fExtensions.ValueFromIndex[i]:25, ' = ':3, fExtensions.Names[i]:25);
	end;


end.