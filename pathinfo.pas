Unit PathInfo;
Interface
uses DirectoryStat,
     filekind,
     SysUtils,
     InternalTypes;

type
	tPIState = (tpisNone, tpisConfigured, tpisFound, tpisFilled);

	TPathInfo = class
		private
			fPathName : WideString;
			fState : tPIState;
			fSumarize : TFileKind;
//			fGroupName : String;
			fDirStats : tDirectoryStat;
		public
			constructor Create(PathN : WideString);
			destructor Destroy; override;
			function AddSizeExtension(info : TSearchRec; LimIndex : Integer; TypeExt : String): UInt64;
			procedure dumpData();
			class function CompareNode(Item1 : TPathInfo; Item2 : TPathInfo) : Longint;			
			property PathName: WideString read FPathName write FPathName;
			property Sumarize: TFileKind read FSumarize write FSumarize;
			property State: tPIState read FState write FState;
//			property GroupName: String read FGroupName write FGroupName;
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
	fSumarize.free;
	fDirStats.free;
	inherited Destroy;	
end;

function TPathInfo.AddSizeExtension(Info : TSearchRec; LimIndex : Integer; TypeExt : String): UInt64;
begin
	Result := fDirStats.AddFileStat(Info,LimIndex,TypeExt);
end;

class function TPathInfo.CompareNode(Item1 : TPathInfo; Item2 : TPathInfo) : Longint;
begin
	Result := AnsiCompareText(Item1.PathName, Item1.PathName);
end;

procedure TPathInfo.dumpData();
var i : integer;
begin
	writeln('Path(' + PathName +
		    ') State(' +  GetEnumName(TypeInfo(tPIState), ord(State)) + 
		    ') Size(' + DirStats.Size.FromByteToHR +')');
	for i:= 0 to Pred(fDirStats.count) do
		writeln(fDirStats.TypeExtension[i],':',fDirStats.FileInfoFromIndex[i].GetData);
end;

end.