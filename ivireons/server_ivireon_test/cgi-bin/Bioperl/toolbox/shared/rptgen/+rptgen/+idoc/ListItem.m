% List  List
%

%    Copyright 2009 The Mathworks, Inc.

classdef ListItem < rptgen.idoc.Group
    methods
        function this = ListItem(varargin)
            this = this@rptgen.idoc.Group(varargin{:});
        end
        
        function increaseIndent(this)
            % INCREASEINDENT  Increase indent
            
            transaction = this.Document.createTransaction();
            this.Doms.increaseIndent();
            transaction.commit();
        end
        
        function decreaseIndent(this)
            % DECREASEINDENT  Decrease indent
            
            transaction = this.Document.createTransaction();
            this.Doms.decreaseIndent();
            transaction.commit();
        end
        
        function index = getListItemIndex(this)
            % GETLISTITEMINDEX  Get list index 

            indexSeq = this.Doms.getListItemIndex();
            index = this.convertSequenceOfIntegerToArray(indexSeq);
            index = index + 1; % DOMS is zero based
        end
        
        function sublist = findSubLists(this)
            % FINDSUBLISTS  Finds childrens that are list objects
            
            disp('todo: clean this up after we finalize findobj');
            disp('todo: make this shallow');
            sublist = this.findobj('-isa','List'); 
        end
    end
    
    methods (Access = protected)
        function createDomsObject(this)
            this.Doms = this.Document.DomsFactory.createdomsListItem();
        end 
    end
end

% ??? 
%         function append(this, object)
%             % APPEND - TBD
%             this.Document.beginChanges();
%             if iscell(object)
%                 this.createSubList(object);
%             
%             elseif isa(object,'rptgen.idoc.List')
%                 sublist = this.createSubList();
%                 sublist.append(object);
%                 
%             elseif isa(object,'rptgen.idoc.ListItem')
%                 list = this.Parent;
%                 list.insertListItem(object,this);
%             
%             else
%                 this.append@rptgen.idoc.Node(object);
%             end
%             this.Document.commitChanges();
%         end
%         
%         function insert(this, object, varargin)
%             % INSERT - TBD
%             this.Document.beginChanges();
%             if iscell(object)
%                 sublist = this.createSubList();
%                 sublist.insert(object, varargin{:});
%             else
%                 this.insert@rptgen.idoc.Node(object,varargin{:});
%             end
%             this.Document.commitChanges();
%         end
