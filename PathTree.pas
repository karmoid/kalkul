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
uses SysUtils;

function CompareNode(Item1 : Pointer; Item2 : Pointer) : Longint;
var Node1 : TPathInfo absolute Item1;
 	Node2 : TPathInfo absolute Item2;
	begin
		Result := AnsiCompareText(Node1.PathName,Node2.Pathname);
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
var TreeItem,Node : TAVLTreeNode;
var MyData : TPathInfo;
	begin
		writeln('\nDump Sorted Tree ftree:');
		TreeEnum := fTree.GetEnumerator;
		While TreeEnum.MoveNext do
		begin
			TreeItem := TreeEnum.Current;
			with TPathInfo(TreeItem.Data) do
			begin
				write('(Item : Prof(' + IntToStr(TreeItem.TreeDepth) + ') ');
				dumpData;			
			end;
		end;
		//for Node in fTree do begin
    	//	MyData:=TPathInfo(Node.Data);
    	//	writeln(MyData.PathName);
    	//end;	
	end;

function TPathTree.AddPathInfo(Name : String) : TPathInfo;
var PI : TPathInfo;
var Node : TAVLTreeNode;
	begin
		try
			PI := tPathInfo.create(Name);
			Node := fTree.find(PI);
			if assigned(Node) then
			begin
				// writeln('Find "',Name,'" give ',TPathInfo(Node.Data).PathName);
				PI.free;
				PI := TPathInfo(Node.Data);
				PI.State := tpisFound;
			end
			else
			begin
				// writeln('Find "',Name,'" give nothing. Create Node');
				Node := fTree.Add(PI);
			end;	
			Result := PI;
		except on e: Exception do writeln('exception ',e.message);
		end;	
	end;

end.