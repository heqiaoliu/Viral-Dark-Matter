
%   Copyright 2010 The MathWorks, Inc.

classdef CVariableImport < Simulink.symbol.CVariable & Simulink.symbol.Config
    %CVARIABLEIMPORT C variable configured for import to Simulink
    
    methods
        function obj = CVariableImport(name,type)
            obj = obj@Simulink.symbol.CVariable(name,type);
        end
    end
    methods
        function out = getDialogAgentClassName(obj)
            out = getDialogAgentClassName@Simulink.symbol.Config(obj);
        end
    end
    methods
        function out = getCheckableProperty(obj)
            out = getCheckableProperty@Simulink.symbol.Config(obj);
        end
        function out = getContextMenuImpl(obj,nodes,me,cm)
            cm = getContextMenuImpl@Simulink.symbol.CVariable(obj,nodes,me,cm);
            out = getContextMenuImpl@Simulink.symbol.Config(obj,nodes,me,cm);
        end
        function out = getDisplayIcon(obj)
            out = getDisplayIcon@Simulink.symbol.Config(obj);
            if isempty(out), out = getDisplayIcon@Simulink.symbol.CVariable(obj); end
        end
        function out = getPreferredProperties(obj)
            out = [...
                getPreferredProperties@Simulink.symbol.CVariable(obj), ...
                getPreferredProperties@Simulink.symbol.Config(obj)];
        end
        function out = getPropAllowedValues(~,propName)
            out = {};
            switch propName
                case 'SimulinkClass'
                    out = {
                            ''
                            'Simulink.Parameter'
                            'Simulink.Signal'
                            };
            end
        end
        function out = isEditableProperty(obj,propName)
            out = isEditableProperty@Simulink.symbol.Config(obj,propName);
        end
        function out = isReadonlyProperty(obj,propName)
            out = isReadonlyProperty@Simulink.symbol.Config(obj,propName);
        end
    end
    methods
        function out = isHidden(obj)
            out = isHidden@Simulink.symbol.Config(obj);
        end
    end
end

