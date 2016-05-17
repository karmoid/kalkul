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
    fExceptAndIncludeExpr : TRegExpression;
	public
		constructor Create();
		destructor Destroy; override;
		procedure AddExtensionType(ExtType : String);
		procedure AddExtension(Ext : String; ExtType : String);
		function GetExtensionType (S : String) : String;
    function IsPathExcluded(Gname : String; Path: string) : Boolean;
		procedure DumpExtensions();
    procedure AddIncExclPathRegExp(RegExpLabel : String; ExtRegExp : String);
		property Extensions: TExtensions read FExtensions;
		property ExtensionTypes: TExtensionTypes read FExtensionTypes;
		property RegExpressions: TRegExpression read FRegExpressions write FRegExpressions;
    property ExceptAndIncludeExpr: TRegExpression read fExceptAndIncludeExpr write fExceptAndIncludeExpr;
end;
	EExtensionsTypeNotSet = class(Exception);
  EExtensionsExceptRuleExists = class(Exception);
  EExtensionsIsNotRegExp = class(Exception);
implementation
uses
	InternalTypes;

constructor TExtensionTypeManager.Create();
begin
	fExtensions := TExtensions.Create();
	fExtensionTypes := TExtensionTypes.Create();
	fRegExpressions := TRegExpression.Create();
  fExceptAndIncludeExpr := TRegExpression.Create();
  fExceptAndIncludeExpr.Sorted := False;
end;

destructor TExtensionTypeManager.Destroy;
begin
	fExtensions.free;
	fExtensionTypes.free;
	fRegExpressions.free;
  fExceptAndIncludeExpr.free;
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
			// Writeln(i,': fic:',S,'/',RegExpressions.names[i],' - ',RegExpressions.TypeExtension[i]);
			Result := GetExtensionTypeFromRegExp(RegExpressions.names[i],S,RegExpressions.TypeExtension[i]);
			if Result <> '' then
			begin
				// writeln('TROUVE ! donne ', Result);
				break;
			end;
		end;
	end	;
  if (Result='') and (Length(Ext)>4) then
  begin
    // Writeln('fic:',S);
    // writeln('Extension longue (' + IntToStr(Length(Ext))+ ') et pas de RegularExpression :  [' + Ext + ']');
  end;
end;

procedure TExtensionTypeManager.AddExtensionType(ExtType : String);
begin
	ExtensionTypes.AddUnique(ExtType);
end;

procedure TExtensionTypeManager.AddIncExclPathRegExp(RegExpLabel : String; ExtRegExp : String);
begin
  // writeln(RegExpLabel+' ajoute à la liste avec RegExp '+ExtRegExp+', IndexOf:'+IntToStr(ExceptAndIncludeExpr.Indexof(RegExpLabel)));
	if ExceptAndIncludeExpr.Indexof(RegExpLabel)=-1 then
	begin
		if RegularExpression(ExtRegExp) then
		begin
			Writeln('ajoute ExceptInclude ExpReg ',ExtRegExp);
			ExceptAndIncludeExpr.addRegExpression(RegExpLabel,ExtRegExp);
		end
		else
      raise EExtensionsIsNotRegExp.create('['+RegExpLabel+'] ExceptInclude rule is not RegExp : '+ExtRegExp);
	end
	else
		raise EExtensionsExceptRuleExists.create('['+RegExpLabel+'] ExceptInclude rule already set.');
end;

function TExtensionTypeManager.IsPathExcluded(GName : String; Path: string) : Boolean;
var i : Integer;
var Exclude, Found : Boolean;
var DumpIt : Boolean;
begin
  Result := false;
  DumpIt := false;
	for i := 0 to pred(ExceptAndIncludeExpr.count) do
		with ExceptAndIncludeExpr do
    begin
      Exclude := Names[i][1] = '-';
      Found := GetExtensionTypeFromRegExp(ValueFromIndex[i],Path,GName)<>'';
      // DumpIt := DumpIt or Found;
      If Found then
        Result := Exclude;
        // Writeln(ValueFromIndex[i]:60,cTrueFalse[Found]:8, cTrueFalse[Exclude]:8);
    end;
  if DumpIt then
  begin
    Writeln(Path:60 , 'Found':8,  'Exclude':8);
  	for i := 0 to pred(ExceptAndIncludeExpr.count) do
  		with ExceptAndIncludeExpr do
      begin
        Exclude := Names[i][1] = '-';
        Found := GetExtensionTypeFromRegExp(ValueFromIndex[i],Path,Gname)<>'';
        Writeln(ValueFromIndex[i]:60,cTrueFalse[Found]:8, cTrueFalse[Exclude]:8);
      end
  end;
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
