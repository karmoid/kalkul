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
		function GetFileInfoFromIndex(Index : Integer) : tFileInfoArray;
		function GetFileInfo(S : String) : tFileInfoArray;

	public
		constructor Create();
		destructor Destroy; override;
		function AddFileStat(info : TSearchRec; LimIndex : Integer; TypeExt : String): UInt64;
		procedure DumpData;
		function GetJSON() : AnsiString;
		property Size: TUInt64 read FSize write FSize;
		property TypeExtension[Index : integer] : String read GetTypeExtension write SetTypeExtension;
		property FileInfoFromIndex [Index : integer] : tFileInfoArray read GetFileInfoFromIndex;
		property FileInfo [S : String] : tFileInfoArray read GetFileInfo;
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

function tDirectoryStat.GetFileInfoFromIndex(Index : Integer) : tFileInfoArray;
begin
	Result := Objects[Index] as tFileInfoArray;
end;

function tDirectoryStat.GetFileInfo(S : String) : tFileInfoArray;
var i : Integer;
begin
	I := IndexOf(S);
	if I <> -1 then
		Result := Objects[i] as tFileInfoArray
	else
		Result := nil;	
end;

function tDirectoryStat.AddFileStat(info : TSearchRec; LimIndex : Integer; TypeExt : String): UInt64;
var FInfoA : tFileInfoArray;
var i : integer;
begin
	if TypeExt='' then
		TypeExt := '_n/a_';
	FInfoA := FileInfo[TypeExt];
	if not assigned(FInfoA) then
	begin
		FInfoA := tFileInfoArray.Create;
		i := AddObject(TypeExt,FInfoA);
		// writeln('added [',i,'] TypeExt=',TypeExt);
	end;
	FInfoA.TakeAccount(info,LimIndex);
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