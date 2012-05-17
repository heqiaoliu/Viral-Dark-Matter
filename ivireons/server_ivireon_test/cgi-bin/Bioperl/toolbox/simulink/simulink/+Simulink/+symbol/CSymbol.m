
%   Copyright 2010 The MathWorks, Inc.

classdef CSymbol < Simulink.symbol.Symbol
    properties
        HeaderFile = ''
        Position
    end
    methods
        function obj = CSymbol(name)
            obj = obj@Simulink.symbol.Symbol(name);
        end
    end
    
    % dialog callback
    methods
        function out = getContextMenuImpl(~,nodes,me,cm)
            callback = me.getActionCallbackName;

            am = DAStudio.ActionManager;
            if isempty(cm)
                cm = am.createPopupMenu(me);
            end
            cm.addMenuItem(am.createAction(me,...
                'text','Navigate to Code...',...
                'icon','',...
                'enabled',Simulink.symbol.Object.getOnOff(isempty(nodes)),...
                'callback',[callback '(''list'',''navigateToCodeCB'')']));
            out = cm;
        end
    end
    
    % context menu callback
    methods
        function out = navigateToCodeCB(obj)
            opentoline(obj.Parent.Parent.getFullPath,obj.Position(1));
            out = '';
        end
        function out = propertiesCB(~)
            disp propertiesCB;
            out = '';
        end
    end
end
