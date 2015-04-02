program kalcul;
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  Marc CHAUFFOUR - january 2015
  Personal project - maybe used on Rooms estimates

  kalkul : Volume estimation / update view
  acquire data about files : min size, max size, min modified date, max modified date, ...
  Goals : ability to understand how the files are stored and used in each directory
  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- }

Uses 
	Classes,
	PathTree,
	IniMangt,
	StrUtils,
	SpecificPath,
	pathinfo,
	Contnrs,
	SysUtils,
	InternalTypes;

Var Tree : TPathTree;
	i,imax : Integer;
	Params : TAppParams;

Const cIniFile = 'kalkul.ini';

function ProcessTree(FileSpec : string; Depth: Integer; GroupName : String): Cardinal;
Var Info : TSearchRec;
	Count : Longint = 0;
	PI : tPathInfo;
begin
if Depth>0 then
	begin
	//Writeln('Ajoute '+FileSpec);
	PI := Tree.AddPathInfo(FileSpec);
	PI.GroupName := Params.FindGroupByPath(FileSpec);
	if PI.GroupName = '' then
	  PI.GroupName := GroupName
	else
	  GroupName := PI.GroupName;  

	If FindFirst (FileSpec+'*',faAnyFile and faDirectory, Info)=0 then
	    begin
	    Repeat
	    	Inc(Count);
	    	With Info do
	    	begin
		    If (Attr and faDirectory) = faDirectory then
		        begin
			        if Name[1] <> '.' then Count := Count + ProcessTree(FileSpec+Name+'\',Depth-1,GroupName);
		        end
		    else
			    begin
			    	Params.AddSizeExtension(ExtractFileExt(Name),Info,Params.SettingsKeepUDetails,GroupName);
			    	PI.AddSizeExtension(ExtractFileExt(Name),Info,Params.SettingsKeepUDetails,GroupName);
		    	end;
			end;
	    Until FindNext(info)<>0;
	    end;
	FindClose(Info);
	end;
Result := Count;
end;

function PopulateTree : TPathTree;
var i,j : Integer;
var pi : tPathInfo;
begin
	Result := TPathTree.create;
	for i := 0 to pred(Params.SpecificPaths.Count) do
 		Result.AddPathInfo(Params.SpecificPaths.Names[i]).State := tpisConfigured;
end;

// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Main entry...
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Begin
	Params := TAppParams.create(cIniFile);

	//Params.DumpPaths;
  	Tree := PopulateTree;
	imax := WordCount(Params.SettingsSrc,[',']);
	for i := 1 to imax do
	begin
		Write('Processing... ' + ExtractWord(i,Params.SettingsSrc,[','])+':\ -> ');
		Writeln(IntToStr(ProcessTree(ExtractWord(i,Params.SettingsSrc,[','])+':\',Params.SettingsDepth,'')) + ' files');
	end;
	// Params.Extensions.DumpStats;
	// Params.DumpExtensions;
	//Params.DumpPaths;
	Params.DumpExtType;

	Params.free;
	Tree.free;
End.
