unit FileInfoSet;

interface
uses Classes,
	sysUtils,
  	InternalTypes;

type
	tFileInfoSet = class(tStringList)
	private	

	public
		constructor Create();
		function AddSizeFromInfo(Info : TSearchRec; TypeExt, Key : String) : UInt64; 
		procedure dumpData();
	end;

implementation
uses DirectoryStat;

constructor tFileInfoSet.Create();
begin
	// Sorted := true;
	Duplicates := dupError;
	OwnsObjects := False;
end;

function tFileInfoSet.AddSizeFromInfo(Info : TSearchRec; TypeExt, Key : String) : UInt64;
var i : Integer;
var DirStat : tDirectoryStat;
begin
	if key='' then
		key := '_n/a_';	
	i := indexOf(Key);
	if i = -1 then
	begin
		DirStat := tDirectoryStat.Create;
		i := AddObject(Key,DirStat);
		//writeln('added [',i,'] key=',Key);
	end;
	DirStat := Objects[i] as tDirectoryStat;
	Result := DirStat.AddFileStat(info,TypeExt);
end;

procedure tFileInfoSet.dumpData();
var i : integer;
var DirStat : tDirectoryStat;
begin
	writeln('=-=-=-=-=-=-=-=-=-=');
	for i:= 0 to pred(Count) do
	begin
		DirStat := Objects[i] as tDirectoryStat;
		writeln('[',i,']', Strings[i],':>');
		DirStat.dumpData;
	end;
	writeln;	
end;

end.