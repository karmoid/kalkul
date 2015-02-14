// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//
// Ini management : Chargement des options de fichiers .INI
// Permet d'exploiter les paramétres en fichier de configuration
// et (a faire...) en overide ligne de commande
//
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
unit IniMangt;
interface
uses Classes,
	InternalTypes;

type

	TAppParams = class
	private
		fUnities : TStringList;			// Liste des unités de regroupement
		function EvaluateUnity(Valyou : string): UInt64;		
		function GetNames(Index : Integer) : String;
		procedure SetNames(Index : Integer; Value : String);
		function GetValues(Index : Integer) : UInt64;
		procedure SetValues(Index : Integer; Value : UInt64);

	public
		constructor Create();
		destructor Destroy; override;
		procedure AddUnity(Valyou : string);
		property Names [Index : Integer] : String read GetNames write SetNames;
		property Values [Index : Integer] : UInt64 read GetValues write SetValues;
	end;

implementation
uses SysUtils;

constructor TAppParams.Create();
	begin
	fUnities := TStringList.Create();
	end;

destructor TAppParams.Destroy;
	begin
	fUnities.free;
	inherited Destroy;		
	end;

// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//
// Analyse du genre de section suivante :
// [SizeDetails]
// Size1k=1k
// Size1M=1m
// Size100M=100m
// Size1G=1G
// Size1T=1t
//
// Code de chargement (exemple)
//
// Var Params : TAppParams;
//
// Type tSections = (tsExtensions,tsDrives,tsSettings,tsSizes);
// 
// Const cSections : array [low(tSections)..high(tSections)] of String = (
// 		'extensions',
// 		'drives',
// 		'settings',
// 		'sizedetails');
//
// Params := TAppParams.create;
// LoadUnities;
//
// procedure LoadUnities();
// var Sections : TStringList;
// 	Counter : Integer;

// begin
// 	Sections := TStringList.create();

// 	IniF.ReadSectionValues(cSections[tsSizes], Sections);
// 	for Counter := 0 to Pred(Sections.count) do
// 	begin
// 		Params.AddUnity(Sections.ValueFromIndex[Counter]);
// 	end;
// 	Sections.free;
// end;
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

function TAppParams.EvaluateUnity(Valyou : String): UInt64;
var Valeur : Integer;
	Unite : UInt64;
	Pos : Word;
	begin
		Result := 0;
		Val(Valyou,Valeur,Pos);
		if Pos <> 0 then
		begin
			// write('on va tester '+lowercase(Valyou[Pos]));
			case lowercase(Valyou[Pos]) of
				'b': Unite := 1;
				'k': Unite := 1 << 10;
				'm': Unite := 1 << 20;
				'g': Unite := 1 << 30;
				't': Unite := 1 << 40;
				else 
					Unite := 0;
			end;
			// writeln(' unite = '+IntToStr(Unite));
		end;	
		Val(LeftStr(Valyou,Pos-1),Valeur,Pos);
		if (Unite>0) and (Pos = 0) then
			Result := Unite * Valeur;	
	end;

// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// Ajout d'une unité à la liste.
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
procedure TAppParams.AddUnity(Valyou : string);
var Index : Integer;	
	begin
		Index := fUnities.AddObject(Valyou, TUint64.Create(EvaluateUnity(Valyou)));
		// writeln('Giving '+Valyou+' I find the value '+IntToStr(TUint64(fUnities.Objects[Index]).value));
	end;

// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// Expression en forme Humaine
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
function TAppParams.GetNames(Index : Integer) : String;
begin
	Result := fUnities[Index];
end;

// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// Expression en forme Humaine
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
procedure TAppParams.SetNames(Index : Integer; Value : String);
begin
	
end;

// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// Expression en forme Humaine
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
function TAppParams.GetValues(Index : Integer) : UInt64;
begin
	Result := TUint64(fUnities.Objects[Index]).Value;
end;

// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// Expression en forme Humaine
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
procedure TAppParams.SetValues(Index : Integer; Value : UInt64);
begin
	
end;

end.