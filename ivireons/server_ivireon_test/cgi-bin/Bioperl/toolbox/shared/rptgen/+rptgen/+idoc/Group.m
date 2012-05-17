% Group   Container for a group of idoc node objects
%

%    Copyright 2009 The Mathworks, Inc.

classdef Group < rptgen.idoc.Node
    methods
        function this = Group(varargin)
            this = this@rptgen.idoc.Node(varargin{:});
        end
        
        function import(this, content)
            transaction = this.Document.createTransaction();
            thisDoms = this.Doms;
            this.removeChildren();
            
            doms = this.toDoms(content);
            for i = 1:length(doms)
                thisDoms.appendChild(doms{i});
            end
            
            transaction.commit();
        end
    end
    
    methods (Access = protected)
        function createDomsObject(this)
            this.Doms = this.Document.DomsFactory.createdomsGroup();
        end        
        
        function initialize(this,varargin)
            if ~isempty(varargin)
                this.import(varargin{1});
            end
        end
    end
end
