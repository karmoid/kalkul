unit PathGroups;

interface

uses classes,
	 sysUtils,
//	 DirectoryStat,
	 ExtensionTypeManager;

type
	TPathGroups = class(TStringList)
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
		procedure AddGroup(P: String; Gname: String);
		function AddUnique(S : String) : Integer; 	
		function ReferenceExists(S : String) : Boolean;
		function ExtensionTypeMan(S : String) : TExtensionTypeManager;
		procedure DumpData(S : String);

	end; 
	EPathGroupsNotUnique = class(Exception);

implementation

constructor TPathGroups.Create();
begin
	fReference := TStringList.create();
	fReference.Duplicates := dupError;
	fReference.Sorted := true;
	fReference.OwnsObjects := true;	
	Duplicates := dupError;
	OwnsObjects := False;
	Sorted := True;	
end;

destructor TPathGroups.Destroy; 
begin
	fReference.free;	
	inherited Destroy;
end;

Procedure TPathGroups.AddGroup(P: String; Gname: String);
var Dup : string;
begin
	try
		GroupName[LowerCase(P)] := LowerCase(GName);
	except 
		on EStringListError do 
		begin
			Dup := Values[LowerCase(P)];
			raise EPathGroupsNotUnique.create('['+Gname+'->'+P+'] duplicates on type ['+Dup+']');
		end;	
	end;
end;

function TPathGroups.GetGroupName(Key : String) : String;
begin
	result := Values[LowerCase(Key)];
end;

procedure TPathGroups.SetGroupName(Key : String; value : String);
begin
	// writeln('Set GroupName[',Key,'] a [',Value,']');
	Values[LowerCase(Key)] := LowerCase(Value);
end;

function TPathGroups.AddUnique(S : String) : Integer; 
begin
	try
		// writeln('ajout PathGroups de ',S);
		Result := fReference.Add(LowerCase(S));		
		fReference.objects[Result] := TExtensionTypeManager.Create();
	except 
		on EStringListError do raise EPathGroupsNotUnique.create('['+S+'] Duplicates');
	end;
end;	

function TPathGroups.ReferenceExists(S : String) : Boolean;
begin
	Result := fReference.indexOf(Lowercase(S))<>-1;
end;

function TPathGroups.ExtensionTypeMan(S : String) : TExtensionTypeManager;
var i : Integer;
begin
	result := nil;
	i := fReference.indexOf(Lowercase(S));
	if i<>-1 then
	  Result := fReference.objects[i] as TExtensionTypeManager;
end;

procedure TPathGroups.dumpData(S : String);
var i : Integer;	
begin
	Writeln(S:10,' Value:':25 , '':3,  'Name:':25);
	for i := 0 to pred(fReference.count) do
	begin
		Writeln(i:10,' => ':4,fReference[i]:25);
		(fReference.objects[i] as TExtensionTypeManager).DumpExtensions;
	end;	
end;

end.