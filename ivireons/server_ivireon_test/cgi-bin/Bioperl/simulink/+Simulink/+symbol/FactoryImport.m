
%   Copyright 2010 The MathWorks, Inc.

classdef FactoryImport < Simulink.symbol.FactoryBase
    %FACTORY Create Simulink.symbol.Symbol object
    
    methods
        function out = newCVariable(~,name,type)
            out = Simulink.symbol.CVariableImport(name,type);
            Simulink.symbol.FactoryImport.createDialogAgent(out);
        end
        function out = newCTypename(~,name)
            out = Simulink.symbol.CTypenameImport(name);
            Simulink.symbol.FactoryImport.createDialogAgent(out);
        end
        function out = newCStructType(~,name)
            out = Simulink.symbol.CStructTypeImport(name);
            Simulink.symbol.FactoryImport.createDialogAgent(out);
        end
        function out = newCFunction(~,~,~)
            out = []; % do not import function
        end
    end
    methods (Access=private,Static)
        function createDialogAgent(var)
            var.DialogAgent = Simulink.SymbolConfigDialog(var);
            var.DialogAgent.Obj = var;
        end
    end
end
