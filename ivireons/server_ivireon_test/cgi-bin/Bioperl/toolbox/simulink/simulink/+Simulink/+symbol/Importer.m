
%   Copyright 2010 The MathWorks, Inc.

classdef Importer < Simulink.symbol.Explorer
    %IMPORTER Import symbols from C code to Simulink environment
    
    properties (Transient)
        DirtyFlag = false
    end
    properties (Transient,Hidden)
        SymbolDlg
        PreferencesDlg
    end
    properties (Access=private)
        SavedFile
    end
    
    methods
        function obj = Importer(files)
            obj = obj@Simulink.symbol.Explorer;
            if nargin >= 1
                obj.addFile(files);
                obj.setDirty;
            end
            obj.DialogTitle = DAStudio.message('Simulink:utility:SITitle');
            obj.Name = 'Untitled';
            obj.setModifyListener;
            obj.ShowAll = false;
        end
        function out = getCParser(obj)
            if isempty(obj.CParser)
                obj.CParser = Simulink.symbol.CParser;
                obj.CParser.SymbolFactory = Simulink.symbol.FactoryImport;
            end
            out = obj.CParser;
        end
        function out = getExplorerUI(~)
            out = Simulink.SymbolImporter.getInstance;
        end
        function out = fileFactory(~,filename)
            [~,~,ext] = fileparts(filename);
            %if any(strcmp(ext,{'.c','.h'}))
            if isdir(filename)
                out = Simulink.symbol.FolderImport(filename,{'.c','.cpp','.h','.hpp'});
                return
            end
            switch ext
                case {'.c','.cpp','.h','.hpp'}
                    out = Simulink.symbol.CFileImport(filename);
                otherwise
                    DAStudio.error('Simulink:utility:SIUnsupportedFileType',filename);
            end
        end
        function out = getTitle(obj)
            if obj.DirtyFlag == true
                dirty = '*';
            else
                dirty = '';
            end
            if ~isempty(obj.Name)
                delim = ' - ';
            else
                delim = '';
            end
            out = sprintf('%s%s%s%s',obj.DialogTitle,delim,...
                obj.Name,dirty);
        end
        function refreshTitle(obj)
            me = obj.getExplorerUI;
            me.title = obj.getTitle;
        end
        function setDirty(obj)
            obj.DirtyFlag = true;
        end
        function setModifyListener(obj)
            addlistener(obj,'Files','PostSet',@obj.setDirtyCB);
            for k=1:length(obj.Files)
                if isa(obj.Files{k},'Simulink.symbol.CFileImport')
                    obj.Files{k}.setModifyListener;
                end
            end
        end
    end
    % action callbacks
    methods
        % File menu callback
        function out = loadSessionCB(obj)
            ok = obj.postCloseCB;
            if ~ok, out = ''; return, end

            [filename pathname] = uigetfile( ...
                {'*.mat','MATLAB files'},...
                DAStudio.message('Simulink:utility:SILoadSessionPrompt'));
            if ~ischar(filename), out = ''; return, end
            
            x = load(fullfile(pathname,filename));
            if ~isa(x.obj,'Simulink.symbol.Importer')
                DAStudio.error('Simulink:utility:SIInvalidSessionFile',...
                    fullfile(pathname,filename));
            end
            me = obj.getExplorerUI;
            agent = me.getRoot;
            agent.Obj = x.obj;
            me.title = x.obj.getTitle;
            x.obj.setModifyListener;
            out = obj.HierarchyChangedEvent;
            delete(obj);
        end
        function out = saveSessionCB(obj,varargin)
            out = '';
            if isempty(obj.SavedFile) || (nargin > 1 && strcmp(varargin{1},'-saveas'))
                name = obj.Name;
                if isempty(name)
                    name = 'Untitled';
                end
                [filename pathname] = uiputfile( ...
                    {'*.mat','MATLAB files'},...
                    DAStudio.message('Simulink:utility:SISaveSessionPrompt'),...
                    [name '.mat']);
                if ~ischar(filename); return, end
                obj.SavedFile = fullfile(pathname,filename);
                [~, obj.Name] = fileparts(filename);
            end
            save(obj.SavedFile,'obj');
            obj.DirtyFlag = false;
            obj.refreshTitle;
            out = obj.HierarchyChangedEvent;
        end
        function out = saveSessionAsCB(obj)
            out = saveSessionCB(obj,'-saveas');
        end
        function out = closeSessionCB(obj)
            % save before close
            ok = obj.postCloseCB;
            if ~ok, out = ''; return, end
            
            out = obj.HierarchyChangedEvent;
            me = obj.getExplorerUI;
            agent = me.getRoot;
            agent.Obj = Simulink.symbol.Importer;
            me.title = agent.Obj.getTitle;
            obj.delete;
        end
        function out = preferencesCB(obj)
            if ~isa(obj.PreferencesDlg,'DAStudio.Dialog')
                obj.PreferencesDlg = DAStudio.Dialog(...
                    Simulink.SymbolDialogBase(obj.getCParser));
            end
            obj.PreferencesDlg.show;
            out = '';
        end
        % View menu callback
        function out = showDeselectedSymbolsCB(obj)
            %obj.ShowDeselectedSymbols = ~obj.ShowDeselectedSymbols;
            obj.ShowAll = ~obj.ShowAll;
            out = {obj.HierarchyChangedEvent, obj.PropertyChangedEvent};
        end
        % Tools menu callback
        function out = importToWorkspaceCB(obj)
            Simulink.symbol.CFileImport.importToWorkspaceWithPrompt(...
                obj.getSymbols,false);
            out = '';
        end
        function out = customizeRulesCB(~)
            out = '';
        end
        function out = applyRulesCB(~)
            out = '';
        end
        % Exit callback
        function out = postCloseCB(obj)
            if obj.DirtyFlag
                buttonName = questdlg(...
                    DAStudio.message('Simulink:utility:SICloseSessionPrompt'),...
                    obj.DialogTitle,...
                    DAStudio.message('Simulink:utility:SIYes'),...
                    DAStudio.message('Simulink:utility:SINo'),...
                    DAStudio.message('Simulink:utility:SICancel'),...
                    DAStudio.message('Simulink:utility:SICancel'));
                switch buttonName
                    case {DAStudio.message('Simulink:utility:SICancel'),''}
                        out = false; % do not close
                        return
                    case DAStudio.message('Simulink:utility:SIYes')
                        event = obj.saveSessionCB; 
                        % exit without close in case user cancel
                        if isempty(event), out = false; return, end
                end
            end
            % clean up popups
            if isa(obj.SymbolDlg,'DAStudio.Dialog')
                obj.SymbolDlg.delete;
            end
            if isa(obj.PreferencesDlg,'DAStudio.Dialog')
                obj.PreferencesDlg.delete;
            end
            obj.clearCache;
            out = true; % saved. now close
        end
        function setDirtyCB(obj,~,~)
            if obj.DirtyFlag == false
                obj.setDirty;
                obj.refreshTitle;
            end
        end
    end
end

