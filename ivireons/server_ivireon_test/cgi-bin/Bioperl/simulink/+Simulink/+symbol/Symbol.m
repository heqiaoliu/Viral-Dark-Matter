
%   Copyright 2010 The MathWorks, Inc.

classdef Symbol < Simulink.symbol.Object
    % Symbol
    properties
        Type = ''
        Value
    end
    methods 
        function obj = Symbol(name)
            if ~ischar(name)
                DAStudio.error('Simulink:utility:invalidArgType');
            end
            if isempty(name), name = ''; end
            obj.Name = name;
        end
    end
    % dialog agent: to bridge MCOS to DAStudio.Explorer
    methods (Hidden)
        function out = getDialogAgentClassName(~)
            out = 'Simulink.SymbolDialog';
        end
    end
    % Dialog callbacks
    methods
        function out = getPreferredProperties(~)
            out = {'Name'};
        end
    end
    methods (Static,Hidden)
        function out = getIconFullName
            out = [Simulink.symbol.Object.getIconPath ...
                   'diagviewer/info_icon.gif'];
        end
    end
end
