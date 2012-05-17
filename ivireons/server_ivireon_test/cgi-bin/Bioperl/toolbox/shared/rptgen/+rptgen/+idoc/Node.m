classdef Node < handle
% TBD  
%    Copyright 2009 The Mathworks, Inc.

    %TODO, make this abstract

    %TODO 
    %properties (Access = protected, Hidden = true)

    properties 
        Doms = [];
    end
    
    properties (Access = protected)
        Document;
    end
    
    properties (Dependent)
        Id;
        Style; 
        StyleClassName;
        AnchorId;
        Parent;
	  RawHtmlAttributes;
    end

    properties (Hidden, Dependent)
        % todo: override DISP to disp children. BUILTIN display of Children is
        % too slow caused my unnecessary calls to idoc wrapper creation.
         Children;
    end
    
    % Accessor methods
    methods
        function Id = get.Id(this)
            Id = num2str(this.Doms.identifier);
        end
        
        function Doms = get.Doms(this)
            Doms = this.Doms;
        end
        
        function set.Doms(this, domsObject)
            this.Doms = domsObject;
        end
        
        function StyleName = get.StyleClassName(this)
            StyleName = this.Doms.styleClassName;
        end
        
        function set.StyleClassName(this, newStyleName)
            transaction = this.Document.createTransaction();
            this.Doms.styleClassName = newStyleName;
            transaction.commit();
        end
        
        function AnchorId = get.AnchorId(this)
            AnchorId = this.Doms.anchorId;
        end
        
        function set.AnchorId(this, newAnchorId)
            transaction = this.Document.createTransaction();
            this.Doms.anchorId = newAnchorId;
            transaction.commit();
        end
        
        function Style = get.Style(this)
            if (~isempty(this.Doms.style))
                Style = this.toIdoc(this.Doms.style);
            else
                Style = [];
            end
        end
                
        function set.Style(this, newStyle)
            transaction = this.Document.createTransaction();
            this.Doms.style = newStyle.Doms;
            transaction.commit();
        end
        
        function Parent = get.Parent(this)
            Parent = this.toIdoc(this.getDomsParent());
        end
        
        function set.Parent(this, newParent)
            transaction = this.Document.createTransaction();
            this.Doms.parent = newParent.Doms;
            transaction.commit();
        end
        
        function Children = get.Children(this)
            Children = this.toIdoc(this.Doms.children);
        end
        
        function set.Children(this, newChildren)
            transaction = this.Document.createTransaction();
            % remove 
            thisDoms = this.Doms;
            domsSeqChildren = thisDoms.children;
            domsSeqChildren.clear();
            
            % reassign
            newNumChildren = length(newChildren);
            for i = 1:newNumChildren
                newDomsChild = newChildren{i}.Doms;
                thisDoms.appendChild(newDomsChild);
            end
            transaction.commit();
        end
        
	  function attributes = get.RawHtmlAttributes(this)
	  	attributes = this.Doms.rawHtmlAttributes;
	  end
        
	  function set.RawHtmlAttributes(this, attributes)
		transaction = this.Document.createTransaction();
	  	this.Doms.rawHtmlAttributes = attributes;
		transaction.commit();
	  end

    end
    
    methods (Static)
