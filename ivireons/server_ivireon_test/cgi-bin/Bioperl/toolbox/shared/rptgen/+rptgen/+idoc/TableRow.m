% TABLEROW   Table row
%    Table row is a container for a list of table cells.
%
%    See also rptgen.idoc.Table

%    Copyright 2009 The Mathworks, Inc.

classdef TableRow < rptgen.idoc.Node
    methods
        function this = TableRow(varargin)
            this = this@rptgen.idoc.Node(varargin{:});
        end
    end
    
    methods (Access = protected)
        function createDomsObject(this)
            this.Doms = this.Document.DomsFactory.createdomsTableRow();
        end        
    end
end
