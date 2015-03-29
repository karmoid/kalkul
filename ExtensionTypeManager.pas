unit ExtensionTypeManager;

interface
uses sysUtils, 
    Extensions,
	ExtensionTypes;

type TExtensionTypeManager = class
	private
		fExtensions : TExtensions;
		fExtensionTypes : TExtensionTypes;
	public
		constructor Create();
		destructor Destroy; override;
		procedure AddExtensionType(ExtType : String);
		procedure AddExtension(Ext : String; ExtType : String);
		function GetExtensionType (S : String) : String;
		procedure DumpExtensions();
		property Extensions: TExtensions read FExtensions;
		property ExtensionTypes: TExtensionTypes read FExtensionTypes;
end;
	EExtensionsTypeNotSet = class(Exception);
implementation

constructor TExtensionTypeManager.Create();
begin
	fExtensions := TExtensions.Create();
	fExtensionTypes := TExtensionTypes.Create();	
end;

destructor TExtensionTypeManager.Destroy;
begin
	fExtensions.free;
	fExtensionTypes.free;
	inherited Destroy;
end;

function TExtensionTypeManager.GetExtensionType (S : String) : String;
begin
	Result := Extensions.ExtensionType[S];
end;

procedure TExtensionTypeManager.AddExtensionType(ExtType : String);
begin
	ExtensionTypes.AddUnique(ExtType);
end;

procedure TExtensionTypeManager.AddExtension(Ext : String; ExtType : String);
begin
	if ExtensionTypes.Indexof(ExtType)<>-1 then
		Extensions.AddExtensionType(Ext,ExtType)
	else
		raise EExtensionsTypeNotSet.create('['+ExtType+'] not set.');

end;

procedure TExtensionTypeManager.DumpExtensions();
var i : Integer;	
begin
	Writeln;
	Writeln('Value:':25 , '':3,  'Name:':25);
	for i := 0 to pred(Extensions.count) do
		with Extensions do
			Writeln(ValueFromIndex[i]:25,' = ':3, Names[i]:25);
end;

end.