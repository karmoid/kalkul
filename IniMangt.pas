// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//
// Ini management : Chargement des options de fichiers .INI
// Permet d'exploiter les paramétres en fichier de configuration
// et (a faire...) en overide ligne de commande
//
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
unit IniMangt;
interface
uses Classes,
	InternalTypes,
	Unities,
	ExtensionTypeManager,
	PathsAndGroupsManager,
	SpecificPaths,
	Specificpath,
	FileInfoSet,
	SysUtils,
	IniFiles;

type

	TAppParams = class
	private
		IniF : TIniFile;
		fUnity : TUnityList;
		fSettingsSrc : WideString;
		fSettingsDepth :Integer;
		fSettingsKeepUDetails : Boolean;
		fSettingsDrillDown : Boolean;
		//fSpecificPaths : TStringList;
		fExtensionTypeManager : TExtensionTypeManager;
		fPathAndGroupManager : TPathsAndGroupsManager;
		fReportExtType : TStringList;
		fSourceSet : tFileInfoSet;
		fGroupSet : tFileInfoSet;
		fSpecificSet : tFileInfoSet;
		procedure InitializeIniFile();
		procedure LoadExtensions();
		procedure LoadUnities();
		procedure LoadSettings();
		procedure LoadSpecificPath();
		procedure LoadSpecificGroup();
		procedure LoadGroupOptions(GroupName : String);
		function GetSpecificPaths : TSpecificPaths;
		property ExtensionTypeManager: TExtensionTypeManager read FExtensionTypeManager write FExtensionTypeManager;
		property PathAndGroupManager: TPathsAndGroupsManager read FPathAndGroupManager write FPathAndGroupManager;
		function GetExceptIncludeRegExp(GName : string) : TExtensionTypeManager;

	public
		constructor Create(fName : String);
		destructor Destroy; override;
		procedure DumpExtensions;
		procedure DumpPaths;
		procedure DumpExtType();
		function AddSizeExtension(key : string; info : TSearchRec; WithDetails: Boolean; GName : String): UInt64;
		function FindGroupByPath(S : String) : string;
		function FindSpecificByPath(S : String) : string;
		function GetExtensionType(fname : String; GName : string) : string;
		function GetLimitIndex(info : TSearchRec) : Integer;
		function SettingsGetJSON : AnsiString;
		function IsPathExcluded(Gname : string; Path : String) : boolean;
		property Unities: tUnityList read fUnity;
		property SettingsSrc: WideString read FSettingsSrc write FSettingsSrc;
		property SettingsDepth: Integer read FSettingsDepth write FSettingsDepth;
		property SettingsKeepUDetails: Boolean read FSettingsKeepUDetails write FSettingsKeepUDetails;
		property SettingsDrillDown: Boolean read fSettingsDrillDown write fSettingsDrillDown;
		property SpecificPaths: TSpecificPaths read GetSpecificPaths;
		property SourceSet : tFileInfoSet read fSourceSet;
		property GroupSet : tFileInfoSet read fGroupSet;
		property SpecificSet : tFileInfoSet read fSpecificSet;
		property ExcludeIncludeRegExp [GName : String] : TExtensionTypeManager read GetExceptIncludeRegExp;

	end;

implementation
uses StrUtils,
	 ExtensionTypes,
	 DirectoryStat;

Type tSections = (tsExtensions,tsDrives,tsSettings,tsSizes,tsSpecificPath,tsSpecificGroup,tsGroupOptions);
Const cComment = ';';
Const cExclude = '-';
Const cInclude = '+';
Const cSections : array [low(tSections)..high(tSections)] of String = (
		'extensions',
		'drives',
		'settings',
		'sizedetails',
		'specificpath',
		'specificgroup',
		'group');

