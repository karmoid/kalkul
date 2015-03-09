// Tableau/Liste contenant les noms regroupant les extensions connues
// Nous nous servirons des index de ces Clef pour référencer 
// ailleurs les liens avec ces noms (gains de place)
//
unit ExtensionTypes;

interface
uses Classes,
	 sysUtils;

type
	TExtensionTypes = class(TStringList)
	protected
		// (object associé) fMyExtensions : TExtensions;

	private

	public
		constructor Create(); 
		destructor Destroy; override;
		function AddUnique(S : String) : Integer; 
	end; 	

	EExtensionTypesNotUnique = class(Exception);

implementation

constructor TExtensionTypes.Create();
begin
	Duplicates := dupError;
	OwnsObjects := False;
	Sorted := True;
end;

destructor TExtensionTypes.Destroy; 
begin
	inherited Destroy;
end;


function TExtensionTypes.AddUnique(S : String) : Integer; 
begin
	try
		Result := inherited Add(S);	
	except 
		on EStringListError do raise EExtensionTypesNotUnique.create('['+S+'] Duplicates');
	end;	
end;

end.