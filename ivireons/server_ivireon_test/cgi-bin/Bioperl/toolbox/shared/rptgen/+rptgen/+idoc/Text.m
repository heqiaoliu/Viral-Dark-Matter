% TEXT   Text
%    Text
%

%    Copyright 2009 The Mathworks, Inc.

classdef Text < rptgen.idoc.Node
    properties (Dependent)
        Content;
    end
    
    % Accessor methods
    methods
        function set.Content(this, content)
            transaction = this.Document.createTransaction();
            this.Doms.content = content;
            transaction.commit();
        end
        
        function Content = get.Content(this)
            Content = this.Doms.content;
        end
    end
    
    methods
        function this = Text(varargin)
            this = this@rptgen.idoc.Node(varargin{:});
        end
    end
    
    methods (Access = protected)
        function createDomsObject(this)
            this.Doms = this.Document.DomsFactory.createdomsText();
        end
        
        function initialize(this,varargin)
            if ~isempty(varargin)
                this.Content = varargin{1};
            end
        end
    end
end
