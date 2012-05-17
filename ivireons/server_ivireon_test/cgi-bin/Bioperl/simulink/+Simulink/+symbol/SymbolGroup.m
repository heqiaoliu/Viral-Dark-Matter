
%   Copyright 2010 The MathWorks, Inc.

classdef SymbolGroup < Simulink.symbol.Object
    % SYMBOLGROUP Group of symbols
    properties
        Symbols = {}
        ClassName = ''
        Icon = ''
    end
    properties (Transient)
        Root
    end
    methods
        % constructor
        function obj = SymbolGroup(name,className,icon)
            error(nargchk(1,3,nargin,'struct'));
            obj.Name = name;
            if nargin > 1
                obj.ClassName = className;
            end
            if nargin > 2
                obj.Icon = icon;
            end
            obj.Symbols = containers.Map;
        end
        % get symbol
        function out = getAllSymbols(obj)
            out = obj.sortSymbols(obj.Symbols.values);
        end
        function out = getSymbols(obj)
            out = getAllSymbols(obj);
            root = obj.getRoot;
            if ~isempty(root)
                if ~root.ShowAll
                    idx = cellfun(@(x) x.isHidden,out);
                    out = out(~idx);
                end
                filter = lower(root.FilterText);
                if ~isempty(filter)
                    idx = cellfun(@(x) ~isempty(strfind(lower(x.Name),filter)),out);
                    out = out(idx);
                end
            end
        end
        function out = sortSymbols(~,symbols)
            out = symbols;
        end
        function out = getRoot(obj)
            if ~isa(obj.Root,'Simulink.symbol.Explorer')
                obj.Root = getRoot@Simulink.symbol.Object(obj);
            end
            out = obj.Root;
        end
        function cleanup(obj)
            if isa(obj.Symbols,'containers.Map')
                symbols = obj.Symbols.values;
                for k=1:length(symbols)
                    delete(symbols{k}.DialogAgent);
                    delete(symbols{k});
                end
            end
        end
    end
    methods
        function addSymbol(obj,symbol)
            % symbol must be an object of class Symbol
            if isempty(obj.Symbols)
                % use containers.Map.
                % @todo investigate performance
                obj.Symbols = containers.Map;
            end
            obj.Symbols(symbol.Name) = symbol;
            symbol.Parent = obj;
        end
        function clearSymbols(obj)
            if isa(obj.Symbols,'containers.Map')
                delete(obj.Symbols);
                obj.Symbols = containers.Map;
            end
        end
    end

    % dialog agent: to bridge MCOS to DAStudio.Explorer
    methods (Access=public,Hidden)
        function out = getDialogAgentClassName(~)
            out = 'Simulink.SymbolDialogBase';
        end
    end
    
    % dialog callbacks
    methods
        function out = getChildren(obj)
            out = obj.getSymbols;
        end
        function dlgStruct = getDialogSchema(obj,~)
            if ~obj.isShowDialogView, dlgStruct = []; return, end
            dlgStruct.DialogTitle = [obj.Parent.Name ' / ' obj.Name];
            num = length(obj.getChildren);
            widget.Type = 'text';
            if num == 0
                widget.Name = DAStudio.message('Simulink:utility:SENoSymbolFoundInGroup');
            else
                widget.Name = DAStudio.message('Simulink:utility:SESymbolFoundInGroup',num);
            end
            widget.Alignment = 2; % top left
            dlgStruct.Items = {widget};
        end
        function out = getDisplayLabel(obj)
            out = obj.Name;
        end
        function out = getDisplayIcon(obj)
            out = obj.Icon;
        end
        function out = isHierarchical(~)
            out = true;
        end
    end
end
