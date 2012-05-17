% Javascript  Javascript
%

%    Copyright 2009 The Mathworks, Inc.

classdef Javascript < rptgen.idoc.Raw

    properties (Dependent)
        SourceFile;
    end

    % Accessor methods
    methods
        function sourceFile = get.SourceFile(this)
            sourceFile = this.Doms.sourceFile;
        end
        
        function set.SourceFile(this, newSrc)
            transaction = this.Document.createTransaction();
            this.Doms.sourceFile = newSrc;
            transaction.commit();
        end
    end
    
    methods
        function this = Javascript(varargin)
            this = this@rptgen.idoc.Raw(varargin{:});
        end
    end
    
    methods (Access = protected)
        function createDomsObject(this)
            this.Doms = this.Document.DomsFactory.createdomsJavascript();
        end
    end
end
