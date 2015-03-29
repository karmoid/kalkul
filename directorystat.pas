unit DirectoryStat;

interface
uses InternalTypes;
type
	tDirectoryStat = class
	private	
		fSize : TUInt64;
	public
	constructor Create();
	destructor Destroy; override;
	property Size: TUInt64 read FSize write FSize;
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

end.