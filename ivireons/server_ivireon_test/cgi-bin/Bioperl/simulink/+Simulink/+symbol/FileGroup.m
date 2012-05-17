
%   Copyright 2010 The MathWorks, Inc.

classdef FileGroup < Simulink.symbol.Object
    properties (SetObservable,AbortSet)
        Files = {}
    end
    methods
        function obj = FileGroup(name,files)
            if nargin >= 1
                obj.Name = name;
            end
            if nargin >= 2
                for k=1:length(files)
                    obj.addFile(files{k});
                end
            end
        end
        function addFile(obj,file)
            if ~iscell(file)
                file = {file};
            end
            for k=1:length(file)
                if ~isempty(obj.findFile(file{k}))
                    DAStudio.error('Simulink:utility:SEFileAddedAlready');
                end
            end
            for k=1:length(file)
                if isa(file{k},'Simulink.symbol.File') || isa(file{k},'Simulink.symbol.FileGroup')
                    obj.Files{end+1} = file{k};
                    file{k}.Parent = obj;
                else
                    f = obj.fileFactory(file{k});
                    obj.Files{end+1} = f;
                    f.Parent = obj;
                end
            end
        end
        function deleteFile(obj,file)
            [~, match] = obj.findFile(file);
            if any(match)
                obj.Files = obj.Files(~match);
            else
                if isa(file,'Simulink.symbol.File')
                    file = file.Name;
                end
                DAStudio.error('Simulink:utility:SEFileNotFound',file);
            end
        end
        function [out varargout] = findFile(obj,file)
            if ~ischar(file)
                file = file.Name;
            end
            [~, filename, ext] = fileparts(file);
            match = cellfun(@(x) strcmp(x.Name,[filename ext]),obj.Files);
            if nargout > 1
                varargout{1} = match;
            end
            out = obj.Files(match);
            if ~isempty(out)
                assert(length(out) == 1);
                out = out{1};
            end
        end
        function out = getSymbols(obj)
            symbols = cellfun(@(x) x.getSymbols,obj.Files,'UniformOutput',false);
            out = [symbols{:}];
        end
        function cleanup(obj)
            for k=1:length(obj.Files)
                obj.Files{k}.cleanup;
            end
        end
    end
    % dialog agent
    methods (Access=public,Hidden)
        function out = getDialogAgentClassName(~)
            out = 'Simulink.SymbolDialogBase';
        end
    end
    
    % factory
    methods
        function out = fileFactory(~,filename,varargin)
            [~, ~, ext] = fileparts(filename);
            if any(strcmp(ext,{'.c','.cpp','.h','.hpp'}))
                out = Simulink.symbol.CFile(filename);
            elseif strcmp(ext,'.mdl')
                out = Simulink.symbol.Model(filename);
            else
                if isdir(filename)
                    out = Simulink.symbol.Folder(filename,varargin{:});
                end
            end
        end
    end
    
    % dialog callbacks
    methods
        function out = getChildren(~)
            out = []; %obj.getSymbols;
        end
        function out = getDialogSchema(~,~)
            out = [];
        end
        function out = getDisplayLabel(obj)
            out = obj.Name;
        end
        function out = getDisplayName(obj)
            out = obj.getDisplayLabel;
        end
        function out = getHierarchicalChildren(obj)
            out = obj.Files;
        end
        function out = isHierarchical(~)
            out = true;
        end
    end    
    methods (Static,Hidden)
        function out = getIconFullName
            out = [Simulink.symbol.Object.getIconPath ...
                   'SimulinkProject.png'];
        end
    end
end
