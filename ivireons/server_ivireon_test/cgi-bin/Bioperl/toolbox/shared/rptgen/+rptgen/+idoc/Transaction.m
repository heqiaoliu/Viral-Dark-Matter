% Transaction  
%

%    Copyright 2009 The Mathworks, Inc.

classdef Transaction < M3I.Transaction
    
    methods
        function this = Transaction(documentNode)
            this = this@M3I.Transaction(documentNode.DomsModel);
            rptgen.idoc.current(documentNode);
        end
    end
end
