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
	DateUtils,
	FileInfoSet,
	InternalTypes,
	Zipper;

Var Tree : TPathTree;
	i,imax : Integer;
	Params : TAppParams;
    Src : String;
    Start : TdateTime;

Const cIniFile = 'kalkul.ini';

function ProcessTree(Src, FileSpec : string; Depth: Integer; GroupName : String): Cardinal;
Var Info : TSearchRec;
	Count : Longint = 0;
	TypeExt : String;
	PI : tPathInfo;
	WGpName,WSpecific : String;
	LimIndex : Integer;
begin
if Depth>0 then
	begin
	//Writeln('Ajoute '+FileSpec);
	PI := Tree.AddPathInfo(FileSpec);
	WSpecific := Params.FindSpecificByPath(FileSpec);
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
			    	LimIndex := Params.GetLimitIndex(Info);
			    	TypeExt := Params.GetExtensionType(lowerCase(ExtractFileExt(Info.Name)),GroupName);
			    	//Writeln('TypeExtension de ',lowerCase(ExtractFileExt(Info.Name)),',',GroupName,' = ',TypeExt);
			    	//if GroupName<>'' then
			    	//	Writeln('TypeExt = [',TypeExt,'] pour ',lowerCase(ExtractFileExt(Info.Name)),' dans ',GroupName);
			    	PI.AddSizeExtension(Info,LimIndex,TypeExt);
			    	Params.SourceSet.AddSizeFromInfo(Info,LimIndex,TypeExt,Src); // gère x Items
			    	Params.GroupSet.AddSizeFromInfo(Info,LimIndex,TypeExt,GroupName); // gère x Items
			    	Params.SpecificSet.AddSizeFromInfo(Info,LimIndex,TypeExt,WSpecific); // gère x Items
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

procedure SaveJSON(fName : String; List : tFileInfoSet);
var srcfile : TextFile;
var Ordinateur : string;
//Dest : TStream;
//Encode : TEncodingStream;
//Comp :TCompressionStream;
// Buf : Array[1..SomeSize] of byte;
var Buf : AnsiString;
//zip : tzipper;
begin
	Ordinateur := GetComputerNetName;
	buf := List.GetJSON;
	assignfile(srcfile, Ordinateur+'_'+fName+'.json');
	rewrite(srcfile);
	Writeln(srcfile,'{ "computername" : "'+Ordinateur+'", '+
					' "start_at" : "'+ DateTime2XMLDateTime(Start) + '", ' +
					' "stop_at" : "'+ DateTime2XMLDateTime(Now) + '", ');
	Writeln(srcfile,Params.Unities.GetJSON+',  ');
	Writeln(srcfile,buf+'}');
	closefile(srcfile);

//	zip := tzipper.create;

//	Dest:=CreateDestStream;
//	Encode:=TEncodingStream.Create(Dest);
//	Comp:=TCompressionStream.Create(Encode);
//	Comp.Write(@Buf[1],Length(Buf));
end;	

Var K : Qword;
Var DateMe, UDate : TdateTime;
Var SDateMe : String;
var SystemTime: TSystemTime;

Begin
	Start := now;
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

	SaveJSON('sources',Params.SourceSet);
	SaveJSON('groupes',Params.GroupSet);
	SaveJSON('specific',Params.SpecificSet);

	Params.free;
	Tree.free;
End.
