// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//
// Specific Paths : Load all definiton for Specific Paths
//
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
unit SpecificPath;
interface
uses Classes,
	SysUtils;

type
	
	TSpecificPath = class
	private
		fSpecificPathName : String;		// Nom du Path Spécifique
		fPaths : TStringList;
		fGroupName : String;			// Liste des chemins 
		procedure SetGroupName(S : String);

	public	
		constructor Create(PathName : String; Paths : String);
		destructor Destroy; Override;
		property Paths: TStringList read FPaths;
		property GroupName: String read FGroupName write SetGroupName;
	end;
	ESpecificPathGroupDuplicate = class(Exception);

Implementation

constructor TSpecificPath.Create(PathName : String; Paths : String);
begin
	fSpecificPathName := PathName;
	fPaths := TStringList.create();
// Important : Needed for Space in paths	
	fPaths.Delimiter := ',';
	fPaths.StrictDelimiter := True;
	fPaths.Delimitedtext := Paths;
end;

destructor TSpecificPath.Destroy; 
begin
	// writeln(fSpecificPathName+ ' -> ' + fPaths.Commatext);
	fPaths.free;
	fSpecificPathName := '';	
	fGroupName := '';
	inherited Destroy;
end;

procedure TSpecificPath.SetGroupName(S : String);
begin
	if fGroupName='' then
		fGroupName := S
	else
		raise ESpecificPathGroupDuplicate.create('['+S+'] Duplicates');
end;

end.	