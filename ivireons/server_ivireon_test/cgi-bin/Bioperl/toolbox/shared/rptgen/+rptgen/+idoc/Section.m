% Section   Section
%

%    Copyright 2009 The Mathworks, Inc.

classdef Section < rptgen.idoc.Node
    properties (Dependent)
        Title;
    end

    % Accessor methods
    methods
        function title = get.Title(this)
            title = this.toIdoc(this.Doms.title);
        end
        
        function set.Title(this, newTitle)
            transaction = this.Document.createTransaction();
            
            newTitle = this.toDoms(newTitle);
            this.Doms.title = newTitle{1};
            
            transaction.commit();
        end
    end
    
    methods
        function this = Section(varargin)
            this = this@rptgen.idoc.Node(varargin{:});
        end
        
        function sectionNumber = getSectionNumber(this)
            seqOfNumbers = this.Doms.getSectionNumber();
            sectionDepth = seqOfNumbers.size();
            sectionNumber = zeros(sectionDepth,1);
            
            iterator = seqOfNumbers.begin();
            for i = 1:sectionDepth
                sectionNumber(i) = iterator.item;
                iterator.getNext();
            end
        end
    end
    
    methods (Access = protected)
        function createDomsObject(this)
            this.Doms = this.Document.DomsFactory.createdomsSection();
        end
        
        function initialize(this,varargin)
            if ~isempty(varargin)                    
                this.Title = varargin{1};
            end
        end
    end
end
