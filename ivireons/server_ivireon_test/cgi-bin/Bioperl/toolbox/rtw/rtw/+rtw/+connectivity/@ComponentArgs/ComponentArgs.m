classdef ComponentArgs < handle
%ComponentArgs provides parameters related to the model build 
%
%   An instance of this class is created by the target connectivity
%   infrastructure and is passed as a constructor argument to a user-defined
%   connectivity configuration. You can call the "get" methods of this class to
%   retrieve parameter values related to the model build. See the help on these
%   methods for more details: the method names are listed below.
%
%   ComponentArgs methods:
%       GETCOMPONENTPATH       - returns a path to the model component being 
%                                built
%       GETCOMPONENTCODEPATH   - returns a system path to the code generation 
%                                directory
%       GETCOMPONENTCODENAME   - returns the component name used for code
%                                generation
%       GETAPPLICATIONCODEPATH - returns a system path to the application 
%                                directory
%
%   See also RTW.MYPIL.CONNECTIVITYCONFIG

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $

    % private properties
    properties(SetAccess = 'private', GetAccess = 'private')        
        componentPath;
        componentCodePath;
        componentCodeName;
        applicationCodePath;
        InternalData;
        ModelName;
    end

    % constructor
    methods
        function this = ComponentArgs(componentPath, ...
                                      componentCodePath, ...
                                      componentCodeName, ...
                                      applicationCodePath)
            error(nargchk(4, 4, nargin, 'struct'));
            % store arguments
            this.componentPath = componentPath;
            this.componentCodePath = componentCodePath;
            this.componentCodeName = componentCodeName;
            this.applicationCodePath = applicationCodePath;
        end
    end

    % methods can't be overridden
    methods (Sealed = true)
        
        function modelName = getModelName(this)
            if isempty(this.ModelName);
                this.ModelName = strtok(this.getComponentPath,'/');
            end
            modelName = this.ModelName;
        end
                
        
        function componentPath = getComponentPath(this)
%GETCOMPONENTPATH returns a path to the model component being built
            error(nargchk(1, 1, nargin, 'struct'));
            componentPath = this.componentPath;
        end

        function componentCodePath = getComponentCodePath(this)
%GETCOMPONENTCODEPATH returns a system path to the code generation directory
            error(nargchk(1, 1, nargin, 'struct'));
            componentCodePath = this.componentCodePath;
        end

        function componentCodeName = getComponentCodeName(this)
%GETCOMPONENTCODENAME returns the component name used for code generation
            error(nargchk(1, 1, nargin, 'struct'));
            componentCodeName = this.componentCodeName;
        end

        function applicationCodePath = getApplicationCodePath(this)
%GETAPPLICATIONCODEPATH returns a system path to the application directory
            error(nargchk(1, 1, nargin, 'struct'));
            applicationCodePath = this.applicationCodePath;
        end
        
        function value = getParam(this, param)
            if ~isfield(this.getInternalData, 'configSet')
                % support for command line testing by e.g. end user                
                value = get_param(this.getModelName, param);
            else
                % rtw.pil.SILPILInterface will set the binfo.mat configSet
                value = get_param(this.getInternalData.configSet, param);                 
            end            
        end                        
        
        function setInternalData(this, internalData)
            error(nargchk(2, 2, nargin, 'struct'));
            this.InternalData = internalData;
        end
        
        function internalData = getInternalData(this)
            error(nargchk(1, 1, nargin, 'struct'));
            internalData = this.InternalData;
        end
    end
end
