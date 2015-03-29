unit SpecificPaths;

interface

uses classes,
	 sysUtils;

type
	TSpecificPaths = class(TStringList)
	protected
		// (object associé) mysuminfo : Tsuminfo;
	private
		fReference : TStringList;
		function GetGroupName(Key : String) : String;
		procedure SetGroupName(Key : String; value : String);
	public	
		constructor Create(); 
		destructor Destroy; override;
		property GroupName[Key : String] : String read GetGroupName write SetGroupName;
		procedure AddSpecificPath(P: String; Gname: String);
		function AddUnique(S : String) : Integer; 
		function ReferenceExists(S : String) : boolean;
		procedure dumpData(S : String);
	end; 
	ESpecificPathsNotUnique = class(Exception);

implementation

constructor TSpecificPaths.Create();
begin
	fReference := TStringList.create();
	fReference.Duplicates := dupError;
	fReference.Sorted := true;
	Duplicates := dupError;
	OwnsObjects := False;
	Sorted := True;	
end;

destructor TSpecificPaths.Destroy; 
begin
	fReference.free;
	inherited Destroy;
end;

Procedure TSpecificPaths.AddSpecificPath(P: String; Gname: String);
var Dup : string;
begin
	try
		GroupName[LowerCase(P)] := Lowercase(GName);
		// writeln('SpecificPaths : on set Values[',P,'] := ',Gname)
	except 
		on EStringListError do 
		begin
			Dup := Values[LowerCase(P)];
			raise ESpecificPathsNotUnique.create('['+Gname+'->'+P+'] duplicates on type ['+Dup+']');
		end
		else
		  raise;	
	end;
end;

function TSpecificPaths.GetGroupName(Key : String) : String;
begin
	result := Values[LowerCase(Key)];
end;

procedure TSpecificPaths.SetGroupName(Key : String; value : String);
begin
	Values[LowerCase(Key)] := LowerCase(Value);
end;

function TSpecificPaths.AddUnique(S : String) : Integer; 
begin
	try
		Result := fReference.Add(LowerCase(S));	
	except 
		on EStringListError do raise ESpecificPathsNotUnique.create('['+S+'] Duplicates');
	end;
end;	

function TSpecificPaths.ReferenceExists(S : String) : Boolean;
begin
	Result := fReference.indexOf(Lowercase(S))<>-1;
end;

procedure TSpecificPaths.dumpData(S : String);
var i : Integer;	
begin
	Writeln(S:10,' Value:':25 , '':3,  'Name:':25);
	for i := 0 to pred(count) do
		Writeln(i:10,Names[i]:25, ' = ':3, ValueFromIndex[i]:25);
end;

end.