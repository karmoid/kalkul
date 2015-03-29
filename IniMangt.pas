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
	Filekind,
	ExtensionTypeManager,
	PathsAndGroupsManager,
	SpecificPaths,	
	specificpath,
	IniFiles;

type

	TAppParams = class
	private
		IniF : TIniFile;
		fExtensions : TFileKind;
		fUnity : TUnityList;
		fSettingsSrc : WideString;
		fSettingsDepth :Integer;
		fSettingsKeepUDetails : Boolean;
		//fSpecificPaths : TStringList;
		fExtensionTypeManager : TExtensionTypeManager;
		fPathAndGroupManager : TPathsAndGroupsManager;
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

	public
		constructor Create(fName : String);
		destructor Destroy; override;
		procedure DumpExtensions;
		procedure DumpPaths;
		function AddSizeExtension(key : string; size : Cardinal; WithDetails: Boolean; GName : String): UInt64;
		function FindGroupByPath(S : String) : string;
		property Unities: tUnityList read fUnity;
		property SettingsSrc: WideString read FSettingsSrc write FSettingsSrc;
		property SettingsDepth: Integer read FSettingsDepth write FSettingsDepth;
		property SettingsKeepUDetails: Boolean read FSettingsKeepUDetails write FSettingsKeepUDetails;
		property Extensions: TFileKind read FExtensions;
		property SpecificPaths: TSpecificPaths read GetSpecificPaths;
	end;	

implementation
uses StrUtils,
	 ExtensionTypes;

Type tSections = (tsExtensions,tsDrives,tsSettings,tsSizes,tsSpecificPath,tsSpecificGroup,tsGroupOptions);
Const cComment = ';';
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
	fExtensions := TFileKind.create;
	//fSpecificPaths := TStringList.create;
	//fSpecificPaths.OwnsObjects := True;
	fExtensionTypeManager := TExtensionTypeManager.Create();
	fPathAndGroupManager := TPathsAndGroupsManager.create();

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
	fExtensions.free;
	IniF.free;
	fExtensionTypeManager.free;
	fPathAndGroupManager.free;
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

begin
	try 
		Sections := TStringList.create();

		IniF.ReadSectionValues(cSections[tsExtensions], Sections);
		ExtensionTypeManager.AddExtensionType('Unknown');
		ExtensionTypeManager.AddExtension('.*','Unknown');

		for Counter := 0 to Pred(Sections.count) do
        if Sections.Names[Counter][1]<>cComment then
		begin
			Values := TStringList.create();
			Values.CommaText := Sections.ValueFromIndex[Counter];
			ExtensionTypeManager.AddExtensionType(Sections.Names[Counter]);
	  		for SectionIndex := 0 to Pred(Values.count) do
	  		begin
	  			ExtensionTypeManager.AddExtension('.'+Values.ValueFromIndex[SectionIndex],Sections.Names[Counter]);
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
		fUnity.AddUnity(Sections.ValueFromIndex[Counter]);
	end;
	Sections.free;
end;

procedure TAppParams.LoadSettings();
begin
	SettingsDepth := IniF.ReadInteger(cSections[tsSettings],'depth', 3);
	SettingsSrc := IniF.ReadString(cSections[tsSettings],'source', 'c');
	SettingsKeepUDetails := True; //IniF.ReadBool(cSections[tsSettings],'KeepUnknownDetails', False);
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

begin
	Sections := TStringList.create();
	ExtensionTypeMan := PathAndGroupManager.Groups.ExtensionTypeMan(GroupName);

	IniF.ReadSectionValues(GroupName+cSections[tsGroupOptions], Sections);
	for Counter := 0 to Pred(Sections.count) do
    if Sections.Names[Counter][1]<>cComment then
	begin
		Values := TStringList.create();
		Values.CommaText := Sections.ValueFromIndex[Counter];
		ExtensionTypeMan.AddExtensionType(Sections.Names[Counter]);
	  	for SectionIndex := 0 to Pred(Values.count) do
	  		ExtensionTypeMan.AddExtension('.'+Values.ValueFromIndex[SectionIndex],Sections.Names[Counter]);
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


function TAppParams.AddSizeExtension(key : string; size : Cardinal; WithDetails: Boolean; GName : String): UInt64;
begin
	Result := 0; // Extensions.AddSizeExtension(key,size,WithDetails);
	PathAndGroupManager.

end;

function TAppParams.FindGroupByPath(S : String) : string;
begin
	Result := PathAndGroupManager.FindGroupByPath(S);
end;

procedure TAppParams.DumpExtensions();
begin
	ExtensionTypeManager.DumpExtensions();	
end;

procedure TAppParams.DumpPaths();
begin
	PathAndGroupManager.DumpPathsAndGroups();	
end;

function TAppParams.GetSpecificPaths : TSpecificPaths;
begin
	Result := PathAndGroupManager.Paths;
end;


end.