Const cDefaultExt : array [0..12] of String = (
		'Unknown/xxx',
		'Video/mp4,mov',
		'Image/jpg,jpeg',
		'Pascal/pas',
		'Executable/exe,com',
		'Library/dll',
		'Objet/obj,o',
		'Pdf/pdf',
		'Office Excel/xls,xlsx',
		'Office Word/doc,docx',
		'OpenOffice Calc/ods',
		'OpenOffice Write/odt',
		'Setup/cab,msi'
	);

constructor TAppParams.Create(fName : String);
	begin
	fUnity := TUnityList.Create();
	IniF := TIniFile.create(fName,False);
	//fSpecificPaths := TStringList.create;
	//fSpecificPaths.OwnsObjects := True;
	fExtensionTypeManager := TExtensionTypeManager.Create();
	fPathAndGroupManager := TPathsAndGroupsManager.create();
	fReportExtType := TStringList.create();
	fReportExtType.Duplicates := dupError;
	fReportExtType.OwnsObjects := True;
	fReportExtType.Sorted := True;
	fSourceSet := tFileInfoSet.create;
	fGroupSet := tFileInfoSet.create;
	fSpecificSet := tFileInfoSet.create;

// pas nécessaire ou obligatoire (valeur par défaut)
	InitializeIniFile;
	LoadExtensions;
	LoadSettings;
	LoadUnities;
	LoadSpecificPath;
	LoadSpecificGroup;
	end;

destructor TAppParams.Destroy;
	begin
	// writeln(funity.DelimitedText);
	fUnity.free;
	//writeln(fSpecificPaths.DelimitedText);
	//fSpecificPaths.free;
	IniF.free;
	fExtensionTypeManager.free;
	fPathAndGroupManager.free;
	fReportExtType.free;
	fGroupSet.free;
	fSourceSet.free;
	fSpecificSet.free;
	inherited Destroy;
	end;

procedure TAppParams.InitializeIniFile();
var Counter : Integer;

begin
	If not IniF.SectionExists(cSections[tsExtensions]) then
	begin
		for Counter := low(cDefaultExt) to high(cDefaultExt) do
		begin
			IniF.WriteString(cSections[tsExtensions],
							 ExtractDelimited(1,cDefaultExt[Counter],['/']),
							 ExtractDelimited(2,cDefaultExt[Counter],['/']));
		end;
	end;
end;

procedure TAppParams.LoadExtensions();
var Sections : TStringList;
	Counter, SectionIndex : Integer;
	Values : TStringList;
	ExtValue : string;

begin
	try
		Sections := TStringList.create();

		IniF.ReadSectionValues(cSections[tsExtensions], Sections);
		ExtensionTypeManager.AddExtensionType('Unknown');
		ExtensionTypeManager.AddExtension('.*','Unknown');

		for Counter := 0 to Pred(Sections.count) do
        if Sections.Names[Counter][1]<>cComment then
		begin
			ExtValue := Sections.ValueFromIndex[Counter];
			if RegularExpression(ExtValue) then

			else

			begin
				Values := TStringList.create();
				Values.CommaText := Sections.ValueFromIndex[Counter];
				ExtensionTypeManager.AddExtensionType(Sections.Names[Counter]);
		  		for SectionIndex := 0 to Pred(Values.count) do
		  		begin
		  			ExtensionTypeManager.AddExtension('.'+Values.ValueFromIndex[SectionIndex],Sections.Names[Counter]);
		  		end;
			end;
		end;
		Sections.free;
	except
		on e: EExtensionTypesNotUnique do
		begin
			writeln('ExtensionType en double ! Msg->' + e.message);
			raise;
		end;
	end;
end;

procedure TAppParams.LoadUnities();
var Sections : TStringList;
	Counter : Integer;

begin
	Sections := TStringList.create();

	IniF.ReadSectionValues(cSections[tsSizes], Sections);
	for Counter := 0 to Pred(Sections.count) do
    if Sections.Names[Counter][1]<>cComment then
	begin
		fUnity.AddUnity(Sections.Names[Counter],Sections.ValueFromIndex[Counter]);
	end;
	Sections.free;
	SizeLimit := fUnity.Count;
end;

