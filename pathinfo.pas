Unit PathInfo;
Interface
uses DirectoryStat,
     SysUtils,
     InternalTypes;

type
	tPIState = (tpisNone, tpisConfigured, tpisFound, tpisFilled);

	TPathInfo = class
		private
			fPathName : WideString;
			fState : tPIState;
			fGroupName : String;
			fSpecificName : String;
			fDirStats : tDirectoryStat;
		public
			constructor Create(PathN : WideString);
			destructor Destroy; override;
			function AddSizeExtension(info : TSearchRec; LimIndex : Integer; TypeExt : String; KeepUnknown: boolean; GpName, SpName : string): UInt64;
			function dumpData() : AnsiString;
			function dumpJSON() : AnsiString;
			class function CompareNode(Item1 : TPathInfo; Item2 : TPathInfo) : Longint;			
			property PathName: WideString read FPathName write FPathName;
			property State: tPIState read FState write FState;
			property GroupName: String read FGroupName write FGroupName;
			property SpecificName: String read FSpecificName write FSpecificName;
			property DirStats: tDirectoryStat read FDirStats;
	end;

Implementation
uses typinfo;

constructor TPathInfo.Create(PathN : WideString);
begin
	fPathName := NormalizePath(PathN);
	fDirStats := tDirectoryStat.Create();
end;

destructor TPathInfo.Destroy; 
begin
	fPathName := '';
	fDirStats.free;
	inherited Destroy;	
end;

function TPathInfo.AddSizeExtension(Info : TSearchRec; LimIndex : Integer; TypeExt : String; KeepUnknown: boolean; GpName, SpName : string): UInt64;
var Ext : string;
begin
	if (TypeExt='') and KeepUnknown then
	begin
		Ext := Copy(lowerCase(ExtractFileExt(Info.Name)),1,5);
		if Length(ExtractFileExt(Info.Name))>5 then
			Ext[5] := '*';
		TypeExt := '!na'+Ext;
		LimIndex := 0;
		GroupName := GpName;
		SpecificName := SpName;
		Result := fDirStats.AddFileStat(Info,LimIndex,TypeExt);
	end;
end;

class function TPathInfo.CompareNode(Item1 : TPathInfo; Item2 : TPathInfo) : Longint;
begin
	Result := AnsiCompareText(Item1.PathName, Item1.PathName);
end;

function TPathInfo.dumpData() : AnsiString;
var i : integer;
begin
	Result := 'Path(' + PathName +
		    ') State(' +  GetEnumName(TypeInfo(tPIState), ord(State)) + 
		    ') Size(' + DirStats.Size.FromByteToHR +
		    ') Specific(' + SpecificName +
		    ') GroupName(' + GroupName +')';
	for i:= 0 to Pred(fDirStats.count) do
		Result := Result + '\n' + fDirStats.TypeExtension[i]+':'+fDirStats.FileInfoFromIndex[i].GetData;
end;

function TPathInfo.dumpJSON() : AnsiString;
var i : integer;
begin
	Result := '{ "Name" : "'+StringReplace(PathName,'\','\\',[rfReplaceAll])+'", '+
              '"Group" : "'+GroupName+'", '+
              '"Specific" : "'+SpecificName+'", '+
              fDirStats.GetJSON() + 
              '}';
end;

end.