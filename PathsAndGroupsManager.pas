unit PathsAndGroupsManager;

interface
uses sysUtils, 
    SpecificPaths,
	PathGroups;

type TPathsAndGroupsManager = class
	private
		fPaths : TSpecificPaths;
		fPathNames : TSpecificPaths;
		fGroups : TPathGroups;
	public
		constructor Create();
		destructor Destroy; override;
		procedure DumpPathsAndGroups();
		procedure AddPath(Child : String; S: String);
		procedure AddPathName(Child : String; S: String);
		procedure AddSpecificGroup(S : String);		
		procedure AddSpecificPathName(S : String);		
		procedure AddSpecificPath(S: string);
		function FindGroupByPath(S : String) : string;
		function GetExtensionType(key : string; GName : String): String;

		property Paths: TSpecificPaths read fPaths;
		property PathNames: TSpecificPaths read fPathNames;
		property Groups: TPathGroups read fGroups;
	end;
	ESpecificGroupNotSet = class(Exception);
	ESpecificPathNameNotSet = class(Exception);
	ESpecificPathNotSet = class(Exception);

implementation
uses InternalTypes,
	ExtensionTypeManager;

constructor TPathsAndGroupsManager.Create();
begin
	fPaths := TSpecificPaths.create();
	fPathNames := TSpecificPaths.create();
	fGroups := TPathGroups.create();
end;

destructor TPathsAndGroupsManager.Destroy;
begin
	fPaths.free;
	fPathNames.free;
	fGroups.free;
	inherited Destroy;
end;

procedure TPathsAndGroupsManager.AddPath(Child : String; S: String);
var i : Integer;	
begin
	// Writeln('On ajoute le path '+Child+', avec le specificpathname '+S);
	if PathNames.ReferenceExists(S) then
	begin
		Paths.AddSpecificPath(Child,S);
	end	
	else	
		raise ESpecificPathNotSet.create('['+S+'] not set.');
end;	

procedure TPathsAndGroupsManager.AddPathName(Child : String; S: String);
var i : Integer;	
begin
	// Writeln('On ajoute le specificpathname '+Child+', avec le groupe '+S);
	if Groups.ReferenceExists(S) then
		PathNames.AddSpecificPath(Child,S)
	else	
		raise ESpecificPathNameNotSet.create('['+S+'] not set.');
end;	

procedure TPathsAndGroupsManager.AddSpecificPathName(S : String);
begin
	PathNames.AddUnique(S);
end;

procedure TPathsAndGroupsManager.AddSpecificPath(S : String);
begin
	Paths.AddUnique(S);
end;

procedure TPathsAndGroupsManager.AddSpecificGroup(S : String);
begin
	Groups.AddUnique(S);
end;

procedure TPathsAndGroupsManager.DumpPathsAndGroups();
var i : Integer;	
begin
	Writeln;
	Paths.dumpData('Paths');			
	PathNames.dumpData('PathNames');			
	Groups.dumpData('Groups');		
end;

function TPathsAndGroupsManager.FindGroupByPath(S : String) : string;
var PathName : string;
begin
	Result := '';
	PathName := Paths.Values[NormalizePath(S)];
	if PathName<>'' then
	  Result := PathNames.Values[PathName];
end;

function TPathsAndGroupsManager.GetExtensionType(key : string; GName : String): String;
var Extensions : TExtensionTypeManager;
begin
	Result := '';
	if GName<>'' then
	begin
		Extensions := Groups.ExtensionTypeMan(GName);
		Result := Extensions.GetExtensionType(Key);
	end;
end;

end.