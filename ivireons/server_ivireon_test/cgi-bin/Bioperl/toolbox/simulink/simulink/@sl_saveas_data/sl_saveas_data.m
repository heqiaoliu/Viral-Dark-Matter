classdef sl_saveas_data < handle
% Data in this object should only be accessed by helper functions on 
% on the sl_saveas object. 
%
% Any data checking and/or data compatibility should be done on the 
% sl_saveas object.

% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $
    properties (SetAccess = 'private',GetAccess = 'private')
        fileNames;
        modelNames;
        tempLib;
        tempMdl;
        successLvl;
    end
    
    properties(Constant)
        SIMPLE  = 0;
        REMOVED = 1;
        FAILED  = 2;
    end
    
    methods    
        function obj = sl_saveas_data
            obj.fileNames = {};
            obj.modelNames = {};
            obj.tempLib = '';
            obj.successLvl = sl_saveas_data.SIMPLE;
        end
        
        function destructor(o)
            clean_data(o);
        end

        function results = getSuccessLvl(obj)
            results = obj.successLvl;
        end
        
        function setSuccessLvlRemoved(obj)
            if obj.successLvl < sl_saveas_data.REMOVED
                obj.successLvl = sl_saveas_data.REMOVED;
            end
        end
        
        function setSuccessLvlFailed(obj)
            obj.successLvl = sl_saveas_data.FAILED;
        end
        
        % used by
        % sl_saveas.getTempLib(obj)
        function libName = get_temp_lib(o)
            libName = o.tempLib;
        end
        
        % used by
        % sl_saveas.getTempLib(obj)
        function set_temp_lib(o, tempLib)
            o.tempLib = tempLib;
            add_reference_model(o, tempLib);
        end
  
        %used by 
        %sl_saveas.getTempMdl(obj)
        function mdlName = get_temp_mdl(o)
            mdlName = o.tempMdl;
        end
        
        %used by 
        %sl_saveas.getTempMdl(obj)
        function set_temp_mdl(o, tempMdl)
            o.tempMdl = tempMdl;
            add_reference_model(o, tempMdl);
        end
        
        %used by
        % sl_saveas.addTempFile(obj)
        function new = add_temp_file(o, fileName)
            new = ~any(strcmp(fileName,o.fileNames));
            if new
                o.fileNames{end+1} = fileName;
            end
        end
        
        % used by
        % sl_saveas.openReferenceModel(obj)
        function new = add_reference_model(o, fileName)
            [~, fName] = fileparts(fileName);
            new = ~any(strcmp(fName,o.modelNames));
            if new
                o.modelNames{end+1} = fName;
            end
        end
           
        % cleanup functions
        function clean_data(o)
            close_reference_models(o);
            remove_files(o);
        end
        
        function close_reference_models(o)
            for i=1:length(o.modelNames)
                bdclose(o.modelNames{i});
            end
            o.modelNames = {};
            o.tempLib = '';
        end
        
        function remove_files(o)
            for i=1:length(o.fileNames)
                delete(o.fileNames{i});
            end
            o.fileNames = {};
        end
    end
end
