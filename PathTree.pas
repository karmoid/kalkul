Unit PathTree;
interface
uses AVL_tree,
	 pathinfo;

type
	TPathTree = class
		private
			fTree : TAVLTree;
		public
			constructor Create();
			destructor Destroy; override;
			function AddPathInfo(Name : String) : TPathInfo;
			procedure BrowseAll;
	end;

implementation
uses SysUtils,
	 typinfo;

function CompareNode(Item1 : Pointer; Item2 : Pointer) : Longint;
var Node1 : TPathInfo absolute Item1;
 	Node2 : TPathInfo absolute Item2;
	begin
		Result := TPathInfo.CompareNode(Node1,Node2);
	end;

constructor TPathTree.Create();
	begin
		ftree := TAVLTree.create(@CompareNode);
	end;

destructor TPathTree.Destroy; 
	begin
		BrowseAll;
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
			writeln('Item : Prof(' + IntToStr(TreeItem.TreeDepth) + 
				    ') Path(' + TPathInfo(TreeItem.Data).PathName +
				    ') State(' +  GetEnumName(TypeInfo(tPIState), ord(TPathInfo(TreeItem.Data).State)) + ')');
		end;
	end;

function TPathTree.AddPathInfo(Name : String) : TPathInfo;
var PI : TPathInfo;
	begin
		PI := tPathInfo.create(Name);
		fTree.Add(PI);
		Result := PI;
	end;

end.