% %         % This function is required by the Handle base class
% %         % MAY NOT BE NECESSARY SINCE WE MOVED FROM HETROGENEOUS HANDLE TO HANDLE - check later
% %         function obj = getDefaultObject()
% %             obj = rptgen.idoc.Node();
% %         end
        
        function integerArray = convertSequenceOfIntegerToArray(seqOfIntegers)
            numIntegers = seqOfIntegers.size();
            integerArray = zeros(1,numIntegers,'int32');
            for i = 1:numIntegers
                integerArray(i) = seqOfIntegers.at(i);
            end
        end
        
    end
    
    
    methods (Static, Access = protected)
        function out = builtinSubsref(caller, subscript)
            % BUILTINSUBSREF  Safely redirect calls to builtin SUBSREF
            try
                out = builtin('subsref',caller,subscript);
            catch me
                if strcmp(me.identifier,'MATLAB:maxlhs')
                    out = caller;
                    builtin('subsref',caller,subscript);
                else
                    rethrow(me);
                end
            end
        end
    end
    
    
    
    % Do not show to user
    methods (Hidden = true)
        function L = addlistener(this, varargin)
            L = this.addlistener@Handle(varargin{:});
        end
        
        function notify(this, varargin)
            this.notify(varargin{:});
        end
        
        function tf = le(this,other)
            tf = this.le@Handle(other);
        end
        
        function tf = ge(this,other)
            tf = this.ge@Handle(other);
        end        
        
        function tf = gt(this,other)
            tf = this.gt@Handle(other);
        end
        
        function tf = lt(this,other)
            tf = this.lt@Handle(other);
        end
        
        %revisit later %%HACK!!
        function out = findobj(this, varargin)
            factory = this.Document.DomsFactory;
            seeker = factory.createutilseekerNodeSeeker();
            i = 0;
            nargs = nargin - 1;
            
            useRegEx = false;
            
            while (i ~= nargs)
                i = i + 1;
                switch varargin{i}
                    case '-regexp'
                        useRegEx = true;
                    case '-isa'
                        typefilter = factory.createutilseekerTypeFilter();
                        typefilter.nodeType = varargin{i+1};
                        seeker.filter = typefilter;
                        i = i + 1;
                    otherwise
                        propfilter = factory.createutilseekerPropertyFilter();
                        propfilter.useRegularExpression = useRegEx;
                        propfilter.propertyName = varargin{i};
                        propfilter.propertyValue = varargin{i+1};
                        seeker.filter = propfilter;
                        i = i + 1;
                end
            end
            
            
            out = this.toIdoc(seeker.seek(this.Doms.asImmutable()));
        end
        
        function out = findprop(this, propname)
            out = this.findprop@Handle(propname);
        end
        
    end
    
    methods (Access = protected)
        function initialize(~,varargin)
        end
        
        function createDomsObject(~,varargin)
        end
        
        function idocObj = toIdoc(this,domsObj)

            if (isa(domsObj,'rptgen.doms.ImmutableNode') || ...
                    isa(domsObj,'rptgen.doms.ImmutableStyle'))
                domsObj = this.Document.DomsModel.toMutable(domsObj);
            end
            
            
            
            if (isa(domsObj, 'rptgen.doms.SequenceOfImmutableNode'))
                idocObj = cell(domsObj.size(),1);
                index = 1;
                iterator = domsObj.begin;
                while (iterator ~= domsObj.end)
                    idocObj{index} = this.toIdoc(iterator.item);
                    iterator.getNext;
                    index = index + 1;
                end

            elseif isempty(domsObj)
                idocObj = [];
                
            elseif (ischar(domsObj))
                idocObj = rptgen.idoc.Text(this.Document, domsObj);
                
%  TODO:: rptgen.utils.toString                
            elseif (isnumeric(domsObj))
                idocObj = this.toIdoc(rptgen.toString(domsObj));
                
            elseif (isempty(domsObj))
                idocObj = [];
            
            elseif (isa(domsObj, 'rptgen.idoc.Node'))
                idocObj = domsObj;
                
            elseif (isa(domsObj, 'rptgen.doms.Root'))
                idocObj = this.Document;
                
            elseif (isa(domsObj, 'rptgen.doms.Node') || isa(domsObj, 'rptgen.doms.Style'))
                idocObj = feval(domsObj.idocClass,this.Document,domsObj);
                idocObj.Doms = domsObj;
                
            else
                error('rptgen:idoc:Node:InvalidType', ...
                    '%s : %s', ...
                    'Input must be either rptgen.idoc.Node, char, numeric or idoc type', class(domsObj));
            end
        end

        
        
        
        
        function doms = toDoms(this, content)
            % TODOMS  Returns a cell array of doms object

            
            
            if isnumeric(content)
                num2StrFormat = this.Document.Num2StrFormat;
                if ~isempty(num2StrFormat)
                    content = num2str(content,num2StrFormat);
                else
                    content = num2str(content);
                end
            end
            
            if ischar(content)
                doms = {this.Document.DomsFactory.createdomsText()};
                doms{1}.content = content;
            else
                contentLength = length(content);
                if (isa(content,'rptgen.idoc.Node') && contentLength == 1)
                    % Handling object which has SUBSREF overwritten
                    doms = {content.Doms};
                    
                else
                    doms = {};
                    for i = 1:contentLength
                        if iscell(content)
                            currentContent = content{i};
                        else
                            currentContent = content(i);
                        end
                        
                        currentDoms = this.toDoms(currentContent);
                        if isempty(doms)
                            doms = currentDoms;
                        else
                            doms = {doms{:} currentDoms{:}};
                        end
                    end
                end
            end
        end

        
        
        
        function domsParent = getDomsParent(this)
            thisDoms = this.Doms;
            domsParent = [];
            if isvalid(thisDoms.parent)
                domsParent = thisDoms.parent;
            end
        end
        
        function seqOfInteger = createSequenceOfInteger(this, integerArray)
            seqOfInteger = M3I.SequenceOfInteger.make(this.Document.DomsModel);
            integerArray = int32(integerArray);
            arrayLength = numel(integerArray);
            for i = 1:arrayLength
                seqOfInteger.append(integerArray(i));
            end
        end
        
        function siblingDoms = getDomsSiblingAtOffset(this, offset)
            % GETDOMSSIBLINGATOFFSET  Returns a DOMS sibling object for a given
            % offset.  An offset of 1 would return the next sibling.  An offset
            % of -1 would return the previous sibling.
            thisDoms = this.Doms;
            siblingDoms = [];
            if (thisDoms.hasSiblingAtOffset(offset))
                siblingDoms = thisDoms.getSiblingAtOffset(offset);
            end
        end
        
        function childrenDoms = getDomsChildren(this)
            % GETDOMSCHILDREN  Returns a cell array of DOMS children objects
            thisDoms = this.Doms;
            childrenSequence = thisDoms.children;
            numChildren = childrenSequence.size;
            iterator = childrenSequence.begin;
            childrenDoms = cell(1,numChildren);
            for i = 1:numChildren
                childrenDoms{i} = iterator.item;
                iterator.getNext();
            end
        end
    
        
    end
    
    methods
        function this = Node(varargin)
            if ~isempty(varargin)
                this.Document = varargin{1};

                % initialize doms object
                if (nargin > 1) && isa(varargin{2},'rptgen.doms.Node')
                    this.Doms = varargin{2};
                else
                    transaction = this.Document.createTransaction();
                    this.createDomsObject();
                    this.initialize(varargin{2:end});
                    transaction.commit();
                end
            end
        end
        
        function tf = eq(this, other)
            tf = (this.Doms == other.Doms);
        end
        
        % What does this do?
        function nodes = getNodesByClass(this)
            nodes = this.toIdoc(this.Doms.getNodesByClass());
        end
        
        function numChildren = getNumberOfChildren(this)
            numChildren = this.Doms.getNumberOfChildren();
        end
        
        function appendChildren(this, children)
            transaction = this.Document.createTransaction();
            for i = 1:length(children)
                child = children(i);
                this.Doms.appendChild(child.Doms.asImmutable());
            end
            transaction.commit();
        end
        
        % To do, more natural at document level??
