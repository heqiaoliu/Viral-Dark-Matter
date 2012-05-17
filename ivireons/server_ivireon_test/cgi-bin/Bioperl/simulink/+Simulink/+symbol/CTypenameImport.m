
%   Copyright 2010 The MathWorks, Inc.

classdef CTypenameImport < Simulink.symbol.CTypename & Simulink.symbol.Config
    %CTYPENAMEIMPORT C typedef configured for import to Simulink
    
    methods
        function obj = CTypenameImport(name)
            obj = obj@Simulink.symbol.CTypename(name);
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
            cm = getContextMenuImpl@Simulink.symbol.CTypename(obj,nodes,me,cm);
            out = getContextMenuImpl@Simulink.symbol.Config(obj,nodes,me,cm);
        end
        function out = getDisplayIcon(obj)
            out = getDisplayIcon@Simulink.symbol.Config(obj);
            if isempty(out), out = getDisplayIcon@Simulink.symbol.CTypename(obj); end
        end
        function out = getPreferredProperties(obj)
            out = [...
                getPreferredProperties@Simulink.symbol.CTypename(obj), ...
                getPreferredProperties@Simulink.symbol.Config(obj)];
        end
        function out = getPropAllowedValues(~,propName)
            out = {};
            switch propName
                case 'SimulinkClass'
                    out = {
                            ''
                            'Simulink.AliasType'
                            'Simulink.NumericType'
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