procedure TAppParams.LoadSettings();
begin
	SettingsDepth := IniF.ReadInteger(cSections[tsSettings],'depth', 3);
	SettingsSrc := IniF.ReadString(cSections[tsSettings],'source', 'c');
	SettingsKeepUDetails := IniF.ReadBool(cSections[tsSettings],'KeepUnknownDetails', False);
	SettingsDrillDown := IniF.ReadBool(cSections[tsSettings],'drilldown', False);
end;

procedure TAppParams.LoadSpecificPath();
var Sections : TStringList;
	Counter,J : Integer;
	wPaths : TStringList;

begin
	Sections := TStringList.create();

	IniF.ReadSectionValues(cSections[tsSpecificPath], Sections);
	for Counter := 0 to Pred(Sections.count) do
    if Sections.Names[Counter][1]<>cComment then
	begin
		//fSpecificPaths.AddObject(Sections.Names[Counter],TSpecificPath.Create(Sections.Names[Counter],Sections.ValueFromIndex[Counter]));
		PathAndGroupManager.AddSpecificPathName(Sections.Names[Counter]);
		wPaths := TStringList.create();
		try
			wPaths.Delimiter := ',';
			wPaths.StrictDelimiter := True;
			wPaths.Delimitedtext := Sections.ValueFromIndex[Counter];
			// Important : Needed for Space in paths
			for J := 0 to Pred(wPaths.count) do
				PathAndGroupManager.AddPath(wPaths[J],Sections.Names[Counter]);
		finally
			wPaths.free;
		end;
	end;
	Sections.free;
end;

procedure TAppParams.LoadGroupOptions(GroupName : String);
var Sections : TStringList;
	Counter,SectionIndex : Integer;
	wPaths : TStringList;
	ExtensionTypeMan : TExtensionTypeManager;
	Values : TStringList;
	ExtValue : String;

begin
	Sections := TStringList.create();
	ExtensionTypeMan := PathAndGroupManager.Groups.ExtensionTypeMan(GroupName);

	IniF.ReadSectionValues(GroupName+cSections[tsGroupOptions], Sections);
	for Counter := 0 to Pred(Sections.count) do
    if Sections.Names[Counter][1]<>cComment then
		begin
			ExtValue := Sections.ValueFromIndex[Counter];
			// writeln('Group Option : ',ExtValue, ' Except, Include, ExtensionGroup Regular or not');
			if Sections.Names[Counter][1] in [cInclude,cExclude] then
			begin
				// Group Options : Except, Include
				if RegularExpression(ExtValue) then
						ExtensionTypeMan.AddIncExclPathRegExp(Sections.Names[Counter],ExtValue)
				else
					writeln('GroupOption:',GroupName,'/',Sections.Names[Counter],' - Value not RegExp [',ExtValue,']');
			end
			else
				if RegularExpression(ExtValue) then
				begin
					ExtensionTypeMan.AddExtensionType(Sections.Names[Counter]);
					ExtensionTypeMan.AddExtension(ExtValue,Sections.Names[Counter]);
			  end
  			else
				begin
					Values := TStringList.create();
					Values.CommaText := Sections.ValueFromIndex[Counter];
					ExtensionTypeMan.AddExtensionType(Sections.Names[Counter]);
				  	for SectionIndex := 0 to Pred(Values.count) do
				  		ExtensionTypeMan.AddExtension('.'+Values.ValueFromIndex[SectionIndex],Sections.Names[Counter]);
				end;
		end;
	Sections.free;
end;

procedure TAppParams.LoadSpecificGroup();
var Sections : TStringList;
	Counter,J : Integer;
	wPaths : TStringList;

