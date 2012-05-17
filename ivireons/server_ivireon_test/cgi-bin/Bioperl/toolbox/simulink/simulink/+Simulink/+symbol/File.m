
%   Copyright 2010 The MathWorks, Inc.

classdef File < Simulink.symbol.Object
    % FILE Base class for files containing symbols
    properties
        Folder = ''       % Folder to the file
        Ext = ''
        Groups = {}
        Populated = false
%         DependentFiles = {}
    end
    properties (Transient,Hidden)
        Root
        IsParsing
    end
    methods
        % constructor
        function obj = File(name)
            error(nargchk(0,1,nargin,'struct'));
            if nargin >= 1
                if ~ischar(name)
                    DAStudio.error('Simulink:utility:invalidArgType');
                end
                if ~exist(name,'file')
                    DAStudio.error('Simulink:utility:SEFileNotFound',name);
                end
                [~,attrib] = fileattrib(name); % get fullpath
                [obj.Folder basename obj.Ext] = fileparts(attrib.Name);
                obj.Name = [basename obj.Ext];
            end
            obj.Groups = containers.Map;
        end
        % get symbol
        function out = getAllSymbols(obj)
            if ~obj.Populated
                obj.populateSymbols;
                obj.Populated = true;
            end
            groups = obj.Groups.values;
            symbols = cell(1,length(groups));
            for k=1:length(groups)
                symbols{k} = groups{k}.getAllSymbols;
            end
            out = [symbols{:}];
        end
        function out = getSymbols(obj)
            if ~obj.Populated
                obj.populateSymbols;
                obj.Populated = true;
            end
            groups = obj.Groups.values;
            symbols = cell(1,length(groups));
            for k=1:length(groups)
                symbols{k} = groups{k}.getSymbols;
            end
            out = [symbols{:}];
        end
        function out = sortSymbols(~,symbols)
            out = symbols;
        end
        % get fullpath name
        function out = getFullPath(obj)
            out = fullfile(obj.Folder, obj.Name);
        end
        function out = getRoot(obj)
            if ~isa(obj.Root,'Simulink.symbol.Explorer')
                obj.Root = getRoot@Simulink.symbol.Object(obj);
            end
            out = obj.Root;
        end
        function cleanup(obj)
            cellfun(@(x) cleanup(x),obj.Groups.values);
            Simulink.symbol.File.cacheChildren(obj,[]);
        end
    end
    methods (Access=protected)
        function addSymbol(obj,symbol)
            group = obj.getGroup(symbol);
            group.addSymbol(symbol);
        end
        function clearSymbols(obj)
            cellfun(@(x) x.clearSymbols,obj.Groups.values);
        end
        function populateSymbols(obj)
            obj.IsParsing = true;
            symbols = parse(obj);
            obj.IsParsing = false;
            for k=1:length(symbols)
                obj.addSymbol(symbols{k});
            end
            Simulink.symbol.File.cacheChildren(obj,symbols);
        end
        function addGroup(obj,group)
            group.Parent = obj;
            obj.Groups(group.ClassName) = group;
        end
    end
    methods
        function out = getGroup(obj,~)  % second argument is symbol
            % this function is intended to be overriden
            if isempty(obj.Groups)
                obj.addGroup(Simulink.symbol.SymbolGroup(''));
            end
            out = obj.Groups('');
        end
    end
    methods (Abstract)
        % parse this file and return cell array of Symbols
        out = parse(obj)
    end
    methods
        function refresh(obj)
            obj.clearSymbols;
            obj.populateSymbols;
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
        function out = getContextMenuImpl(obj,~,me,cm)
            callback = me.getActionCallbackName;

            am = DAStudio.ActionManager;
            if isempty(cm)
                cm = am.createPopupMenu(me);
            end
            cm.addMenuItem(am.createAction(me,...
                'text','Navigate to File...',...
                'icon','',...
                'callback',[callback '(''tree'',''navigateToFileCB'')']));
            cm.addMenuItem(am.createAction(me,...
                'text','Refresh...',...
                'icon','',...
                'callback',[callback '(''tree'',''refreshCB'')']));
            % Delete File...
            cm.addMenuItem(am.createAction(me,...
                'text','Close File',...
                'icon','',...
                'enabled',num2str(~isempty(obj.Parent) && isempty(obj.Parent.Parent)),...
                'callback',[callback '(''menu_tree'',''deleteFileCB'')']));
            out = cm;
        end
        function out = getHierarchicalChildren(obj)
            out = obj.Groups.values;
        end
        function out = getDialogSchema(~,~)
            out = [];
        end
        function out = getDisplayLabel(obj)
            out = obj.Name;
        end
        function out = isHierarchical(~)
            out = true;
        end
    end
    methods (Static)
        function cacheChildren(obj,child)
            persistent cachedChild;
            if isempty(obj), cachedChild = []; return, end
            if isempty(child)
                if isfield(cachedChild,genvarname(obj.Name))
                    cachedChild = rmfield(cachedChild,genvarname(obj.Name));
                end
                return
            end
            dlg = cellfun(@(x) x.DialogAgent,child,'UniformOutput',false);
            cachedChild.(genvarname(obj.Name)) = [dlg{:}];
        end
    end
end
