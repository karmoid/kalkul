unit DriveInfoSet;

interface
uses Classes,
	sysUtils,
  	InternalTypes;

type
	tDriveInfoSet = class(tStringList)
	private	

	public
		constructor Create();
		function AddSizeFromSize(TotalSize, FreeSize : uInt64; Key : String) : Boolean; 
		function GetJSON() : AnsiString;
		procedure dumpData();
	end;

implementation
uses DriveStat;

constructor tDriveInfoSet.Create();
begin
	// Sorted := true;
	Duplicates := dupError;
	OwnsObjects := True;
end;

function tDriveInfoSet.AddSizeFromSize(TotalSize, FreeSize : uInt64; Key : String) : Boolean;
var i : Integer;
var DStat : tDriveStat;
begin
	if key='' then
		key := '_n/a_';	
	i := indexOf(Key);
	if i = -1 then
	begin
		DStat := tDriveStat.Create;
		DStat.TotalS := TotalSize;
		DStat.FreeS := FreeSize;
		i := AddObject(Key,DStat);
		//writeln('added [',i,'] key=',Key);
		Result := False;
	end
	else
		Result := True;
end;

procedure tDriveInfoSet.dumpData();
var i : integer;
var DStat : tDriveStat;
begin
	writeln('=-=-=-=-=-=-=-=-=-=');
	for i:= 0 to pred(Count) do
	begin
		DStat := Objects[i] as tDriveStat;
		writeln('[',i,']', Strings[i],':>',IntToStr(DStat.FreeS),' free on ',IntToStr(DStat.TotalS));
	end;
	writeln;	
end;

function tDriveInfoSet.GetJSON() : AnsiString;
var i : integer;
var DStat : tDriveStat;
begin
	Result := '"DriveInfoSet" : [';
	for i:= 0 to pred(Count) do
	begin
		DStat := Objects[i] as tDriveStat;
		Result := Result + '{ "Name" : "'+Strings[i]+
		                   '", "TotalSize" : '+IntToStr(DStat.TotalS)+
		                   ', "FreeSize" : '+IntToStr(DStat.FreeS)+'}'+ 
		                   VirguleLast[i<>pred(count)];
	end;
	Result := Result + ']'
end;

end.