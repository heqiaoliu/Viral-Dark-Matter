
%   Copyright 2010 The MathWorks, Inc.

classdef Explorer < Simulink.symbol.FileGroup
    properties (SetObservable,AbortSet)
        DialogTitle = ''
    end
    properties
        CParser
    end
    properties (Transient)
        FilterText = ''
        ShowAll = true
    end
    methods
        function obj = Explorer(files)
            obj.Name = 'Symbol Explorer';
            obj.DialogTitle = DAStudio.message('Simulink:utility:SETitle');
            if nargin >= 1
                obj.addFile(files);
            end
        end
        function out = getCParser(obj)
            if isempty(obj.CParser)
                obj.CParser = Simulink.symbol.CParser;
            end
            out = obj.CParser;
        end
        function out = getExplorerUI(~)
            out = Simulink.SymbolExplorer.getInstance;
        end
    end
    % dialog agent
    methods (Access=public,Hidden)
        function out = getDialogAgentClassName(~)
            out = 'Simulink.SymbolDialogBase';
        end
        function clearCache(obj)
            obj.cleanup;
            Simulink.symbol.File.cacheChildren([]);
        end
    end
    % dialog callbacks
    methods
        function dlgStruct = getDialogSchema(obj,~)
            widget.Type = 'text';
            widget.Name = DAStudio.message('Simulink:utility:SEDialogText');
            widget.RowSpan = [1 1];
            widget.ColSpan = [1 1];
            widget.Alignment = 2; % top left
            
            dlgStruct.DialogTitle = obj.DialogTitle;
            dlgStruct.Items = {widget};
            dlgStruct.LayoutGrid = [2 1];
            dlgStruct.RowStretch = [0 1];
        end
        function dialogCallback(obj,dlg,widgetTag,action)
            obj.CParser.dialogCallback(dlg,widgetTag,action);
        end
        function out = getContextMenuImpl(~,~,me,cm)
            callback = me.getActionCallbackName;
            am = DAStudio.ActionManager;
            if isempty(cm)
                cm = am.createPopupMenu(me);
            end
            cm.addMenuItem(am.createAction(me,...
                'text',DAStudio.message('Simulink:utility:SEMenuAddFile'),...
                'icon','',...
                'callback',[callback '(''tree'',''addFileCB'')']));
            out = cm;
        end
    end    
    methods (Static,Hidden)
        function out = getIconFullName
            out = [Simulink.symbol.Object.getIconPath ...
                   'SimulinkProject.png'];
        end
    end
    % explorer callback: show only dialog view
    methods
        function out = isShowListView(~)
            out = false;
        end
        function out = isShowDialogView(~)
            out = true;
        end
    end
    % convenience functions
    methods
        function out = getTitle(obj)
            out = obj.Name;
        end
    end
    % menu callbacks
    methods (Static=true)
        function out = getInstance
            out = Simulink.SymbolExplorer.getInstance;
        end
        function out = getCallbackName
            out = 'Simulink.SymbolExplorer.actionCallback';
        end
    end
    properties (Constant,Hidden)
        HierarchyChangedEvent = 'HierarchyChangedEvent'
        PropertyChangedEvent = 'PropertyChangedEvent'
    end
    methods
        function out = postCloseCB(obj)
            buttonName = questdlg(...
                DAStudio.message('Simulink:utility:SEExitPrompt'),...
                obj.DialogTitle,...
                DAStudio.message('Simulink:utility:SIOK'),...
                DAStudio.message('Simulink:utility:SICancel'),...
                DAStudio.message('Simulink:utility:SICancel'));
            out = strcmp(buttonName,DAStudio.message('Simulink:utility:SIOK'));
            if out == true
                obj.clearCache;
            end
        end
        function out = addFileCB(obj)
            out = addFileUI(obj,{{'*.c;*.cpp;*.h;*.hpp','C/C++ files'},...
                DAStudio.message('Simulink:utility:SEAddFilePrompt')});
        end
        function out = addFileUI(obj,prompt)
            out = '';
            [filename pathname] = uigetfile(prompt{:});
            if ischar(filename)
                if ~isempty(obj.findFile(fullfile(pathname,filename)))
                    DAStudio.error('Simulink:utility:SEFileAddedAlready');
                end
                fileObj = obj.fileFactory(fullfile(pathname,filename));
                obj.addFile(fileObj);
                out = obj.HierarchyChangedEvent;
            end
        end
        function out = addFolderCB(obj)
            pathname = uigetdir('',DAStudio.message('Simulink:utility:SEAddFolderPrompt'));
            if ischar(pathname) && isempty(obj.findFile(pathname))
                folderObj = obj.fileFactory(pathname);
                %folderObj.getDialogAgent;
                obj.addFile(folderObj);
            end
            out = obj.HierarchyChangedEvent;
        end
        function out = deleteFileCB(obj,file)
            obj.deleteFile(file);
            out = obj.HierarchyChangedEvent;
        end
        function out = filterCB(obj,widget)
            obj.FilterText = widget.getCurrentText;
            out = {obj.HierarchyChangedEvent,obj.PropertyChangedEvent};
        end
        function out = clearFilterCB(obj,widget)
            out = '';
            if ~isempty(obj.FilterText)
                out = {obj.HierarchyChangedEvent,obj.PropertyChangedEvent};
            end
            widget.setCurrentText('');
            obj.FilterText = '';
        end
    end
end
