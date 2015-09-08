unit DriveStat;

interface
uses Classes,
	sysUtils;

type
	tDriveStat = class
	private
		fTotalS : uInt64;
		fFreeS : UInt64;
	public
		property TotalS: uInt64 read FTotalS write FTotalS;	
		property FreeS: uInt64 read FFreeS write FFreeS;
	end;

implementation


end.