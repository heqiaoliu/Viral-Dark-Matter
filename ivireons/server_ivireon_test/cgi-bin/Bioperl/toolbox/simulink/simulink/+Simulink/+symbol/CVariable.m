
%   Copyright 2010 The MathWorks, Inc.

classdef CVariable < Simulink.symbol.CSymbol
    properties
        Storage = ''
    end
    methods
        function obj = CVariable(name,type)
            obj = obj@Simulink.symbol.CSymbol(name);
            if ~ischar(type) && ~isa(type,'Simulink.symbol.CStructType')
                DAStudio.error('Simulink:utility:invalidArgType');
            end
            obj.Type = type;
        end
    end
    % dialog agent: to bridge MCOS to DAStudio.Explorer
    methods (Access=public,Hidden)
        function out = getDialogAgentClassName(~)
            out = 'Simulink.SymbolVarDialog';
        end
    end
    methods
        function out = getPreferredProperties(obj)
            out = getPreferredProperties@Simulink.symbol.Symbol(obj);
            out = [out,'Type','Value'];
        end
    end
    methods (Static,Hidden)
        function out = getIconFullName
            out = [Simulink.symbol.Object.getIconPath ...
                   'diagviewer/info_icon.gif'];
        end
    end
end
