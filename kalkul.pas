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

function ProcessTree(Src, FileSpec : string; Depth: Integer; GroupName : String): Cardinal;
Var Info : TSearchRec;
	Count : Longint = 0;
	TypeExt : String;
	PI : tPathInfo;
	WGpName : String;
begin
if Depth>0 then
	begin
	//Writeln('Ajoute '+FileSpec);
	PI := Tree.AddPathInfo(FileSpec);
	WGpName := Params.FindGroupByPath(FileSpec);
	if WGpName <> '' then
	  GroupName := WGpName;

	If FindFirst (FileSpec+'*',faAnyFile and faDirectory, Info)=0 then
	    begin
	    Repeat
	    	Inc(Count);
	    	With Info do
	    	begin
		    If (Attr and faDirectory) = faDirectory then
		        begin
			        if Name[1] <> '.' then Count := Count + ProcessTree(Src,FileSpec+Name+'\',Depth-1,GroupName);
		        end
		    else
			    begin
			    	// remplacer Ext par ExtractFileExt(Info.Name)
			    	// Params.AddSizeExtension(ExtractFileExt(Name),Info,Params.SettingsKeepUDetails,GroupName);
			    	// PI Gère un Item
			    	TypeExt := Params.GetExtensionType(lowerCase(ExtractFileExt(Info.Name)),GroupName);
			    	//Writeln('TypeExtension de ',lowerCase(ExtractFileExt(Info.Name)),',',GroupName,' = ',TypeExt);
			    	//if GroupName<>'' then
			    	//	Writeln('TypeExt = [',TypeExt,'] pour ',lowerCase(ExtractFileExt(Info.Name)),' dans ',GroupName);
			    	PI.AddSizeExtension(Info,TypeExt);
			    	Params.SourceSet.AddSizeFromInfo(Info,TypeExt,Src); // gère x Items
			    	Params.GroupSet.AddSizeFromInfo(Info,TypeExt,GroupName); // gère x Items
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
var Src : String;
var srcfile : TextFile;
Begin
	Params := TAppParams.create(cIniFile);

	//Params.DumpPaths;
  	Tree := PopulateTree;
	imax := WordCount(Params.SettingsSrc,[',']);
	for i := 1 to imax do
	begin
		Src := ExtractWord(i,Params.SettingsSrc,[',']);
		Write('Processing... ' + Src + ':\ -> ');
		Writeln(IntToStr(ProcessTree(Src,ExtractWord(i,Params.SettingsSrc,[','])+':\',Params.SettingsDepth,'')) + ' files');
	end;
	// Params.Extensions.DumpStats;
	// Params.DumpExtensions;
	//Params.DumpPaths;
	Params.DumpExtType;
	Writeln('SOURCES:');
	writeln(Params.SourceSet.GetJSON);
	assignfile(srcfile, 'sources.json');
	rewrite(srcfile);
	Writeln(srcfile,Params.SourceSet.GetJSON);
	closefile(srcfile);
	Writeln('GROUPES:');
	writeln(Params.GroupSet.GetJSON);


	Params.free;
	Tree.free;
End.
