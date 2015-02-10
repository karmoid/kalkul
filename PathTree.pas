Unit PathTree;
interface
uses AVL_tree;

type
	PTreeElement = ^TTreeElement;
	TTreeElement = record
		Next : PTreeElement;
		Parent : PTreeElement;
		Child : PTreeElement;
		ItemName : String
	end;

	pPathInfo = ^TPathInfo;
	TPathInfo = record
		Name : String;
	end;

	TPathTree = class
			fRoot : PTreeElement;
			fTree : TAVLTree;
		private
			function NewTreeElement : PTreeElement;	
			function InitTreeElement(Item : PTreeElement) : PTreeElement;	
			procedure DumpNode(Base : PTreeElement);
		public
			constructor Create();
			destructor Destroy; override;
			procedure AddItems(value : String);
			function AddPathInfo(Name : String) : pPathInfo;
			procedure BrowseAll;
			procedure BrowseFrom(Base : PTreeElement; Level : Integer);
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
				Result := StrComp(@Node1.Name[1], @Node2.Name[1])
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
		fRoot := NewTreeElement;
		fRoot.ItemName := '\';
		ftree := TAVLTree.create(CompareNode);
	end;

destructor TPathTree.Destroy; 
	begin
		// fTronc.free;
	end;	

function TPathTree.NewTreeElement : PTreeElement;	
	begin
		Result := InitTreeElement(New(PTreeElement));
	end;

function TPathTree.InitTreeElement(Item : PTreeElement) : PTreeElement;	
	begin
		Fillchar(Item^, SizeOf(TTreeElement), byte(0));
		Result := Item;
	end;


procedure TPathTree.AddItems(value : String);
var Current : PTreeElement;	
	LastCurrent : PTreeElement;
	begin
		Current := NewTreeElement;	
		fRoot.Child := Current;
		Current.ItemName := Value+'1';
		Current.Parent := fRoot;
		LastCurrent := Current;

		Current := NewTreeElement;	
		LastCurrent.Child := Current;
		Current.ItemName := Value+'11';
		Current.Parent := LastCurrent;
		LastCurrent := Current;

		Current := NewTreeElement;	
		LastCurrent.Next := Current;
		Current.ItemName := Value+'12';
		Current.Parent := LastCurrent.Parent;
	end;

procedure TPathTree.BrowseAll;
var TreeEnum : TAVLTreeNodeEnumerator;	
var TreeItem : TAVLTreeNode;
	begin
		writeln('Dump Internal Tree fRoot:');
		BrowseFrom(fRoot,0);
		writeln('\nTree ftree Report as String:');
		WriteLn(ftree.Count:5, fTree.ReportAsString);
		writeln('\nDump Sorted Tree ftree:');
		TreeEnum := fTree.GetEnumerator;
		While TreeEnum.MoveNext do
		begin
			TreeItem := TreeEnum.Current;
			writeln('Item : ' + IntToStr(TreeItem.TreeDepth) + pPathInfo(TreeItem.Data).Name);
		end;
	end;

procedure TPathTree.DumpNode(Base : PTreeElement);
	begin
		if Assigned(Base.Parent) then
			WriteLn(Base.ItemName + ' has parent ' + Base.Parent.ItemName)
		else	
			WriteLn(Base.ItemName + ' has no parent');
		if Assigned(Base.Child) then
			WriteLn(Base.ItemName + ' has children and first is ' + Base.Child.ItemName)
		else	
			WriteLn(Base.ItemName + ' has no child');
		if Assigned(Base.Next) then
			WriteLn(Base.ItemName + ' has brothers and next is ' + Base.Next.ItemName)
		else	
			WriteLn(Base.ItemName + ' has no brother');
	end;

procedure TPathTree.BrowseFrom(Base : PTreeElement; Level : Integer);
var Current : PTreeElement;	
	begin
		Current := Base;
		While Assigned(Current) do
		begin
			WriteLn('('+IntToStr(Level)+') '+Base.ItemName);
			DumpNode(Base);
			if Assigned(Base.Child) then
				BrowseFrom(Base.Child,Level+1);
			Current := Current.Next;	
		end;		
	end;

function TPathTree.AddPathInfo(Name : String) : pPathInfo;
var pPI : pPathInfo;
	begin
		pPI := new(pPathInfo);
		Fillchar(pPI^, SizeOf(TPathInfo), Byte(0));
		pPI.Name := Name;
		fTree.Add(pPI);
		Result := pPI;
	end;

end.