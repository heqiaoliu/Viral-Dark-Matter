
%   Copyright 2010 The MathWorks, Inc.

classdef CFileImport < Simulink.symbol.CFile
    %CFILEIMPORT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Transient)
        DirtyFlag = true
    end
    
    methods
        function obj = CFileImport(name)
            obj = obj@Simulink.symbol.CFile(name);
        end
        function out = getCParser(obj)
            out = getCParser@Simulink.symbol.CFile(obj);
            if ~isa(out.SymbolFactory,'Simulink.symbol.FactoryImport')
                out.SymbolFactory = Simulink.symbol.FactoryImport;
            end
        end
        function out = sortSymbols(~,symbols)
            out = symbols;
        end
        function importToWorkspace(obj)
            Simulink.symbol.CFileImport.importToWorkspaceWithPrompt(obj.getSymbols,true);
        end
        function setModifyListener(obj)
            symbols = obj.getSymbolsFromGroups;
            for k=1:length(symbols)
                symbols{k}.setModifyListener(@obj.modifyListener)
            end
        end
    end
    methods (Access=protected)
        function populateSymbols(obj)
            populateSymbols@Simulink.symbol.CFile(obj);
            % apply configuration rule after populating symbols
            obj.applyRule;
            obj.setModifyListener;
        end
        function modifyListener(obj,~,~)
            root = obj.getRoot;
            if ~isempty(root)
                root.setDirtyCB;
            end
        end
        function addCFileGroups(obj)
            % add only types and variables
            if isempty(obj.Groups)
                obj.addGroup(Simulink.symbol.SymbolGroup('Types',...
                    'Simulink.symbol.CTypename',...
                    Simulink.symbol.CTypename.getIconFullName));
                obj.addGroup(Simulink.symbol.SymbolGroup('Variables',...
                    'Simulink.symbol.CVariable',...
                    Simulink.symbol.CVariable.getIconFullName));
            end
        end
    end
    methods (Access=private)
        function out = getSymbolsFromGroups(obj)
            out = cellfun(@(x) x.Symbols.values,obj.Groups.values,'UniformOutput',false);
            out = [out{:}];
        end
    end
    methods
        % override refresh to preserve user input
        function refresh(obj)
            oldSymbols = obj.getSymbolsFromGroups;
            refresh@Simulink.symbol.CFile(obj);
            % now copy config
            for k=1:length(oldSymbols)
                groups = obj.Groups.values;
                for n=1:length(groups)
                    if groups{n}.Symbols.isKey(oldSymbols{k}.Name)
                        newSymbol = groups{n}.Symbols(oldSymbols{k}.Name);
                        newSymbol.copyConfig(oldSymbols{k});
                        break
                    end
                end
            end
        end
        function applyRule(obj)
            obj.defaultRule;
        end
        function defaultRule(obj)
            symbols = obj.getSymbolsFromGroups;
            if isempty(symbols), return, end
            slTypeMap = Simulink.symbol.CParser.getTypeSLMap;
            for k=1:length(symbols)
                s = symbols{k};
                s.Selected = true;
                if isempty(s.SimulinkDataType) && slTypeMap.isKey(s.Type)
                    s.SimulinkDataType = slTypeMap(strtok(s.Type,'[*'));
                end
                if isa(s,'Simulink.symbol.CStructType')
                    s.SimulinkClass = 'Simulink.Bus';
                elseif isa(s,'Simulink.symbol.CTypename')
                    s.SimulinkClass = 'Simulink.AliasType';
                elseif isa(s,'Simulink.symbol.CFunction')
                    % do nothing
                elseif ~isempty(s.Value)
                    s.SimulinkClass = 'Simulink.Parameter';
                else
                    s.SimulinkClass = 'Simulink.Signal';
                end
            end
        end
    end
    methods
        function out = getContextMenuImpl(obj,nodes,me,cm)
            callback = me.getActionCallbackName;

            am = DAStudio.ActionManager;
            cm = getContextMenuImpl@Simulink.symbol.CFile(obj,nodes,me,cm);
            if ~isempty(cm)
                cm.addSeparator;
            else
                cm = am.createPopupMenu(me);
            end            
            cm.addMenuItem(am.createAction(me,...
                'text',DAStudio.message('Simulink:utility:SIMenuImportToWorkspace'),...
                'icon','',...
                'callback',[callback '(''tree'',''importToWorkspaceCB'')']));
            out = cm;
        end
        function out = getChildren(obj)
            out = getChildren@Simulink.symbol.CFile(obj);
        end
        function out = getDisplayName(obj)
            if obj.DirtyFlag
                out = [obj.Name '*'];
            else
                out = obj.Name;
            end
        end
    end
    methods
        function out = importToWorkspaceCB(obj,varargin)
            if nargin > 1
                symbols = varargin{1};
            else
                symbols = obj.getSymbols;
            end
            Simulink.symbol.CFileImport.importToWorkspaceWithPrompt(...
                symbols,false);
            out = '';
        end
        function out = deleteCB(~,symbols)
            cellfun(@(x) x.setSelected(false),symbols);
            out = 'HierarchyChangedEvent';
        end
        function out = undeleteCB(~,symbols)
            cellfun(@(x) x.setSelected(true),symbols);
            out = 'HierarchyChangedEvent';
        end
    end
    methods (Static)
        function importToWorkspaceWithPrompt(symbols,dontAsk)
            count = 0;
            overwrite = false;
            for k=1:length(symbols)
                if ~symbols{k}.Selected, continue, end
                conflict = evalin('base',['exist(''' symbols{k}.Name ''',''var'')']);
                if conflict && ~dontAsk
                    buttonName = questdlg(...
                        DAStudio.message('Simulink:utility:SIOverwriteBatchPrompt',symbols{k}.Name),...
                        DAStudio.message('Simulink:utility:SITitle'),...
                        DAStudio.message('Simulink:utility:SIYes'),...
                        DAStudio.message('Simulink:utility:SIYesToAll'),...
                        DAStudio.message('Simulink:utility:SINo'),...
                        DAStudio.message('Simulink:utility:SINo'));
                    switch buttonName
                        case {DAStudio.message('Simulink:utility:SICancel'),''}
                            return
                        case DAStudio.message('Simulink:utility:SIYes')
                            overwrite = true;
                        case DAStudio.message('Simulink:utility:SIYesToAll')
                            overwrite = true;
                            dontAsk = true;
                        case DAStudio.message('Simulink:utility:SINo')
                            overwrite = false;
                        case DAStudio.message('Simulink:utility:SINoToAll')
                            overwrite = false;
                            dontAsk = true;
                    end
                end
                if ~conflict || overwrite == true
                    ret = symbols{k}.importToWorkspace;
                    if ret == true
                        count = count+1;
                    end
                end
            end
            if count == 0
                DAStudio.error('Simulink:utility:SINoSymbolSelected');
            end
        end
    end
end

