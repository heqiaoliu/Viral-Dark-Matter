
%   Copyright 2010 The MathWorks, Inc.

classdef CFunction < Simulink.symbol.CSymbol
    properties
        Arguments = {}
    end
    methods
        function obj = CFunction(name,type)
            obj = obj@Simulink.symbol.CSymbol(name);
            obj.Type = type;
        end
        function setArgument(obj,idx,arg)
            obj.Arguments{idx} = arg;
        end
    end
    methods
        function out = getDialogAgent(obj)
            for k=1:length(obj.Arguments)
                % create DialogAgent of children upfront
                obj.Arguments{k}.getDialogAgent;
            end
            out = getDialogAgent@Simulink.symbol.CSymbol(obj);
        end
    end
    methods
        function out = getChildren(obj)
            out = obj.Arguments;
        end
        function out = getHierarchicalChildren(obj)
            out = obj.Arguments;
        end
    end
    methods (Static,Hidden)
        function out = getIconFullName
            out = [Simulink.symbol.Object.getIconPath ...
                   'Function.gif'];
        end
    end
end
