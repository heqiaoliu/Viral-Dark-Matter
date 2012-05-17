% List  List
%

%    Copyright 2009 The Mathworks, Inc.

classdef List < rptgen.idoc.Group
    methods
        function this = List(varargin)
            this = this@rptgen.idoc.Group(varargin{:});
        end
        
        function import(this, content)
            % IMPORT  Imports a cell array into a list
            
            transaction = this.Document.createTransaction();
            if ischar(content)
                content = {content};
            elseif isnumeric(content) && (numel(content) == length(content))
                % Converts [1 2 3] to {'1' '2' '3'}
                contentLen = length(content);
                cellContent = cell(1,contentLen);
                for i = 1:contentLen
                    cellContent{i} = rptgen.toString(content(i));        %<<+++++++++++
                end
                content = cellContent;
            end
            this.removeChildren();
            this.insertToDomsList(this.Doms,content,1);
            transaction.commit();
        end
        
        function appendChild(this,child)
            if isa(child,'rptgen.idoc.ListItem')
                appendChild@rptgen.idoc.Node(this,child);
            else
                error('Child must be of a listitem.  Consider calling appendListItem.');
            end
            
        end
        
        function insertChild(this,child,existingChild)
            if isa(child,'rptgen.idoc.ListItem')
                insertChild@rptgen.idoc.Node(this,child,existingChild);
            else
                error('Child must be of a listitem.  Consider calling insertListItem.');
            end
        end
        
        function listitem = getListItem(this,varargin)
            % GETLISTITEM  Returns the listitem object for a given integer index 
            %    location.
            
            domsListItem = this.getDomsListItem(varargin{:});
            listitem = this.toIdoc(domsListItem);
        end
        
        function index = getListItemIndex(this, listitem)
            % GETLISTITEMINDEX  Get index for a given list item
            
            domsListItem = this.getDomsListItem(listitem);
            indexSeq = this.Doms.getListItemIndex(domsListItem.asImmutable());
            index = this.convertSequenceOfIntegerToArray(indexSeq);
            index = index + 1; % DOMS is zero based
        end
        
        function numberOfListItem = getNumberOfListItems(this,varargin)
            % GETNUMBEROFLISTITEM  Get number of list items
            
            if (~isempty(varargin))
                listItem = this.getListItem(varargin{:});
                
                sublist = listItem.getSubList();
                if ~isempty(sublist)
                    numberOfListItem = sublist.getNumberOfChildren();
                else
                    numberOfListItem = 1;
                end
            else
                numberOfListItem = this.getNumberOfChildren();
            end
        end
            
        function increaseIndent(this,listitem)
            % INCREASEINDENT  Increase indent for a given listitem
            
            transaction = this.Document.createTransaction();
            domsListItem = this.getDomsListItem(listitem);
            this.Doms.increaseIndent(domsListItem.asImmutable());
            transaction.commit();
        end
        
        function decreaseIndent(this,listitem)
            % DECREASEINDENT  Decrease indent for a given listitem
            
            transaction = this.Document.createTransaction();
            domsListItem = this.getDomsListItem(listitem);
            this.Doms.decreaseIndent(domsListItem.asImmutable());
            transaction.commit();
        end

        function removeListItem(this,varargin)
            % REMOVELISTITEM TBD
            
            transaction = this.Document.createTransaction();
            domsListItem = this.getDomsListItem(varargin{:});
            this.Doms.removeChild(domsListItem.asImmutable());
            transaction.commit();
        end
            
        function insertListItem(this,object,varargin)
            % INSERTLISTITEM  Inserts content
            
            transaction = this.Document.createTransaction();
            listPosition = varargin(1:end-1);
            targetPosition = varargin{end};

            if ~isempty(listPosition)
                % Insert to sublist
                listitem = this.getListItem(listPosition{:});
                list = listitem.findSubLists();
                if ~isempty(list)
                    list = list{1};
                else
                    list = listitem.appendList();
                end
                domsList = list.Doms;
            else
                % Insert to itself
                domsList = this.Doms;
            end

            if ~iscell(object)
                object = {object};
            end
            
            if isa(targetPosition,'rptgen.idoc.Node')
                % domsTargetObject.getSiblingIndex is zero base.  We add 2
                % because we want 1 base and want to insert after the object.
                domsTargetObject = targetPosition.Doms;
                targetPosition = domsTargetObject.getSiblingIndex() + 2;
            end
            
            this.insertToDomsList(domsList,object,targetPosition);
            transaction.commit();
        end
           
        function appendListItem(this,object,varargin)
            % APPENDLISTITEM TBD

            transaction = this.Document.createTransaction();
            if isempty(varargin)
                list = this;
            else
                listitem = this.getListItem(varargin{:});
                list = listitem.createSubList();
            end
            
            numberOfListItem = list.getNumberOfListItems() + 1;
            if iscell(object)
                list.insertToDomsList(list.Doms,object,numberOfListItem);
            else
                list.insertListItem(object,numberOfListItem);
            end
            transaction.commit();
        end
        
        function out = end(this,position,~)
            % ENDS  Returns number of listitems
            
            thisDoms = this.Doms;
            if (position == 1)
                out = thisDoms.getNumberOfChildren();
            else
                % Possible with LXE (11b)? TODO: ask martin
                error('rptgen:idoc:unsupported','unsupported tbd');
            end
        end
        
        function this = subsasgn(this,subscript,varargin)
            % SUBSASGN  Subscripted assignment to a list item object
            
            transaction = this.Document.createTransaction();
            if strcmp(subscript(1).type,'()')
                % Assignment on list item
                listitem = this.getListItem(subscript(1).subs{:});
                listitem.import(varargin{1});
            else
                % Default property assignment or method invocation
                this = builtin('subsasgn',this,varargin{:});
            end
            transaction.commit();
        end
        
        function out = subsref(this,subscript)
            % SUBSREF  Subscripted reference to a list item object
            
            if strcmp(subscript(1).type,'()')
                % Get listitem
                listitem = this.getListItem(subscript(1).subs{:});
                if (length(subscript) == 1)
                    % Return listitem
                    out = listitem;
                else
                    % Safely call builtin SUBSREF on remaining subscript
                    out = this.builtinSubsref(listitem,subscript(2:end));
                end
            else
                % Safely call builtin SUBSREF
                out = this.builtinSubsref(this,subscript);
            end
        end
    end
    
    methods (Access = protected)
        function createDomsObject(this)
            this.Doms = this.Document.DomsFactory.createdomsList();
        end  
    end    
    
    methods (Access = private)
        function insertToDomsList(this,domsList,content,index)
            % insertToDomsList  Imports a MATLAB cell array of text and/or
            %    IDOC object into a tree structure of LIST and LISTITEM DOMS at
            %    given index position.  Index is ones based!

            domsFactory = this.Document.DomsFactory;
            domsListChildren = domsList.children;
            
            % Go through each cell array element.
            numCellElements = length(content);
            previousDomsListItem = [];
            for i = 1:numCellElements
                currentElement = content{i};
                
                if (iscell(currentElement) && ~isempty(previousDomsListItem))
                    % Create sublist for previous listitem
                    % Ex.  {'a', 'b', {'subb'}}
                    domsSubList = domsFactory.createdomsList();
                    this.insertToDomsList(domsSubList,currentElement,1);
                    previousDomsListItem.appendChild(domsSubList);
                    
                elseif iscell(currentElement)
                    % listitem is wrapped inside a cell array.
                    % Ex.  {{'a'}, {'b', {'subb'}}}
                    this.insertToDomsList(this.Doms,currentElement,index);
                    previousDomsListItem = [];
                    index = index + 1;
                    
                else
                    % Simple listitem
                    % Ex.  {'a', 'b', 'c'}
                    domsElement = this.toDoms(currentElement);
                    domsElement = domsElement{1};
                    domsListItem = this.wrapInDomsListItem(domsElement);
                    previousDomsListItem = domsListItem;
                    
                    % Append to listitem to list
                    domsListChildren.insert(index,domsListItem);
                    index = index + 1;
                end
            end
        end
        
        function domsListItem = getDomsListItem(this,varargin)
            % GETDOMSLISTITEM  Returns a DOMS ListItem object for a given IDOC 
            %    object or index location.  Index location is an array of 
            %    integer.  Index is ones based!
			
            if all(cellfun(@isnumeric,varargin))
                % Convert to an array.
                indexArray = cell2mat(varargin);
    
                % Get doms listitem node, DOMS calls are zero based
                seqOfInteger = this.createSequenceOfInteger(indexArray-1);
                domsListItem = this.Doms.getListItem(seqOfInteger);
            
            else
                if isa(varargin{1},'rptgen.idoc.Node')
                    doms = varargin{1}.Doms;
                else
                    doms = varargin{1};
                end
                domsListItem = this.Doms.getListItem(doms.asImmutable());
            end
            
            domsModel = this.Document.DomsModel;
            domsListItem = domsModel.toMutable(domsListItem);
        end
  
        function domsListItem = wrapInDomsListItem(this,doms)
            % WRAPINDOMSLISTITEM  If object is not a listitem type object, then 
            %    wrap object inside a DOMS ListItem object.
            
            if ~isa(doms,'rptgen.doms.ListItem')
                domsFactory = this.Document.DomsFactory;
                domsListItem = domsFactory.createdomsListItem();
                domsListItem.appendChild(doms);
            else
                domsListItem = doms;
            end
        end
        
    end
end


        

