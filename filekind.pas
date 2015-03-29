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
		// a terme on doit utiliser l'objet ExtensionTypes pour partager les données
		// avec d'autre objet
		fextension : WideString;
		fname : WideString;
		fTypes : TStringList;
		fUnknown : TStringList;
		fHarray : TFPObjectHashTable;
	private

	public	
		property Name: WideString read fname write fname;
		// function AddSizeExtension(key : string; size : Cardinal; WithDetails: Boolean): UInt64;
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
	// fExtensionTypes := TExtensionTypes.Create();
	// fExtensions := TExtensions.Create();
end;

destructor TFileKind.Destroy;
begin
	fHarray.free;
	fTypes.free;
	fUnknown.free;
	inherited Destroy;
end;

// function TFileKind.AddSizeExtension(key : string; size : Cardinal; WithDetails: Boolean): UInt64;
// var i : Integer;
// var Int : TUInt64;
// begin
// 	// Writeln('Ladies & Gentlemen, entering '+Key);
// 	Int := fHarray.items[Lowercase(key)] as TUInt64;
// 	if Assigned(Int) then
// 	begin
// 		i := Int.Value;
// 		// writeln('Key ' + Key + ' found. Index ' + IntToStr(Int.Value) + ' & Size = ' + IntToStr(Size));
// 	end	
// 	else
// 	begin
// 	  i := 0;
// 	  // writeln('Key ' + Key + ' not found. Size = '+IntToStr(Size));
// 	end;
// 	Result := (fTypes.Objects[i] as TSumInformation).AddSize(size);
// 	// Writeln('Result sera = {'+IntToStr(Result)+'}');
// 	if (i = 0) and (WithDetails) then 
// 	begin
// 	  	// writeln('Key ' + Key + ' on ajoute Size = '+IntToStr(Size)+ ' index '+ IntToStr(i));
// 		if (fUnknown.IndexOf(key)=-1) then
// 			fUnknown.add(key);
// 		i := fUnknown.IndexOf(key);
// 		if Not Assigned(fUnknown.Objects[i]) then
// 			fUnknown.Objects[i] := TUInt64.Create(size)
// 		else
// 			(fUnknown.Objects[i] as TUInt64).Add(size);
// 		Somme := Somme + Size;	
// 	end;
// end;

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

	end;
end.