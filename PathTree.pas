Unit PathTree;
interface
uses AVL_tree;

type
	pPathInfo = ^TPathInfo;
	TPathInfo = record
		PathName : String;
	end;

	TPathTree = class
		private
			fTree : TAVLTree;
		public
			constructor Create();
			destructor Destroy; override;
			function AddPathInfo(Name : String) : pPathInfo;
			procedure BrowseAll;
	end;

implementation
uses SysUtils;

function CompareNode(Item1 : Pointer; Item2 : Pointer) : Longint;
var Node1 : pPathInfo absolute Item1;
 	Node2 : pPathInfo absolute Item2;
	begin
		if Assigned(Item1) then
			begin
			if Assigned(Item2) then
				Result := StrComp(@Node1^.PathName[1], @Node2^.PathName[1])
			else
				Result := 1;
			end
		else 
			begin
			if Assigned(Item2) then
				Result := -1
			else
				Result := 0;	
			end;
	end;

constructor TPathTree.Create();
	begin
		ftree := TAVLTree.create(@CompareNode);
	end;

destructor TPathTree.Destroy; 
	begin
		// BrowseAll;
		ftree.free;
	end;	

procedure TPathTree.BrowseAll;
var TreeEnum : TAVLTreeNodeEnumerator;	
var TreeItem : TAVLTreeNode;
	begin
		writeln('\nTree ftree Report as String:');
		WriteLn(ftree.Count:5, fTree.ReportAsString);
		writeln('\nDump Sorted Tree ftree:');
		TreeEnum := fTree.GetEnumerator;
		While TreeEnum.MoveNext do
		begin
			TreeItem := TreeEnum.Current;
			writeln('Item : ' + IntToStr(TreeItem.TreeDepth) + pPathInfo(TreeItem.Data)^.PathName);
		end;
	end;

function TPathTree.AddPathInfo(Name : String) : pPathInfo;
var pPI : pPathInfo;
	begin
		pPI := new(pPathInfo);
		Fillchar(pPI^, SizeOf(TPathInfo), Byte(0));
		pPI^.PathName := Name;
		fTree.Add(pPI);
		Result := pPI;
	end;

end.