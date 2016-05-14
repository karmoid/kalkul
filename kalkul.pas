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
	DriveInfoSet,
	regexpr,
	Zipper;

Var Tree : TPathTree;
	i,imax : Integer;
	Params : TAppParams;
    Src : String;
    Start : TdateTime;
    DInfoSet : tDriveInfoSet;

Const cIniFile = 'kalkul.ini';

function ProcessTree(Src, RootSpec, NewPath : string; Depth: Integer; GroupName : String): Cardinal;
Var Info : TSearchRec;
	Count : Longint = 0;
	TypeExt : String;
	PI : tPathInfo;
	FileSpec,KeyFilespec,WGpName,WSpecific : String;
	LimIndex : Integer;
begin
FileSpec := RootSpec+NewPath+'\';
if Depth<=0 then
	KeyFileSpec := RootSpec+'<any>'+'\'
else
	KeyFilespec := FileSpec;

if (Depth>0) or (Params.SettingsDrillDown) then
	begin
	// Writeln('Ajoute '+FileSpec);
	WSpecific := Params.FindSpecificByPath(FileSpec);
	WGpName := Params.FindGroupByPath(FileSpec);
	// si on trouve un paramètre Path Spécifique
	// on force le chemin même si Depth dépassé
	// et on remet la profondeur égale au paramétrage
	if WSpecific<>'' then
	begin
		KeyFilespec := FileSpec;
		Depth := Params.SettingsDepth;
	end;
	PI := Tree.AddPathInfo(LowerCase(KeyFileSpec));
	if WGpName <> '' then
	  GroupName := WGpName;
	if PI.State = tpisConfigured then
	begin
		// PI.State := tpisFound;
		Depth := Params.SettingsDepth;
	end;
	if Params.IsPathExcluded(GroupName,PI.PathName) then
		PI.State := tpisExcluded
	else
	If (PI.State in [tpisNone, tpisConfigured]) and
	   (FindFirst (FileSpec+'*',faAnyFile and faDirectory, Info)=0) then
	    begin
		    Repeat
		    	Inc(Count);
		    	With Info do
		    	begin
			    If (Attr and faDirectory) = faDirectory then
			        begin
	//			        if Name[1] <> '.' then Count := Count + ProcessTree(Src,FileSpec+Name+'\',Depth-1,GroupName);
				        if Name[1] <> '.' then Count := Count + ProcessTree(Src,FileSpec,Name,Depth-1,GroupName);
			        end
			    else
				    begin
				    	// remplacer Ext par ExtractFileExt(Info.Name)
				    	// Params.AddSizeExtension(ExtractFileExt(Name),Info,Params.SettingsKeepUDetails,GroupName);
				    	// PI Gère un Item
				    	LimIndex := Params.GetLimitIndex(Info);
//				    	TypeExt := Params.GetExtensionType(lowerCase(ExtractFileExt(Info.Name)),GroupName);
						//writeln('cherche ',lowerCase(Info.Name),' groupe',GroupName);
				    	TypeExt := Params.GetExtensionType(lowerCase(Info.Name),GroupName);
				    	Params.SourceSet.AddSizeFromInfo(Info,LimIndex,TypeExt,Src); // gère x Items
				    	Params.GroupSet.AddSizeFromInfo(Info,LimIndex,TypeExt,GroupName); // gère x Items
				    	Params.SpecificSet.AddSizeFromInfo(Info,LimIndex,TypeExt,WSpecific); // gère x Items
				    	PI.AddSizeExtension(Info,LimIndex,TypeExt,Params.SettingsKeepUDetails,GroupName,WSpecific);
			    	end;
				end;
		    Until FindNext(info)<>0;
		FindClose(Info);
		PI.state := tpisFilled;
	    end;
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
var ts : string;
//zip : tzipper;
begin
	ts := getTimeStampString();
	Ordinateur := GetComputerNetName;
	buf := List.GetJSON;
	assignfile(srcfile, Ordinateur+'_'+fName+ts+'.json');
	rewrite(srcfile);
	Writeln(srcfile,'{ "computername" : "'+Ordinateur+'", '+
					'"start_at" : "'+ DateTime2XMLDateTime(Start) + '", ' +
					'"stop_at" : "'+ DateTime2XMLDateTime(Now) + '", ');
	Writeln(srcfile,Params.SettingsGetJSON+',  ');
	Writeln(srcfile,Params.Unities.GetJSON+',  ');
	Writeln(srcfile,DInfoSet.GetJSON+',  ');
	Writeln(srcfile,buf+'}');
	closefile(srcfile);

