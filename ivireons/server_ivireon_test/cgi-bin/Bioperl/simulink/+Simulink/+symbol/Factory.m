
%   Copyright 2010 The MathWorks, Inc.

classdef Factory < Simulink.symbol.FactoryBase
    %FACTORY Create Simulink.symbol.Symbol object
    %   Detailed explanation goes here
    
    methods
        function out = newCVariable(~,name,type)
            out = Simulink.symbol.CVariable(name,type);
            Simulink.symbol.Factory.createDialogAgent(out);
        end
        function out = newCTypename(~,name)
            out = Simulink.symbol.CTypename(name);
            Simulink.symbol.Factory.createDialogAgent(out);
        end
        function out = newCStructType(~,name)
            out = Simulink.symbol.CStructType(name);
            Simulink.symbol.Factory.createDialogAgent(out);
        end
        function out = newCFunction(~,name,type)
            out = Simulink.symbol.CFunction(name,type);
            Simulink.symbol.Factory.createDialogAgent(out);
        end
    end
    methods (Access=private,Static)
        function createDialogAgent(var)
            var.DialogAgent = Simulink.SymbolVarDialog(var);
            var.DialogAgent.Obj = var;
        end
    end
end