begin
	Sections := TStringList.create();

	IniF.ReadSectionValues(cSections[tsSpecificGroup], Sections);
	for Counter := 0 to Pred(Sections.count) do
    if Sections.Names[Counter][1]<>cComment then
	begin
		PathAndGroupManager.AddSpecificGroup(Sections.Names[Counter]);
		wPaths := TStringList.create();
		try
			wPaths.Delimiter := ',';
			wPaths.StrictDelimiter := True;
			wPaths.Delimitedtext := Sections.ValueFromIndex[Counter];
			// Important : Needed for Space in paths
			for J := 0 to Pred(wPaths.count) do
				PathAndGroupManager.AddPathName(wPaths[J],Sections.Names[Counter]);
			LoadGroupOptions(Sections.Names[Counter]);
		finally
			wPaths.free;
		end;
	end;
	Sections.free;
end;


function TAppParams.AddSizeExtension(key : string; info : TSearchRec; WithDetails: Boolean; GName : String): UInt64;
var ExtType : String;
var Obj : TDirectoryStat;
var i : integer;
begin
	Result := 0; // Extensions.AddSizeExtension(key,size,WithDetails);
//	ExtType := PathAndGroupManager.GetExtensionType(Key,GName);
	ExtType := PathAndGroupManager.GetExtensionType(info.name,GName);
	if ExtType='' then
		ExtType := ExtensionTypeManager.GetExtensionType(info.name);
	if ExtType='' then
		ExtType := '*any*';
	i := fReportExtType.indexOf(ExtType);
	if i=-1 then
	begin
		obj := TDirectoryStat.Create;
		fReportExtType.AddObject(ExtType,obj);
	end
	else
		obj := fReportExtType.Objects[i] as TDirectoryStat;
	Result := obj.Size.Add(info.Size);
end;

function TAppParams.FindGroupByPath(S : String) : string;
begin
	Result := PathAndGroupManager.FindGroupByPath(S);
end;

function TAppParams.FindSpecificByPath(S : String) : string;
begin
	Result := PathAndGroupManager.FindSpecificByPath(S);
end;

procedure TAppParams.DumpExtensions();
begin
	ExtensionTypeManager.DumpExtensions();
end;

procedure TAppParams.DumpPaths();
begin
	PathAndGroupManager.DumpPathsAndGroups();
end;

procedure TAppParams.DumpExtType();
var i : integer;
begin
	writeln('Type extension':25,' = ','Taille':25);
	for i:= 0 to pred(fReportExtType.count) do
	with fReportExtType.Objects[i] as TDirectoryStat do
		writeln(fReportExtType[i]:25,' = ',Size.FromByteToHR:25);
end;

function TAppParams.GetSpecificPaths : TSpecificPaths;
begin
	Result := PathAndGroupManager.Paths;
end;

function TAppParams.GetExtensionType(fName : String; GName : string) : string;
begin
	Result := PathAndGroupManager.GetExtensionType(Fname,GName);
	if Result = '' then
		Result := ExtensionTypeManager.GetExtensionType(Fname);
end;

function TAppParams.GetExceptIncludeRegExp(GName : string) : TExtensionTypeManager;
begin
	Result := PathAndGroupManager.GetExceptIncludeRegExp(GName);
end;

function TAppParams.GetLimitIndex(info : TSearchRec) : Integer;
var i : integer;
begin
	for i:= 0 to pred(fUnity.count) do
		if info.size <= funity.Values[i] then break;
	Result := i;
end;

function TAppParams.IsPathExcluded(Gname : string; Path : String) : boolean;
begin
	Result := false;
	if GName<>'' then
		begin
		// writeln('On teste pour le groupe '+Gname+' si le Path '+Path+' est exclu ou inclus ?');
		if Assigned(ExcludeIncludeRegExp[GName]) then
			Result := ExcludeIncludeRegExp[GName].IsPathExcluded(Gname,Path);
	end;
end;

function TAppParams.SettingsGetJSON : AnsiString;
begin
	Result := '"DrillDown": "'+cTrueFalse[SettingsDrillDown]+'", '+
			  '"KeepUnknownDetails": "'+cTrueFalse[SettingsKeepUDetails]+'", '+
			  '"Depth": "'+IntToStr(SettingsDepth)+'", '+
			  '"Sources": "'+SettingsSrc+'"';
end;

end.
