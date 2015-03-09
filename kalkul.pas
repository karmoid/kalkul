program kalcul;

{ This program demonstrates the FindFirst function }

Uses 
	Classes,
	PathTree,
	IniMangt,
	SysUtils,
	StrUtils,
	SpecificPath,
	pathinfo,
	Contnrs;

Var Tree : TPathTree;
	i,imax : Integer;
	Params : TAppParams;

Const cIniFile = 'kalkul.ini';

function ProcessTree(FileSpec : string; Depth: Integer): Cardinal;
Var Info : TSearchRec;
	Count : Longint = 0;
	PI : tPathInfo;
begin
if Depth>0 then
	begin
	//Writeln('Ajoute '+FileSpec);
	PI := Tree.AddPathInfo(FileSpec);
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
			    	Params.AddSizeExtension(ExtractFileExt(Name),Size,Params.SettingsKeepUDetails);
			    	PI.AddSizeExtension(ExtractFileExt(Name),Size,Params.SettingsKeepUDetails)
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
	with (Params.SpecificPaths.Objects[i] as TSpecificPath) do
		begin
			for j := 0 to Pred(Paths.Count) do
		 		Result.AddPathInfo(Paths.ValueFromIndex[j]).State := tpisConfigured;
		end; 	
end;

// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Main entry...
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Begin
	Params := TAppParams.create(cIniFile);

  	Tree := PopulateTree;

	imax := WordCount(Params.SettingsSrc,[',']);
	for i := 1 to imax do
	begin
		Write('Processing... ' + ExtractWord(i,Params.SettingsSrc,[','])+':\ -> ');
		Writeln(IntToStr(ProcessTree(ExtractWord(i,Params.SettingsSrc,[','])+':\',Params.SettingsDepth)) + ' files');
	end;
	Params.Extensions.DumpStats;

	Params.free;
	Tree.free;
End.
