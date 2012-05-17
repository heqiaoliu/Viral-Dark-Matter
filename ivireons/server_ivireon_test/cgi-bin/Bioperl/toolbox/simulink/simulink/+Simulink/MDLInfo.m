classdef MDLInfo < handle
%Simulink.MDLInfo - Extracts information from an MDL file without loading
%                   the block diagram into memory.
% e.g.
%        info = Simulink.MDLInfo('mymodel');
%        description = info.Description
%        is_library = info.IsLibrary
%
% Static methods are provided for convenient access to individual
% properties:
%        description = Simulink.MDLInfo.getDescription('mymodel')
%        metadata = Simulink.MDLInfo.getMetadata('mymodel')
    
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/02/25 08:31:50 $

    properties (GetAccess='public', SetAccess='protected')
        % These are populated by the constructor.
        FileName = '';
        BlockDiagramName = '';
        % These are the same as the fields returned by sls_getmdlinfo.
        IsLibrary = false;
        SimulinkVersion = '';
        FileFormatMinorVersion = '';
        ModelVersion = '';
        Description = '';
        Metadata = [];
        Interface = [];
    end
    properties (GetAccess='private', SetAccess='protected')
        % Simulink does not currently produce XML model files.  This
        % property is always false and so is hidden.
        IsXML = false;
        % Internal flag indicating whether we should read the Metadata
        % property from the MDL file.  Passed to sls_getmdlinfo.  In the
        % interests of performance, we don't read this property if we don't
        % need to.
        GetMetadata = true;
        % Internal flag indicating whether we should read the
        % GraphicalInterface section from the MDL file.
        % Passed to sls_getmdlinfo.  In the interests of performance, we
        % don't read this informationif we don't need to.
        GetInterface = true;
    end

    methods (Access=public)

        % mdlname can be a block diagram name (e.g. vdp) or the file name
        % for a file on the MATLAB path (e.g. vdp.mdl), or a file name
        % relative to the current directory (e.g. mydir/mymodel.mdl) or a
        % a fully qualfied file name (e.g. C:\mydir\mymodel.mdl).
        % The second parameter is for internal use only and should be
        % omitted.
        function obj = MDLInfo(mdlname,getmetadata,getinterface)
            [obj.FileName,resolved] = sls_resolvename(mdlname);
            if ~resolved
                DAStudio.error('Simulink:util:MDLFileNotFound',mdlname);
            end
            assert(exist(obj.FileName,'file')~=0);
            % Extract the block diagram name
            [~,obj.BlockDiagramName] = fileparts(obj.FileName);
            if nargin>1
                obj.GetMetadata = getmetadata;
                if nargin>2
                    obj.GetInterface = getinterface;
                end
            end
            obj.getInfo();
        end

    end
    
    methods (Access='protected')
        % Reads the information from the MDL file and stores it in this
        % object.
        function getInfo(obj)
            opts = struct('GetMetadata',obj.GetMetadata,...
                'GetInterface',obj.GetInterface);
            info = sls_getmdlinfo(obj.FileName,opts);
            % Copy the fields of "info" to the fields of the same name in
            % this object.
            f = fieldnames(info);
            for i=1:numel(f)
                obj.(f{i}) = info.(f{i});
            end
        end
    end

    methods (Static)
        % Shorthand for retrieving just the Metadata parameter from the MDL
        % file.  The rules for "mdlname" are the same as for the
        % constructor of this class.
        function metadata = getMetadata(mdlname)
            obj = Simulink.MDLInfo(mdlname,true,false);
            metadata = obj.Metadata;
        end
        % Shorthand for retrieving just the Metadata parameter from the MDL
        % file.  The rules for "mdlname" are the same as for the
        % constructor of this class.
        function metadata = getInterface(mdlname)
            obj = Simulink.MDLInfo(mdlname,false,true);
            metadata = obj.Interface;
        end
        % Shorthand for retrieving just the Description parameter from the
        % MDL file.  The rules for "mdlname" are the same as for the
        % constructor of this class.
        function metadata = getDescription(mdlname)
            % Don't read the Metadata parameter from the file, to save
            % time.
            obj = Simulink.MDLInfo(mdlname,false,false);
            metadata = obj.Description;
        end
    end

end