//	zip := tzipper.create;

//	Dest:=CreateDestStream;
//	Encode:=TEncodingStream.Create(Dest);
//	Comp:=TCompressionStream.Create(Encode);
//	Comp.Write(@Buf[1],Length(Buf));
end;

procedure SavePathJSON(fName : String);
var srcfile : TextFile;
var Ordinateur : string;
var ts : string;
//Dest : TStream;
//Encode : TEncodingStream;
//Comp :TCompressionStream;
// Buf : Array[1..SomeSize] of byte;
//zip : tzipper;
begin
	ts := getTimeStampString();
	Ordinateur := GetComputerNetName;
	assignfile(srcfile, Ordinateur+'_'+fName+ts+'.json');
	rewrite(srcfile);
	Writeln(srcfile,'{ "computername" : "'+Ordinateur+'", '+
					'"start_at" : "'+ DateTime2XMLDateTime(Start) + '", ' +
					'"stop_at" : "'+ DateTime2XMLDateTime(Now) + '", ');
	Writeln(srcfile,Params.SettingsGetJSON+',  ');
	Writeln(srcfile,Params.Unities.GetJSON+',  ');
	Writeln(srcfile,Tree.UnknownGetJSON+'}');
	closefile(srcfile);

//	zip := tzipper.create;

//	Dest:=CreateDestStream;
//	Encode:=TEncodingStream.Create(Dest);
//	Comp:=TCompressionStream.Create(Encode);
//	Comp.Write(@Buf[1],Length(Buf));
end;


Var K : Qword;
Var DateMe, UDate : TdateTime;
Var MissedPaths : String;
var SystemTime: TSystemTime;
var free_size, total_size: Int64;

Begin
	Start := now;
	Params := TAppParams.create(cIniFile);
  	Regex := TRegExpr.Create;
  	DInfoSet := tDriveInfoSet.create;

	//Params.DumpPaths;
  	Tree := PopulateTree;
	imax := WordCount(Params.SettingsSrc,[',']);
	for i := 1 to imax do
	begin
		Src := ExtractWord(i,Params.SettingsSrc,[',']);
		Write('Processing... ' + Src + ':\ -> ');
		if GetDiskSize(Src[1], free_size, total_size) then
			DInfoSet.AddSizeFromSize(total_size, free_size, Src);
		Writeln(IntToStr(ProcessTree(Src,ExtractWord(i,Params.SettingsSrc,[','])+':','',Params.SettingsDepth,'')) + ' files');
	end;

	MissedPaths := Tree.GetMissedPaths;
	if MissedPaths<>'' then
	begin
		// Writeln('Missed Path:'+MissedPaths);
		Writeln('Processing missed paths... -> ');
		imax := WordCount(MissedPaths,['|']);
		for i := 1 to imax do
		begin
			Src := ExtractWord(i,MissedPaths,['|']);
			Write(Src[1] + ':\ -> ['+ Src +']');
			Writeln(IntToStr(ProcessTree(Src[1],Copy(Src,1,Pred(length(Src))),'',Params.SettingsDepth,'')) + ' files');
		end;
	end;

	SaveJSON('sources',Params.SourceSet);
	SaveJSON('groupes',Params.GroupSet);
	SaveJSON('specific',Params.SpecificSet);

//	if Params.SettingsKeepUDetails then
	SavePathJSON('paths');

	Params.free;
	DInfoSet.free;
	Regex.free;
	Tree.free;
End.
