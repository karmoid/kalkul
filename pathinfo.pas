Unit PathInfo;
Interface
uses DirectoryStat,
     filekind;

type
	tPIState = (tpisNone, tpisConfigured, tpisFound, tpisFilled);

	TPathInfo = class
		private
			fPathName : WideString;
			fState : tPIState;
			fSumarize : TFileKind;
			fGroupName : String;
			fDirStats : tDirectoryStat;
		public
			constructor Create(PathN : WideString);
			destructor Destroy; override;
			function AddSizeExtension(key : string; size : Cardinal; WithDetails: Boolean; GName : String): UInt64;
			procedure dumpData();
			class function CompareNode(Item1 : TPathInfo; Item2 : TPathInfo) : Longint;			
			property PathName: WideString read FPathName write FPathName;
			property Sumarize: TFileKind read FSumarize write FSumarize;
			property State: tPIState read FState write FState;
			property GroupName: String read FGroupName write FGroupName;
			property DirStats: tDirectoryStat read FDirStats;
	end;

Implementation
uses SysUtils,
	 InternalTypes,
	 typinfo;

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

function TPathInfo.AddSizeExtension(key : string; size : Cardinal; WithDetails: Boolean; GName : String): UInt64;
begin
	// ATTENTION : Avant de pouvoir ajouter les différents cumuls par extension
	// il va falloir trouver un moyen pour avoir un tableau de structure
	// cumul... Je ne pense pas qu'utiliser FileKind soit la bonne méthode
	// ceci va nous obliger à traiter x fois les fichiers .INI...
	// a étudier - 07 mars 2015 - C.m.
	// writeln('PathInfo > Ajout de '+key+' de taille '+IntToStr(size));
	// Result := Sumarize.AddSizeExtension(key,size,WithDetails);
	fDirStats.size.add(size);
end;

class function TPathInfo.CompareNode(Item1 : TPathInfo; Item2 : TPathInfo) : Longint;
begin
	Result := AnsiCompareText(Item1.PathName, Item1.PathName);
end;

procedure TPathInfo.dumpData();
begin
	writeln('Path(' + PathName +
		    ') State(' +  GetEnumName(TypeInfo(tPIState), ord(State)) + 
		    ') Group(' + GroupName + ') Size(' + DirStats.Size.FromByteToHR +')');
end;

end.