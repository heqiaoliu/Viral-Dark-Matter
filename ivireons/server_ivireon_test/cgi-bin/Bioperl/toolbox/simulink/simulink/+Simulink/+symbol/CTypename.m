
%   Copyright 2010 The MathWorks, Inc.

classdef CTypename < Simulink.symbol.CSymbol
    methods
        function obj = CTypename(name)
            obj = obj@Simulink.symbol.CSymbol(name);
        end
    end
    methods (Static,Hidden)
        function out = getIconFullName
            out = [Simulink.symbol.Object.getIconPath ...
                   'diagviewer/warning_icon.gif'];
        end
    end
    methods
        function out = getPreferredProperties(obj)
            out = getPreferredProperties@Simulink.symbol.Symbol(obj);
            out = [out,'Type','Value'];
        end
    end
end
