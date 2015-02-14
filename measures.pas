// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//
// Measures defined : We define some Objects and Strcuture to
// manage and store Sizes and Dates
//
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
unit Measures;
interface
uses Classes;

type
	cMeasuresItem = (miCreated, miModified, miAccessed);
	cMeasuresItemSlice = (misMin, misMax);

	TMeasures = class
	private
		fSizes : Array[cMeasuresItemSlice] of uInt64;
		fDates : Array[cMeasuresItemSlice,cMeasuresItem] of TDateTime;
		fCount : uInt64;
	public

	end;

Implementation


end;	