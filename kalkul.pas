program kalcul;
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  Marc CHAUFFOUR - may 2016
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
	ListFile : TextFile;
	Ident : Integer;
	OurZipper :TZipper;

Const cIniFile = 'kalkul.ini';

procedure PrepareListFile(Active : Boolean);
var Ordinateur : string;
var ts : string;
begin
	if Active then
	begin
		ts := getTimeStampString();
		Ordinateur := GetComputerNetName;
		assignfile(ListFile, Ordinateur+'_'+ts+'.csv');
		rewrite(ListFile);
		writeln(ListFile,'ident;path;conteneur;filename;taille;created;accessed;modified;end');
	end;
end;

procedure TerminateListFile(Active : Boolean);
begin
	if Active then closefile(ListFile);
end;

procedure DumpInfoListFile(Info : TSearchRec; Pi : tPathInfo; CurrentPath : String);
begin
	if Params.IsFileToTrace(Info) then
	begin
		Ident := Ident + 1;
		with Info do
		begin
			writeln(ListFile,Ident,';',pi.PathName,';',CurrentPath,';',Name,';',
							Size,';',DateTime2XMLDateTimeNoTZ(FileTimeToDTime(FindData.ftCreationTime)),';',
							DateTime2XMLDateTimeNoTZ(FileTimeToDTime(FindData.ftLastAccessTime)),';',
							DateTime2XMLDateTimeNoTZ(FileTimeToDTime(FindData.ftLastWriteTime)),';*');
		end;
	end;
end;

procedure PrepareZipFile(Active : Boolean);
var Ordinateur : string;
var ts : string;
begin
	if Active then
	begin
		ts := getTimeStampString();
		Ordinateur := GetComputerNetName;
		OurZipper := TZipper.Create;
	  OurZipper.FileName := IncludeTrailingPathDelimiter(Params.SettingsCopyTarget)+Ordinateur+'_'+ts+'.zip';
	end;
end;

procedure TerminateZipFile(Active : Boolean);
	begin
		if Active then
    begin
			writeln('writing ',OurZipper.Entries.count,' file(s) to ',OurZipper.FileName);
			OurZipper.ZipAllFiles;
			OurZipper.Free;
    end;
	end;

procedure CopyTreeDirFile(Info : TSearchRec; Pi : tPathInfo; CurrentPath : String);
var ADiskFileName : string;
var AArchiveFileName :String;
begin
	if Params.IsFileToCopy(Info) then
	begin
		with Info do
		begin
			  ADiskFileName:=pi.PathName+Name;
			  AArchiveFileName:=StringReplace(pi.PathName+Name,extractfiledrive(pi.PathName)+'\','',[rfReplaceall]);
			  // AArchiveFileName:=SysToUTF8(AArchiveFileName);
			  // AArchiveFileName:=UTF8ToCP866(AArchiveFileName);
				// writeln('zip ',ADiskFileName,' to ',AArchiveFileName);
			  OurZipper.Entries.AddFileEntry(ADiskFileName,AArchiveFileName);
		end;
	end;
end;

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
	// writeln('on traite le path '+PI.PathName);
	if Params.IsPathExcluded(GroupName,PI.PathName) then
  begin
		PI.State := tpisExcluded;
		// writeln(PI.PathName,' Excluded');
	end;
	If (PI.State in [tpisNone, tpisConfigured,tpisExcluded]) and
		 ((PI.State <> tpisExcluded) or (not Params.SettingsExclFullDir)) and
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
			    else if pi.state<>tpisExcluded then
				    begin
							DumpInfoListFile(Info,PI,NewPath);
							CopyTreeDirFile(Info,PI,NewPath);
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
				if PI.state <> tpisExcluded then
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
  writeln(Params.SettingsGetJSON);
	PrepareListFile(Params.SettingsListFile<>'');
	PrepareZipFile(Params.SettingsCopyTreeDir<>'');

	//Params.DumpPaths;
	Tree := PopulateTree;
	imax := WordCount(Params.SettingsSrc,[',']);
	for i := 1 to imax do
	begin
		Src := ExtractWord(i,Params.SettingsSrc,[',']);
		WriteLn('Processing... ' + Src + ':\ -> ');
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

	TerminateListFile(Params.SettingsListFile<>'');
	TerminateZipFile(Params.SettingsCopyTreeDir<>'');

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
