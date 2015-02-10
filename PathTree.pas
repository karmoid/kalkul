Unit PathTree;
interface
uses AVL_tree;

type
	PTreeElement = ^TTreeElement;
	TTreeElement = record
		Next : PTreeElement;
		Parent : PTreeElement;
		Child : PTreeElement;
		Value : String
	end;

	TPathTree = class
			fRoot : PTreeElement;
		private
			function NewTreeElement : PTreeElement;	
			function InitTreeElement(Item : PTreeElement) : PTreeElement;	
			procedure DumpNode(Base : PTreeElement);
		public
			constructor Create();
			destructor Destroy; override;
			procedure AddItems(value : String);
			procedure BrowseAll;
			procedure BrowseFrom(Base : PTreeElement; Level : Integer);
	end;

implementation
uses SysUtils;

constructor TPathTree.Create();
	begin
		fRoot := NewTreeElement;
		fRoot.Value := '\';
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
		WriteLn('initializing with 0 on ', SizeOf(TTreeElement):10, ' bytes');
		Fillchar(Item^, word(0), SizeOf(TTreeElement));
		Item.Parent := nil;
		Item.Next := nil;
		Item.Child := nil;
		Item.Value := '';
		Result := Item;
	end;


procedure TPathTree.AddItems(value : String);
var Current : PTreeElement;	
	LastCurrent : PTreeElement;
	begin
		Current := NewTreeElement;	
		fRoot.Child := Current;
		Current.Value := Value+'1';
		Current.Parent := fRoot;
		LastCurrent := Current;

		Current := NewTreeElement;	
		LastCurrent.Child := Current;
		Current.Value := Value+'11';
		Current.Parent := LastCurrent;
		LastCurrent := Current;

		Current := NewTreeElement;	
		LastCurrent.Next := Current;
		Current.Value := Value+'12';
		Current.Parent := LastCurrent.Parent;
	end;

procedure TPathTree.BrowseAll;
	begin
		BrowseFrom(fRoot,0);
	end;

procedure TPathTree.DumpNode(Base : PTreeElement);
	begin
		if Assigned(Base.Parent) then
			WriteLn(Base.Value + ' has parent ' + Base.Parent.Value)
		else	
			WriteLn(Base.Value + ' has no parent');
		if Assigned(Base.Child) then
			WriteLn(Base.Value + ' has children and first is ' + Base.Child.Value)
		else	
			WriteLn(Base.Value + ' has no child');
		if Assigned(Base.Next) then
			WriteLn(Base.Value + ' has brothers and next is ' + Base.Next.Value)
		else	
			WriteLn(Base.Value + ' has no brother');
	end;

procedure TPathTree.BrowseFrom(Base : PTreeElement; Level : Integer);
var Current : PTreeElement;	
	begin
		Current := Base;
		While Assigned(Current) do
		begin
			WriteLn('('+IntToStr(Level)+') '+Base.Value);
			DumpNode(Base);
			if Assigned(Base.Child) then
				BrowseFrom(Base.Child,Level+1);
			Current := Current.Next;	
		end;		
	end;

end.