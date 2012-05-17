
%   Copyright 2010 The MathWorks, Inc.

classdef Object < handle
    %OBJECT Base class for symbols and files
    
    properties
        Name = ''
        Parent
    end
    % dialog agent: bridge to UDD
    properties (Transient,Hidden)
        DialogAgent
    end
    methods (Abstract,Hidden)
        out = getDialogAgentClassName(obj)
    end
    % Dialog callbacks
    methods
        function out = getCheckableProperty(~)
            out = '';
        end
        function out = getChildren(~)
            out = [];
        end
        function out = getHierarchicalChildren(~)
            out = [];
        end
        function dlgstruct = getDialogSchema(~, ~)
            dlgstruct = [];
        end
        function out = getDisplayIcon(obj)
            out = obj.getIconFullName;
        end
        function out = getDisplayLabel(obj)
            out = obj.Name;
        end
        function out = getPreferredProperties(~)
            out = {};
        end
        function out = isHierarchical(~)
            out = false;
        end
        function out = isEditableProperty(~,~)
            out = false;
        end
        function out = isReadonlyProperty(~,~)
            out = false;
        end
        function out = getPropAllowedValues(~,~)
            out = {};
        end
    end
    methods (Sealed)
        % client should implement context menu in getContextMenuImpl
        function out = getContextMenu(obj,nodes)
            me = obj.getME;
            if isempty(me), out = []; return, end
            cm = [];
            out = obj.getContextMenuImpl(nodes,me,cm);
        end
    end
    methods
        function out = getContextMenuImpl(~,~,~,~)
            out = [];
        end
        function out = isHidden(~)
            out = false;
        end
    end
    % helper functions
    methods
        function out = getRoot(obj)
            out = [];
            p = obj.Parent;
            while ~isempty(p)
                out = p;
                p = p.Parent;
            end
            if ~isa(out,'Simulink.symbol.Explorer')
                out = [];
            end
        end
        function out = getFile(obj)
            out = obj.Parent.Parent;
        end
    end
    methods (Access=private)
        function out = getME(obj)
            out = [];
            root = obj.getRoot;
            if isa(root,'Simulink.symbol.Explorer')
                out = root.getExplorerUI;
            end
        end
    end
    % callbacks from Explorer: configure if Explorer will show dialog view
    % and list view. By default shows both. Called whenever a node is
    % selected in the tree.
    methods
        function out = isShowDialogView(~)
            out = true;
        end
        function out = isShowListView(~)
            out = true;
        end
    end
    % helper functions
    methods (Static,Hidden)
        function out = getIconPath
            out = 'toolbox/shared/dastudio/resources/';
        end
        function out = getIconFullName
            out = '';
        end
        function out = getOnOff(val)
            if val
                out = 'on';
            else
                out = 'off';
            end
        end
    end
end

