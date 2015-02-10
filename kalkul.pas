program kalcul;

{ This program demonstrates the FindFirst function }

Uses 
	Classes,
	Filekind,
	PathTree,
	SysUtils,
	StrUtils,
	Contnrs,
	IniFiles;

Var Ext : TFileKind;
	Tree : TPathTree;
	IniF : TIniFile;
	i,imax : Integer;
	SettingsSrc : String;
	SettingsDepth :Integer;
	SettingsKeepUDetails : Boolean;

Type tSections = (tsExtensions,tsDrives,tsSettings);

Const cIniFile = 'kalkul.ini';
Const cSections : array [low(tSections)..high(tSections)] of String = (
		'extensions',
		'drives',
		'settings');

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

function ProcessTree(FileSpec : string; Depth: Integer): Integer;
Var Info : TSearchRec;
	Count : Longint = 0;
begin
if Depth>0 then
	begin
	//Writeln('Ajoute '+FileSpec);
	Tree.AddPathInfo(FileSpec);
	//Writeln('Enter '+FileSpec+' Depth:'+IntToStr(Depth));
	If FindFirst (FileSpec+'*',faAnyFile and faDirectory, Info)=0 then
	    begin
	    Repeat
	    	Inc(Count);
	    	With Info do
	    	begin
		    If (Attr and faDirectory) = faDirectory then
		        begin
			        if Name[1] <> '.' then Count := Count + ProcessTree(FileSpec+Name+'\',Depth-1);
		        end
		    else
			    begin
			    	Ext.AddSizeExtension(ExtractFileExt(Name),Size,SettingsKeepUDetails);
			        //Write (Name:40,Size:15);
			        //Writeln(Ext.TypeExtension[ExtractFileExt(Name)]:15);
		    	end;
			end;
	    Until FindNext(info)<>0;
	    end;
	FindClose(Info);
	//Writeln('Exit '+FileSpec);	
	end;
Result := Count;
end;

procedure InitializeIniFile();
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

procedure LoadExtensions();
var Sections : TStringList;
	Counter, SectionIndex : Integer;
	Values : TStringList;	

begin
	Sections := TStringList.create();

	IniF.ReadSectionValues(cSections[tsExtensions], Sections);
	for Counter := 0 to Pred(Sections.count) do
	begin
		Values := TStringList.create();
		Values.CommaText := Sections.ValueFromIndex[Counter];
  		for SectionIndex := 0 to Pred(Values.count) do
  		begin
  			Ext.AddExtension(Sections.Names[Counter],'.'+Values.ValueFromIndex[SectionIndex]);
  		end;
	end;
	Sections.free;
end;

procedure LoadSettings();
begin
	SettingsDepth := IniF.ReadInteger(cSections[tsSettings],'depth', 3);
	SettingsSrc := IniF.ReadString(cSections[tsSettings],'source', 'c');
	SettingsKeepUDetails := IniF.ReadBool(cSections[tsSettings],'KeepUnknownDetails', False);
end;

Begin
	IniF := TIniFile.create(cIniFile,False);
  	Ext := TFileKind.create;
  	Tree := TPathTree.create;
// pas nécessaire ou obligatoire (valeur par défaut)	
	InitializeIniFile;
	LoadExtensions;
	LoadSettings;

	IniF.free;

	imax := WordCount(SettingsSrc,[',']);
	for i := 1 to imax do
	begin
		Write('Processing... ' + ExtractWord(i,SettingsSrc,[','])+':\ -> ');
		Writeln(IntToStr(ProcessTree(ExtractWord(i,SettingsSrc,[','])+':\',SettingsDepth)) + ' files');
	end;
	Ext.DumpContents;

	Tree.AddItems('Tests');
	Tree.BrowseAll;
End.
