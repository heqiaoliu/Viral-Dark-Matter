
%   Copyright 2010 The MathWorks, Inc.

classdef CFile < Simulink.symbol.File
    properties (Hidden)
        ErrorMessage
        ParseTime
    end
    methods
        % constructor
        function obj = CFile(name)
            obj = obj@Simulink.symbol.File(name);
            obj.addCFileGroups;
        end
        function out = parse(obj)
            parser = obj.getCParser;
            out = parser.parse(obj.getFullPath);
            obj.ParseTime = now;
            obj.ErrorMessage = parser.LastMessage;
        end
        function out = getCParser(obj)
            root = obj.getRoot;
            if isa(root,'Simulink.symbol.Explorer')
                out = root.getCParser;
            else
                % default C parser
                out = Simulink.symbol.CParser;
            end
        end
        function out = sortSymbols(obj,symbols)
            out = obj.sortSymbolsByPosition(symbols);
        end
        function show(obj,varargin)
            opentoedit(obj.getFullPath,varargin{:});
        end
    end
    methods (Static)
        function out = sortSymbolsByPosition(symbols)
            pos = cellfun(@(x) x.Position(1),symbols);
            [~,idx] = sort(pos);
            out = symbols(idx);
        end
    end
    methods (Access=protected)
        function addCFileGroups(obj)
            if isempty(obj.Groups)
                obj.addGroup(Simulink.symbol.SymbolGroup('Functions',...
                    'Simulink.symbol.CFunction',...
                    Simulink.symbol.CFunction.getIconFullName));
                obj.addGroup(Simulink.symbol.SymbolGroup('Types',...
                    'Simulink.symbol.CTypename',...
                    Simulink.symbol.CTypename.getIconFullName));
                obj.addGroup(Simulink.symbol.SymbolGroup('Variables',...
                    'Simulink.symbol.CVariable',...
                    Simulink.symbol.CVariable.getIconFullName));
            end
        end
        function out = getTypeGroup(obj)
            out = obj.Groups('Simulink.symbol.CTypename');
        end
        function out = getVariableGroup(obj)
            out = obj.Groups('Simulink.symbol.CVariable');
        end
    end
    methods
        function out = getType(obj,typename)
            group = obj.getTypeGroup;
            out = [];
            if group.Symbols.isKey(typename)
                out = group.Symbols(typename);
            end
        end
        function out = getVariable(obj,varname)
            group = obj.getVariableGroup;
            out = [];
            if group.Symbols.isKey(varname)
                out = group.Symbols(varname);
            end
        end
        function out = getGroup(obj,symbol)
            if isa(symbol,'Simulink.symbol.CVariable')
                out = obj.Groups('Simulink.symbol.CVariable');
            elseif isa(symbol,'Simulink.symbol.CTypename')
                out = obj.Groups('Simulink.symbol.CTypename');
            elseif isa(symbol,'Simulink.symbol.CFunction')
                out = obj.Groups('Simulink.symbol.CFunction');
            end
        end
    end
    
    % dialog callbacks
    methods
        function out = getHierarchicalChildren(obj)
            out = getHierarchicalChildren@Simulink.symbol.File(obj);
        end
        function dlgstruct = getDialogSchema(obj,~)
            if ~obj.isShowDialogView, dlgstruct = []; return, end
            dlgstruct.DialogTitle = DAStudio.message(...
                'Simulink:utility:SESymbolExplorationResults',...
                datestr(obj.ParseTime));
            dlgstruct.Items = {};
            if ~isempty(obj.ErrorMessage)
                dlgstruct.Items = obj.getErrorMessageDialogWidget;
                if ~isempty(obj.getSymbols)
                    numSymbolsWidget = obj.getNumOfSymbolsDialogWidget;
                    dlgstruct.Items{end+1} = numSymbolsWidget;
                end
            else
                numSymbolsWidget = obj.getNumOfSymbolsDialogWidget;
                dlgstruct.Items{end+1} = numSymbolsWidget;
            end
        end
    end
    % helper functions for dialog
    methods (Access=private)
        function dlgstruct = getCodeViewDialogSchema(obj)
            item.Type = 'editarea';
            item.FilePath = obj.getFullPath;
            dlgstruct.DialogTitle = obj.Name;
            dlgstruct.Items         = {item};
        end
        function msgs = getErrorMessageDialogWidget(obj)
            msgs = cell(1,length(obj.ErrorMessage));
            for k=1:length(obj.ErrorMessage)
                msg.Type = 'text';
                msg.Alignment = 2; % top left
                msg.Name = [obj.ErrorMessage(k).kind ' - ' obj.ErrorMessage(k).desc ...
                    sprintf('\n') obj.ErrorMessage(k).detail];
                msg.FontFamily = 'Courier';
                msgs{k} = msg;
            end
        end
        function msg = getNumOfSymbolsDialogWidget(obj)
            msg.Type = 'text';
            msg.Alignment = 2; % top left
            num = length(obj.getAllSymbols());
            if num == 0
                msg.Name = DAStudio.message('Simulink:utility:SENoSymbolFound');
            else
                msg.Name = DAStudio.message('Simulink:utility:SESymbolFound',num);
                numAfterFilter = length(obj.getSymbols);
                if numAfterFilter ~= num
                    msg.Name = [msg.Name ' (' ...
                        DAStudio.message('Simulink:utility:SENumSymbolsAfterFilter',numAfterFilter) ...
                        ')'];
                end
            end
        end
    end
    methods (Static,Hidden)
        function out = getIconFullName
            out = [Simulink.symbol.Object.getIconPath ...
                   'document.png'];
        end
    end
    % action callbacks - called by Simulink.SymbolExplorer
    methods
        function out = isShowDialogView(~)
            out = true;
        end
        function out = navigateToFileCB(obj)
            out = '';
            edit(obj.getFullPath);
        end
        function out = refreshCB(obj)
            obj.refresh;
            out = {'HierarchyChangedEvent','PropertyChangedEvent'};
        end
    end
end
