% Raw  Raw
%

%    Copyright 2009 The Mathworks, Inc.

classdef Raw < rptgen.idoc.Node
    properties (Dependent)
        Content;
    end

    % Accessor methods
    methods
        function content = get.Content(this)
            content = this.Doms.content;
        end
        
        function set.Content(this, newContent)
            transaction = this.Document.createTransaction();
            this.Doms.content = newContent;
            transaction.commit();
        end
    end
    
    methods
        function this = Raw(varargin)
            this = this@rptgen.idoc.Node(varargin{:});
        end
    end
    
    methods (Access = protected)        
        function createDomsObject(this)
            this.Doms = this.Document.DomsFactory.createdomsRaw();
        end
        
        function initialize(this,varargin)
            if ~isempty(varargin)
                this.Content = varargin{1};
            end
        end
    end
end
