unit DirectoryStat;

interface
uses Classes,
	sysUtils,
  	InternalTypes;

type
	tDirectoryStat = class(tStringList)
	private	
		fSize : TUInt64;
		function GetGroupName(Index : Integer) : String;
		procedure SetGroupName(Index : Integer; S : String);
		function GetFileInfoFromIndex(Index : Integer) : tFileInfo;
		function GetFileInfo(S : String) : tFileInfo;

	public
		constructor Create();
		destructor Destroy; override;
		function AddFileStat(info : TSearchRec; GName : String): UInt64;
		property Size: TUInt64 read FSize write FSize;
		property GroupName[Index : integer] : String read GetGroupName write SetGroupName;
		property FileInfoFromIndex [Index : integer] : tFileInfo read GetFileInfoFromIndex;
		property FileInfo [S : String] : tFileInfo read GetFileInfo;
	end;

implementation

constructor tDirectoryStat.Create();
begin
	fSize := TUInt64.Create(0);	
end;

destructor tDirectoryStat.Destroy; 
begin
	fSize.free;
	inherited Destroy;	
end;

function tDirectoryStat.GetGroupName(Index : Integer) : String;
begin
	Result := ValueFromIndex[Index];
end;

procedure tDirectoryStat.SetGroupName(Index : Integer; S : String);
begin
	ValueFromIndex[Index] := S;
end;

function tDirectoryStat.GetFileInfoFromIndex(Index : Integer) : tFileInfo;
begin
	Result := Objects[Index] as tFileInfo;
end;

function tDirectoryStat.GetFileInfo(S : String) : tFileInfo;
var i : Integer;
begin
	I := IndexOf(S);
	if I <> -1 then
		Result := Objects[i] as tFileInfo
	else
		Result := nil;	
end;

function tDirectoryStat.AddFileStat(info : TSearchRec; GName : String): UInt64;
var FInfo : tFileInfo;
begin
	FInfo := FileInfo[GName];
	if not assigned(FInfo) then
	begin
		FInfo := tFileInfo.Create;
		AddObject(GName,FInfo);
	end;
	FInfo.TakeAccount(info);
end;


end.