// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//
// Specific Paths : Load all definiton for Specific Paths
//
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
unit SpecificPath;
interface
uses Classes;

type
	
	TSpecificPath = class
	private
		fSpecificPathName : String;		// Nom du Path Spécifique
		fPaths : TStringList;			// Liste des chemins 

	public	
		constructor Create(PathName : String; Paths : String);
		destructor Destroy; Override;
		property Paths: TStringList read FPaths;
	end;

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
	inherited Destroy;
end;

end.	