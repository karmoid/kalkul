unit DirectoryStat;

interface
uses Classes,
	sysUtils,
  	InternalTypes;

type
	tDirectoryStat = class(tStringList)
	private	
		fSize : TUInt64;
		function GetTypeExtension(Index : Integer) : String;
		procedure SetTypeExtension(Index : Integer; S : String);
		function GetFileInfoFromIndex(Index : Integer) : tFileInfo;
		function GetFileInfo(S : String) : tFileInfo;

	public
		constructor Create();
		destructor Destroy; override;
		function AddFileStat(info : TSearchRec; TypeExt : String): UInt64;
		procedure DumpData;
		function GetJSON() : AnsiString;
		property Size: TUInt64 read FSize write FSize;
		property TypeExtension[Index : integer] : String read GetTypeExtension write SetTypeExtension;
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

function tDirectoryStat.GetTypeExtension(Index : Integer) : String;
begin
	Result := Strings[Index];
end;

procedure tDirectoryStat.SetTypeExtension(Index : Integer; S : String);
begin
	Strings[Index] := S;
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

function tDirectoryStat.AddFileStat(info : TSearchRec; TypeExt : String): UInt64;
var FInfo : tFileInfo;
var i : integer;
begin
	if TypeExt='' then
		TypeExt := '_n/a_';
	FInfo := FileInfo[TypeExt];
	if not assigned(FInfo) then
	begin
		FInfo := tFileInfo.Create;
		i := AddObject(TypeExt,FInfo);
		// writeln('added [',i,'] TypeExt=',TypeExt);
	end;
	FInfo.TakeAccount(info);
end;

procedure tDirectoryStat.DumpData;
var i : Integer;	
begin
	for i:=0 to pred(count) do
		writeln('  TypeExt[',i,'] ',Strings[i],':>',FileInfoFromIndex[i].GetData);
end;

function tDirectoryStat.GetJSON() : AnsiString;
var i : integer;
begin
	Result := '"DirStat" : [';
	for i:=0 to pred(count) do
		Result := Result + '{ "TypeExtName" : "' + Strings[i] +'", '+
		          FileInfoFromIndex[i].GetJSON + '}' + VirguleLast[i<>pred(count)];
	Result := Result + ']'
end;


end.