Unit PathInfo;
Interface
uses filekind;

type
	tPIState = (tpisConfigured, tpisFound, tpisFilled);

	TPathInfo = class
		private
			fPathName : WideString;
			fState : tPIState;
			fSumarize : TFileKind;
		public
			constructor Create(PathN : WideString);
			destructor Destroy; override;
			function AddSizeExtension(key : string; size : Cardinal; WithDetails: Boolean): UInt64;
			property PathName: WideString read FPathName write FPathName;
			property Sumarize: TFileKind read FSumarize write FSumarize;
			property State: tPIState read FState write FState;
	end;

Implementation
uses SysUtils;

constructor TPathInfo.Create(PathN : WideString);
begin
	fPathName := PathN;
	// fSumarize := TFileKind.Create();
end;

destructor TPathInfo.Destroy; 
begin
	fPathName := '';
	fSumarize.free;
	inherited Destroy;	
end;

function TPathInfo.AddSizeExtension(key : string; size : Cardinal; WithDetails: Boolean): UInt64;
begin
	// ATTENTION : Avant de pouvoir ajouter les différents cumuls par extension
	// il va falloir trouver un moyen pour avoir un tableau de structure
	// cumul... Je ne pense pas qu'utiliser FileKind soit la bonne méthode
	// ceci va nous obliger à traiter x fois les fichiers .INI...
	// a étudier - 07 mars 2015 - C.m.
	// writeln('PathInfo > Ajout de '+key+' de taille '+IntToStr(size));
	// Result := Sumarize.AddSizeExtension(key,size,WithDetails);
end;

end.