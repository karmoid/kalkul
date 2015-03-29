// Tableau/Liste contenant la référence des extensions connues
// Nous nous servirons des index de ces Clef pour référencer 
// ailleurs les liens avec ces extensions (gains de place)
//
unit Extensions;

interface

uses classes,
	 sysUtils;

type
	TExtensions = class(TStringList)
	protected
		// (object associé) mysuminfo : Tsuminfo;
	private
		function GetExtensionType(Key : String) : String;
		procedure SetExtensionType(Key : String; value : String);
	public	
		constructor Create(); 
		destructor Destroy; override;
		property ExtensionType[Key : String] : String read GetExtensionType write SetExtensionType;
		procedure AddExtensionType(Ext: String; ExtType: String);
	end; 
	EExtensionsNotUnique = class(Exception);

implementation

constructor TExtensions.Create();
begin
	Duplicates := dupError;
	OwnsObjects := False;
	Sorted := True;	
end;

destructor TExtensions.Destroy; 
begin
	inherited Destroy;
end;

procedure TExtensions.AddExtensionType(Ext: String; ExtType: string);
var Dup : string;
begin
	try
		Values[Ext] := ExtType;
	except 
		on EStringListError do 
		begin
			Dup := Values[Ext];
			raise EExtensionsNotUnique.create('['+ExtType+Ext+'] duplicates on type ['+Dup+']');
		end;	
	end;
end;

function TExtensions.GetExtensionType(Key : String) : String;
begin
	result := Values[Key];
end;

procedure TExtensions.SetExtensionType(Key : String; value : String);
begin
	Values[Key] := Value;
end;


end.