% Paragraph  Paragraph
%

%    Copyright 2009 The Mathworks, Inc.

classdef Paragraph < rptgen.idoc.Group
    properties (Dependent)
        Title;
    end
    
    % Accessor methods
    methods
        function title = get.Title(this)
            title = this.toIdoc(this.Doms.title);
        end
        
        function set.Title(this, newTitle)
            this.Doms.title = this.toDoms(newTitle);
        end
    end
    
    methods
        function this = Paragraph(varargin)
            this = this@rptgen.idoc.Group(varargin{:});
        end
    end
    
    methods (Access = protected)
        function createDomsObject(this)
            this.Doms = this.Document.DomsFactory.createdomsParagraph();
        end        
    end
end