%         import rptgen.idoc.*;
%         d = Document('t003.html');        
%         d.OutputFormat = 'html';
% 
%         chapter1 = d.appendSection('Chapter 1 Title');
%         chapter2 = d.appendSection('Chapter 2 Title');
%         newChapter = Section(d, 'Between Chapter 1 and 2');
%         newChapter.insert(chapter1);
%         d.generateReport();        

        %revisit later
        function insert(this, destinationNode)
            transaction = this.Document.createTransaction();
            thisDoms = this.Doms;
            destinationNodeDoms = destinationNode.Doms;
            newParentDoms = destinationNode.getDomsParent();
            newParentDoms.insertChild(thisDoms, ...
                                      destinationNodeDoms.asImmutable());
            transaction.commit();
        end
        
        function appendChild(this, child)
            transaction = this.Document.createTransaction();
            this.Doms.appendChild(child.Doms);
            transaction.commit();
        end
        
        function insertChild(this, child, position)
            transaction = this.Document.createTransaction();
            if isnumeric(position)
                this.Doms.insertChild(child.Doms, ...
                    position-1);  % DOMS calls are zero based
            else
                
                this.Doms.insertChild(child.Doms, ...
                    position.Doms.asImmutable());
            end
            transaction.commit();
        end

        function removeChild(this, child)
            transaction = this.Document.createTransaction();
            this.Doms.removeChild(child.Doms.asImmutable());
            transaction.commit();
        end
        
        function removeChildren(this, varargin)
            transaction = this.Document.createTransaction();
            thisDoms = this.Doms;
            if isempty(varargin)
                domsSeqChildren = thisDoms.children;
                domsSeqChildren.clear();
            else
                if (length(varargin) == 1)  && iscell(varargin{1})
                    toRemove = varargin{1};
                else
                    toRemove = varargin;
                end
                
                
                numChildren = length(toRemove);
                children = cell(1,numChildren);
                if all(cellfun(@isnumeric, toRemove))
                    % Get children reference
                    for i = 1:numChildren
                        children{i} = thisDoms.getChildAtIndex(toRemove{i}-1); % DOMS is zero-based
                    end
                else 
                    for i = 1:numChildren
                        children{i} = toRemove{i}.Doms;
                    end
                end
                
                % to do.  support index
                for i = 1:length(children)
                    child = children{i};
                    this.Doms.removeChild(child.asImmutable());
                end
            end
            transaction.commit();
            
        end
        
        function index = getChildIndex(this, child)
            index = this.Doms.getChildIndex(child.Doms.asImmutable()) + 1;
        end
        
        function node = getNodeById(this, id)
            node = this.toIdoc(this.Doms.getNodeById(id));
        end
        
        function attributeValue = getStyleAttribute(this, name)
            name = rptgen.idoc.Style.stringToStyleAttribute(name);
            attributeValue = this.Doms.getStyleAttribute(name);
        end
        
        function setStyleAttribute(this, name, value)
