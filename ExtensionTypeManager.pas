unit ExtensionTypeManager;

interface
uses sysUtils, 
    Extensions,
	ExtensionTypes,
	RegExpressions;

type TExtensionTypeManager = class
	private
		fExtensions : TExtensions;
		fExtensionTypes : TExtensionTypes;
		fRegExpressions : TRegExpression;
	public
		constructor Create();
		destructor Destroy; override;
		procedure AddExtensionType(ExtType : String);
		procedure AddExtension(Ext : String; ExtType : String);
		function GetExtensionType (S : String) : String;
		procedure DumpExtensions();
		property Extensions: TExtensions read FExtensions;
		property ExtensionTypes: TExtensionTypes read FExtensionTypes;
		property RegExpressions: TRegExpression read FRegExpressions write FRegExpressions;
end;
	EExtensionsTypeNotSet = class(Exception);
implementation
uses
	InternalTypes;

constructor TExtensionTypeManager.Create();
begin
	fExtensions := TExtensions.Create();
	fExtensionTypes := TExtensionTypes.Create();	
	fRegExpressions := TRegExpression.Create();
end;

destructor TExtensionTypeManager.Destroy;
begin
	fExtensions.free;
	fExtensionTypes.free;
	fRegExpressions.free;
	inherited Destroy;
end;

function TExtensionTypeManager.GetExtensionType (S : String) : String;
var Ext : string;
var i : integer;
begin
	Ext := ExtractFileExt(S);
	Result := Extensions.ExtensionType[Ext];
	if Result='' then
	begin
		for i:= 0 to pred(RegExpressions.count) do
		begin
			//Writeln(i,': fic:',S,'/',RegExpressions.names[i],' - ',RegExpressions.TypeExtension[i]);
			Result := GetExtensionTypeFromRegExp(RegExpressions.names[i],S,RegExpressions.TypeExtension[i]);
			if Result <> '' then 
			begin
				// writeln('TROUVE ! donne ', Result);
				break;
			end;
		end;
	end	;
end;

procedure TExtensionTypeManager.AddExtensionType(ExtType : String);
begin
	ExtensionTypes.AddUnique(ExtType);
end;

procedure TExtensionTypeManager.AddExtension(Ext : String; ExtType : String);
begin
	if ExtensionTypes.Indexof(ExtType)<>-1 then
	begin
		if RegularExpression(Ext) then
		begin
			// Writeln('ajoute ExpReg ',Ext,' sur ',ExtType);
			RegExpressions.addRegExpression(Ext,ExtType);
		end	
		else
			Extensions.AddExtensionType(Ext,ExtType);
	end	
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