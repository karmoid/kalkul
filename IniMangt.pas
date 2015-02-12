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

procedure TAppParams.AddUnity(Valyou : string);
	begin
		fUnities.Add(Valyou);
		writeln('Giving '+Valyou+' I find the value '+IntToStr(EvaluateUnity(Valyou)))
	end;

end.