%% TODO:: rptgen.utils.toString            
%%  Actually - maybe there should just be an overridden c++ method
            name = rptgen.idoc.Style.stringToStyleAttribute(name);
            transaction = this.Document.createTransaction();
            if (isa(value, 'char'))
                this.Doms.setStyleAttribute(name, value);
            elseif (value)
                this.Doms.setStyleAttribute(name, '1');
            else
                this.Doms.setStyleAttribute(name, '0');
            end
            transaction.commit();
        end
        
        % Need to discuss with greg
        function attributeValue = getDirectStyleAttribute(this, name, value)
            name = rptgen.idoc.Style.stringToStyleAttribute(name);            
            attributeValue = this.Doms.getDirectStyleAttribute(name, value);
        end
        
        
        function node = getFollowingSibling(this)
            node = this.toIdoc(this.getDomsSiblingAtOffset(1));
        end
        
        function node = getPrecedingSibling(this)
            node = this.toIdoc(this.getDomsSiblingAtOffset(-1));
        end        
        
        function tf = isDescendent(this, other)
            tf = this.Doms.isDescendent(other.Doms.asImmutable());
        end
        
        function tf = isDescendentOrSelf(this, other)
            tf = this.Doms.isDescendentOrSelf(other.Doms.asImmutable());
        end

        function tf = isAncestor(this, other)
            tf = this.Doms.isAncestor(other.Doms.asImmutable());
        end
        
        function tf = isAncestorOrSelf(this, other)
            tf = this.Doms.isAncestorOrSelf(other.Doms.asImmutable());
        end

        
    end

    % Convenience methods
    methods 
        function newObj = appendParagraph(this, varargin)
            transaction = this.Document.createTransaction();
            newObj = rptgen.idoc.Paragraph(this.Document, varargin{:});
            this.appendChild(newObj);
            transaction.commit();
        end
        
        function newObj = appendText(this, varargin)
            transaction = this.Document.createTransaction();
            newObj = rptgen.idoc.Text(this.Document, varargin{:});
            this.appendChild(newObj);
            transaction.commit();
        end
        
        function newObj = appendSection(this, title)
            transaction = this.Document.createTransaction();
            if (nargin > 1)
                newObj = rptgen.idoc.Section(this.Document, title);
            else
                newObj = rptgen.idoc.Section(this.Document);
            end
            this.appendChild(newObj);
            transaction.commit();
        end
        
        function newObj = appendImage(this, filename)
            transaction = this.Document.createTransaction();
            if (nargin > 1)
                newObj = rptgen.idoc.Image(this.Document, filename);
            else
                newObj = rptgen.idoc.Image(this.Document);
            end
            this.appendChild(newObj);
            transaction.commit();
        end
        
        function newObj = appendLink(this, destination, targetArea)
            transaction = this.Document.createTransaction();
            if (nargin > 2)
                newObj = rptgen.idoc.Link(this.Document, destination, targetArea);
            elseif (nargin > 1)
                newObj = rptgen.idoc.Link(this.Document, destination);
            else
                newObj = rptgen.idoc.Link(this.Document);
            end
            this.appendChild(newObj);
            transaction.commit();
        end
        
        function newObj = appendList(this, varargin)
            transaction = this.Document.createTransaction();
            newObj = rptgen.idoc.List(this.Document, varargin{:});
            this.appendChild(newObj);
            transaction.commit();
        end
        
        function newObj = appendTable(this, varargin)
            transaction = this.Document.createTransaction();
            newObj = rptgen.idoc.Table(this.Document, varargin{:});
            this.appendChild(newObj);
            transaction.commit();
        end
        
        function newObj = appendGroup(this)
            transaction = this.Document.createTransaction();
            newObj = rptgen.idoc.Group(this.Document);
            this.appendChild(newObj);
            transaction.commit();
        end
        
        function newObj = appendTitlePage(this, title)
            transaction = this.Document.createTransaction();
            if (nargin > 1)
                newObj = rptgen.idoc.TitlePage(this.Document, title);
            else
                newObj = rptgen.idoc.TitlePage(this.Document);
            end
            this.appendChild(newObj);
            transaction.commit();
        end
        
        function newObj = appendRaw(this, content)
            transaction = this.Document.createTransaction();
            if (nargin > 1)
                newObj = rptgen.idoc.Raw(this.Document, content);
            else
                newObj = rptgen.idoc.Raw(this.Document);
            end
            this.appendChild(newObj);
            transaction.commit();
        end
        
        function newObj = appendJavascript(this, content)
            transaction = this.Document.createTransaction();
            if (nargin > 1)
                newObj = rptgen.idoc.Javascript(this.Document, content);
            else
                newObj = rptgen.idoc.Javascript(this.Document);
            end
            this.appendChild(newObj);
            transaction.commit();
        end
        
        
       
     end
    
end
