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
		fSpecificPaths : TStringList;
		procedure InitializeIniFile();
		procedure LoadExtensions();
		procedure LoadUnities();
		procedure LoadSettings();
		procedure LoadSpecificPath();

	public
		constructor Create(fName : String);
		destructor Destroy; override;
		property Unities: tUnityList read fUnity;
		property SettingsSrc: WideString read FSettingsSrc write FSettingsSrc;
		property SettingsDepth: Integer read FSettingsDepth write FSettingsDepth;
		property SettingsKeepUDetails: Boolean read FSettingsKeepUDetails write FSettingsKeepUDetails;
		property Extensions: TFileKind read FExtensions;
		property SpecificPaths: TStringList read FSpecificPaths;
		function AddSizeExtension(key : string; size : Cardinal; WithDetails: Boolean): UInt64;
	end;	

implementation
uses StrUtils,
	 ExtensionTypes;

Type tSections = (tsExtensions,tsDrives,tsSettings,tsSizes,tsSpecificPath);
Const cComment = ';';
Const cSections : array [low(tSections)..high(tSections)] of String = (
		'extensions',
		'drives',
		'settings',
		'sizedetails',
		'specificpath');

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
	fSpecificPaths := TStringList.create;
	fSpecificPaths.OwnsObjects := True;
// pas nécessaire ou obligatoire (valeur par défaut)	
	InitializeIniFile;
	LoadExtensions;
	LoadSettings;
	LoadUnities;
	LoadSpecificPath;  	
	end;

destructor TAppParams.Destroy;
	begin
	// writeln(funity.DelimitedText);
	fUnity.free;
	writeln(fSpecificPaths.DelimitedText);
	fSpecificPaths.free;
	fExtensions.free;
	IniF.free;
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
		Extensions.AddTypeExtension('Unknown');
		Extensions.AddExtension('Unknown','.*');
		for Counter := 0 to Pred(Sections.count) do
		begin
			Values := TStringList.create();
			Values.CommaText := Sections.ValueFromIndex[Counter];
			Extensions.AddTypeExtension(Sections.Names[Counter]);
	  		for SectionIndex := 0 to Pred(Values.count) do
	  		begin
	  			Extensions.AddExtension(Sections.Names[Counter],'.'+Values.ValueFromIndex[SectionIndex]);
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
	begin
        if Sections.Names[Counter][1]<>cComment then
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
	Counter : Integer;

begin
	Sections := TStringList.create();

	IniF.ReadSectionValues(cSections[tsSpecificPath], Sections);
	for Counter := 0 to Pred(Sections.count) do
	begin
		fSpecificPaths.AddObject(Sections.Names[Counter],TSpecificPath.Create(Sections.Names[Counter],Sections.ValueFromIndex[Counter]));
	end;
	Sections.free;
end;

function TAppParams.AddSizeExtension(key : string; size : Cardinal; WithDetails: Boolean): UInt64;
begin
	Result := Extensions.AddSizeExtension(key,size,WithDetails);
end;


end.
