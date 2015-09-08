// Tableau/Liste contenant les noms regroupant les extensions connues
// Nous nous servirons des index de ces Clef pour référencer 
// ailleurs les liens avec ces noms (gains de place)
//
unit RegExpressions;

interface
uses Classes,
	 sysUtils;

type
	TRegExpression = class(TStringList)
	protected

	private
		function GetTypeExtension(i : integer) : AnsiString;
		procedure SetTypeExtension(i : integer; Value : AnsiString);

	public
		constructor Create(); 
		destructor Destroy; override;
		function AddRegExpression(S : String; TypeExt : AnsiString) : Integer; 
		property TypeExtension[i: integer] : AnsiString read GetTypeExtension write SetTypeExtension;
	end; 	

implementation

constructor TRegExpression.Create();
begin
	Duplicates := dupError;
	OwnsObjects := False;
	Sorted := True;
end;

destructor TRegExpression.Destroy; 
begin
	inherited Destroy;
end;


function TRegExpression.GetTypeExtension(i : integer) : AnsiString;
	begin
		Result := ValueFromIndex[i];
	end;

procedure TRegExpression.SetTypeExtension(i : integer; Value : AnsiString);
	begin
		ValueFromIndex[i] := Value;
	end;

function TRegExpression.AddRegExpression(S : String; TypeExt : AnsiString) : Integer; 
	begin
		Values[S]:=TypeExt;
	end;


end.