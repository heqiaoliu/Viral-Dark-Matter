
%   Copyright 2010 The MathWorks, Inc.

classdef CStructTypeImport < Simulink.symbol.CStructType & Simulink.symbol.Config
    %CVARIABLEIMPORT C struct type configured for import to Simulink
    
    methods
        function obj = CStructTypeImport(name)
            obj = obj@Simulink.symbol.CStructType(name);
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
            cm = getContextMenuImpl@Simulink.symbol.CStructType(obj,nodes,me,cm);
            out = getContextMenuImpl@Simulink.symbol.Config(obj,nodes,me,cm);
        end
        function out = getDisplayIcon(obj)
            out = getDisplayIcon@Simulink.symbol.Config(obj);
            if isempty(out), out = getDisplayIcon@Simulink.symbol.CStructType(obj); end
        end
        function out = getPreferredProperties(obj)
            out = [...
                getPreferredProperties@Simulink.symbol.CStructType(obj), ...
                getPreferredProperties@Simulink.symbol.Config(obj)];
        end
        function out = getPropAllowedValues(~,propName)
            out = {};
            switch propName
                case 'SimulinkClass'
                    out = {
                            ''
                            'Simulink.Bus'
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

