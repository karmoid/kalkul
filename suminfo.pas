unit suminfo;
interface
type
	TSumInformation = class
	protected

	private
		fname : WideString;
		fsize : Longint;
		function GetSizeHumanReadable(): WideString;
	public
		constructor Create(Name : WideString);
		destructor Destroy; override;
		property Size: Longint read FSize write FSize;
		property SizeHumanReadable: WideString read GetSizeHumanReadable;
		property Name: WideString read FName;
		function AddSize(Value : Integer): Integer;
	end;

implementation
uses
  SysUtils;
  
constructor TSumInformation.Create(Name : WideString);
begin
	fname := Name;	
	fsize := 0;
end;

destructor TSumInformation.Destroy; 
begin
	inherited Destroy;	
end;

function TSumInformation.AddSize(Value : Integer): Integer;
begin
	fsize := fsize + Value div 1024;
	Result := fsize;
end;

function TSumInformation.GetSizeHumanReadable(): WideString;
const Units : array[1..4] of string = ('Kib','Mib','Gib','Tib');
var index : integer;
	isize : integer;
begin
	index := 1;
	isize := fsize;
	while (index<=4) and (isize>1024) do
	begin
		index := index + 1;
		isize := isize div 1024;	
	end;
	result := IntToStr(isize) + ' ' + Units[index];	
end;

end.