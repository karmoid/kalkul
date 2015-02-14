unit IniMangt;
interface
uses Classes;

type
	TAppParams = class
	private
		fUnities : TStringList;
		function EvaluateUnity(Valyou : string): UInt64;		
	public
		constructor Create();
		destructor Destroy; override;
		procedure AddUnity(Valyou : string);
	end;

function GetSizeHRb(fSize : uInt64): WideString;
function GetSizeHRk(fSize : uInt64): WideString;

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
			write('on va tester '+lowercase(Valyou[Pos]));
			case lowercase(Valyou[Pos]) of
				'b': Unite := 1;
				'k': Unite := 1 << 10;
				'm': Unite := 1 << 20;
				'g': Unite := 1 << 30;
				't': Unite := 1 << 40;
				else 
					Unite := 0;
			end;
			writeln(' unite = '+IntToStr(Unite));
		end;	
		Val(LeftStr(Valyou,Pos-1),Valeur,Pos);
		if (Unite>0) and (Pos = 0) then
			Result := Unite * Valeur;	
	end;

// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// Ajout d'une unité à la liste.
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
procedure TAppParams.AddUnity(Valyou : string);
	begin
		fUnities.Add(Valyou);
		writeln('Giving '+Valyou+' I find the value '+IntToStr(EvaluateUnity(Valyou)))
	end;

// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// Procedure interne utilitaire
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
function GetSizeHRAny(fSize : uInt64; IndexV : Integer): WideString;
const Units : array[1..5] of string = ('','Kib','Mib','Gib','Tib');
var index : Integer;
	isize : UInt64;
begin
	index := IndexV;
	isize := fsize;
	while (index<=5) and (isize>1024) do
	begin
		index := index + 1;
		isize := isize div 1024;	
	end;
	result := IntToStr(isize) + ' ' + Units[index];	
end;

// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// Expression en forme Humaine
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
function GetSizeHRb(fSize : uInt64): WideString;
begin
	Result := GetSizeHRAny(fSize,1);
end;

// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// Expression en forme Humaine
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
function GetSizeHRk(fSize : uInt64): WideString;
begin
	Result := GetSizeHRAny(fSize,2);
end;
end.