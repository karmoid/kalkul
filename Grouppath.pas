unit GroupPath;
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//
// Ini management : Chargement des options de fichiers .INI
// Permet d'exploiter les paramétres en fichier de configuration
// et (a faire...) en overide ligne de commande
//
// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
interface
uses Classes;

type
	TGroupPath = class
	private
		fGroup : String;				// Nom du Groupe
		fSpecificPaths : TSpecificPath;	// Stocke les items Liste de path
		fExtensions : TFileKind;		// Stocket les extensions Override ou Add

	public

	end;

Implementation

end;