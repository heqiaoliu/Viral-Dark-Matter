
%   Copyright 2010 The MathWorks, Inc.

classdef Folder < Simulink.symbol.FileGroup
    properties
        Ext
        ParentFolder
    end
    methods
        function obj = Folder(name,ext)
            error(nargchk(1,2,nargin,'struct'));
            if ~exist(name,'dir')
                DAStudio.error('Simulink:utility:SEFileNotFound',name);
            end
            if nargin < 2
                obj.Ext = {'.c','.cpp','.h','.hpp'};
            elseif iscell(ext)
                obj.Ext = ext;
            else
                obj.Ext = {ext};
            end
            [obj.ParentFolder basename rest] = fileparts(name);
            if isempty(obj.ParentFolder)
                obj.ParentFolder = pwd; %fileparts(which(name));
            end
            obj.Name = [basename rest];
        end
        function out = getFullPath(obj)
            out = fullfile(obj.ParentFolder,obj.Name);
        end
        function out = getFiles(obj)
            if isempty(obj.Files)
                % get subfolders first
                allfiles = dir(obj.getFullPath);
                folders = allfiles([allfiles.isdir]);
                % filter out hidden files
                folders = folders(~strncmp({folders.name},'.',1));
                folderObjs = {};
                for k=1:length(folders)
                    fullname = fullfile(obj.getFullPath,folders(k).name);
                    % skip empty folder
                    if length(dir(fullname)) > 2 && ... % more than . folders
                        any(cellfun(@(x) ~isempty(dir(...
                        	fullfile(fullname,['*' x]))),obj.Ext))
                        f = obj.fileFactory(...
                            fullfile(obj.getFullPath,folders(k).name),obj.Ext);
                        f.Parent = obj;
                        folderObjs{end+1} = f; %#ok<AGROW>
                    end
                end
                obj.Files = folderObjs;
                % get files
                for k=1:length(allfiles)
                    if allfiles(k).isdir, continue, end
                    [~, ~, ext] = fileparts(allfiles(k).name);
                    if ~any(strcmp(ext,obj.Ext)), continue, end;
                    f = obj.fileFactory(fullfile(obj.getFullPath,allfiles(k).name));
                    f.Parent = obj;
                    obj.Files{end+1} = f;
                end
            end
            out = obj.Files;
        end
    end
    methods
        function out = getContextMenuImpl(obj,nodes,me,cm)
            callback = me.getActionCallbackName;

            am = DAStudio.ActionManager;
            if isempty(cm)
                cm = am.createPopupMenu(me);
            end
            % Delete File...
            cm.addMenuItem(am.createAction(me,...
                'text','Close Folder',...
                'icon','',...
                'enabled',num2str(~isempty(obj.Parent) && isempty(obj.Parent.Parent)),...
                'callback',[callback '(''menu_tree'',''deleteFileCB'')']));
            cm.addSeparator;
            cm.addMenuItem(am.createAction(me,...
                'text','Properties',...
                'icon','',...
                'enabled',num2str(isempty(nodes)),...
                'callback',[callback '(''tree'',''propertiesCB'')']));
            out = cm;
        end
        function out = getHierarchicalChildren(obj)
            obj.getFiles;
            % filter out empty folders
            %idx = cellfun(@(x) ~isa(x, 'Simulink.symbol.Folder') || ...
            %    isempty(x.Files), obj.Files);
            %out = obj.Files(idx);
            out = getHierarchicalChildren@Simulink.symbol.FileGroup(obj);
        end
    end
    methods (Static,Hidden)
        function out = getIconFullName
            out = 'toolbox/matlab/icons/foldericon.gif';
        end
    end
end
