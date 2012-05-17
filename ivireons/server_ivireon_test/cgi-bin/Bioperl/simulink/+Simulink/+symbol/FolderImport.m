
%   Copyright 2010 The MathWorks, Inc.

classdef FolderImport < Simulink.symbol.Folder
    methods
        function obj = FolderImport(name,ext)
            obj =  obj@Simulink.symbol.Folder(name,ext);
        end
    end
    % factory
    methods
        function out = fileFactory(obj,filename,varargin)
            [~, ~, ext] = fileparts(filename);
            if any(strcmp(ext,{'.c','.cpp','.h','.hpp'}))
                out = Simulink.symbol.CFileImport(filename);
                return
            else
                [~, attrib] = fileattrib(filename);
                if attrib.directory == true
                    out = Simulink.symbol.FolderImport(filename,varargin{:});
                    return
                end
            end
            out = fileFactory@Simulink.symbol.Folder(obj,filename,varargin{:});
        end
    end
end