classdef (Hidden = true) BuildHook < handle
%BUILDHOOK implements RTW build hooks
%
%
%   See also
%
%   This is an undocumented class. Its methods and properties are likely to
%   change without warning from one release to the next.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $

    properties (SetAccess=private, GetAccess=private)
        BuildEnvVarNames;
        BuildEnvValues;
        BuildEnvOrigValues;
        BuildPathPrepends;
        LaunchEnvVarNames;
        LaunchEnvValues;
        LaunchEnvOrigValues;
        ExcludedModels;
    end


    methods (Static, Access=public)
        
        function hook = getBuildHookForClass(model,className)
            hooks = rtw.pil.BuildHook.getBuildHooks(model);
            hook = [];
            for i=1:length(hooks)
                if strcmp(hooks(i).className,className)
                    % found matching build hook
                    hook=hooks(i);
                    break;
                end
            end
        end
        
        function checksum = getChecksum(model, hooks, topModel)
        % Returns a checksum based on constructor arguments for all 
        % build hooks that are not excluded for the current model

            checksum = sfprivate('md5',[]);

            for i=1:length(hooks)
                hook = hooks(i);

                if rtw.pil.BuildHook.isHookActive(hook, model, topModel)
                    checksum = sfprivate('md5',checksum, hook.className, ...
                        rtw.pil.BuildHook.getAllArgsForComponent(model, topModel, hook));
                end
            
            end
        end

        function dispatch(hookName, model, buildArgs, hooks, varargin)

            if strcmp(hookName,'entry')
                handles = [];
                % Ensure no handles are left from a previous build
                if bdIsLoaded(model) 
                    set_param(model, 'RTWBuildHookHandles',handles);
                end

                if ~isempty(hooks)
                    
                    % Check if code being re-generated for this model
                    rebuild= ~( ~isempty(buildArgs) && ...
                            isfield(buildArgs,'NoRebuild') && ...
                            buildArgs.NoRebuild==true);
                    
                    % Check if this is a referenced model running in SIL or
                    % PIL mode (i.e. the before/after target make and  on-
                    % target execution hook points will be called)
                    silPilMdlRefs = [buildArgs.SILModelReferences ...
                                     buildArgs.PILModelReferences];
                    isSilOrPilMdlRef=any(strcmp(model,...
                        get_param(silPilMdlRefs,'ModelName')));
                    
                    % Instantiate any hook classes for this model
                    if rebuild==true || isSilOrPilMdlRef
                        handles = rtw.pil.BuildHook.createHookClasses(...
                            hooks, model, buildArgs.TopOfBuildModel);
                    end
                end
                % If the handles are non-empty then it is safe to assume
                % that the model is already loaded
                if ~isempty(handles)
                    set_param(model, 'RTWBuildHookHandles',handles);
                end
            else 
                handles = get_param(model, 'RTWBuildHookHandles');
            end

            for i=1:length(handles)
                hookH = handles{i};

                % Call the appropriate hook method; if the build hook subclass does not
                % implement that method then the empty implementation in this class
                % is called
                feval(hookName, hookH, model, varargin{:});
            end
        end

        function cmds = writePcBuildEnvironmentCmds(cmdFileFid, model)
            cmds = '';

            if isempty(find_system(...
                'SearchDepth',0,...
                'Name',model,...
                'Type','block_diagram'))
                handles = [];
            else
                handles=get_param(model,'RTWBuildHookHandles');
            end

            for i=1:length(handles)
                hookH = handles{i};
                cmds = [cmds, ...
                        sprintf(['REM Start environment setup for build ' ...
                                 'hook %s\n'], ...
                                class(hookH))]; %#ok

                % Generate commands to set build environment variables
                envVarNames = hookH.BuildEnvVarNames;
                envVarValues = hookH.BuildEnvValues;
                for j=1:length(envVarNames);
                    cmds=[cmds,...
                          sprintf('SET %s=%s\n', envVarNames{j}, ...
                                  envVarValues{j})];%#ok
                end

                % Apply path prepends for build environment
                pathPrepends = hookH.BuildPathPrepends;
                pathPrependStr='';

                for j=1:length(pathPrepends);
                    pathPrependStr=['"' pathPrepends{j} '"' pathsep ...
                                    pathPrependStr]; %#ok
                end

                cmds = [cmds, ...
                        sprintf('SET PATH=%s%%PATH%%\n',pathPrependStr)]; %#ok

                cmds = [cmds, ...
                        sprintf(['REM End environment setup for build ' ...
                                 'hook %s\n'], ...
                                class(hookH))]; %#ok

            end
            if ~isempty(cmds)
                fprintf(cmdFileFid, '%s\n',cmds);
            end
        end

        function [allEnvVars] = getLaunchEnvironmentVars(model)
        % Get environment variables to configure the launch environment; these
        % environment variables are set immediately prior to launching the
        % target application; the original environment variable values are
        % restored after the application has been launched.
            
            handles=get_param(model,'RTWBuildHookHandles');
            allEnvVars = struct('name',{},'value',{});
            for i=1:length(handles)
                hookH = handles{i};

                % Generate commands to set launch environment variables
                envVarNames = hookH.LaunchEnvVarNames;
                envVarValues = hookH.LaunchEnvValues;
                if ~isempty(envVarNames)
                    hookEnvVars=struct('name',envVarNames,'value',envVarValues);
                    allEnvVars(end+1:end+length(hookEnvVars))=hookEnvVars;
                end
            end
        end

        function applyBuildEnvironment(model, verbose, dispHook)
        %APPLYBUILDENVIONMENT applies environment settings prior to model
        % build; it is must be called for non-Windows platforms only.
            if isempty(find_system(...
                'SearchDepth',0,...
                'Name',model,...
                'Type','block_diagram'))
                handles = [];
            else
                handles=get_param(model,'RTWBuildHookHandles');
            end

            for i=1:length(handles)
                hookH = handles{i};
                
                % Apply build environment variables
                envVarNames = hookH.BuildEnvVarNames;
                envVarValues = hookH.BuildEnvValues;
                origValues = hookH.applyEnvironmentVariables(verbose, dispHook, ...
                                                             envVarNames, ...
                                                             envVarValues);
                hookH.BuildEnvOrigValues = origValues;
                
                % Apply path prepends for build environment
                hookH.applyBuildPathPrepends(verbose, dispHook);
            end
        end

        function clearBuildEnvironment(model, verbose, dispHook)
        %CLEARBUILDENVIONMENT clears environment settings after model
        % build; it is effective for non-Windows platforms only.
            if ~ispc
                
                if isempty(find_system(...
                    'SearchDepth',0,...
                    'Name',model,...
                    'Type','block_diagram'))
                    handles = [];
                else
                    handles=get_param(model,'RTWBuildHookHandles');
                end
            
                for i=1:length(handles)
                    hookH = handles{i};

                    % Restore build environment variables
                    envVarNames = hookH.BuildEnvVarNames;
                    origValues = hookH.BuildEnvOrigValues;
                    hookH.clearEnvironmentVariables(verbose, dispHook, envVarNames,...
                                                    origValues);

                    % Remove path prepends
                    hookH.clearBuildPathPrepends(verbose, dispHook);
                end
            end
        end

        function enabled = isEnabled(model,hookClass)
            rtw.pil.BuildHook.checkClassExists(hookClass);
            hooks=rtw.pil.BuildHook.getBuildHooks(model);
            enabled=false;
            for i=1:length(hooks)
                hook = hooks(i);
                % Check if the class name matches
                if strcmp(hook.className,hookClass);
                    enabled=true;
                    break;
                end
            end
        end

        function setEnabled(model,hookClass, enabled)
            hooks=rtw.pil.BuildHook.getBuildHooks(model);
            if ~(strcmp(enabled,'on') || strcmp(enabled,'off'))
                DAStudio.error('Simulink:utility:invalidParameter',enabled);              
            end
            changed=false;
            for i=1:length(hooks)
                % Check if the class name matches
                if strcmp(hooks(i).className,hookClass);
                    if ~strcmp(hooks(i).enabled,enabled)
                        hooks(i).enabled=enabled;
                        changed=true;
                        break;
                    end
                end
            end
            if changed==true
                rtw.pil.BuildHook.setBuildHooks(model,hooks);
            end
        end

        function addHook(model, hookClass, varargin)
            rtw.pil.BuildHook.checkClassExists(hookClass);


            %default values
            argsAllComponents = [];
            argsTopModelOnly = [];
            excludedModels=[];
            includeTopModel='on';
            includeReferencedModels='on';
            enabled='on';
                
            N=length(varargin)/2;
            for i=1:N
                name  =varargin{i*2-1};
                value =varargin{i*2};
                
                switch lower(name)
                  case 'argsallcomponents'
                    argsAllComponents=value;
                  case 'argstopmodelonly'
                    argsTopModelOnly=value;
                  case 'excludedmodels';
                    excludedModels=value;
                  case 'includetopmodel'
                    includeTopModel=value;
                  case 'includereferencedmodels'
                    includeReferencedModels=value;
                  case 'enabled'
                    if ~(strcmp(value,'on') || strcmp(value,'off'))
                        DAStudio.error('Simulink:utility:invalidParameter',value);              
                    end
                    enabled=value;
                  otherwise
                    DAStudio.error('Simulink:utility:invalidParameter',name);              
                end
            end
            
            hooks=rtw.pil.BuildHook.getBuildHooks(model);
            idx_to_keep=logical(1:length(hooks));
            for i=1:length(hooks)
                if strcmp(hooks(i).className, hookClass)
                    % remove existing entry for this hook
                    idx_to_keep(i) = false;
                else
                    idx_to_keep(i) = true;
                end
            end
            hooks = hooks(idx_to_keep);
            hooks(end+1).className = hookClass;
            hooks(end).argsAllComponents = argsAllComponents;
            hooks(end).argsTopModelOnly = argsTopModelOnly;
            hooks(end).excludedModels = excludedModels;
            hooks(end).includeReferencedModels=includeReferencedModels;
            hooks(end).includeTopModel = includeTopModel;
            hooks(end).enabled = enabled;
            % Sort by class name so that re-ordering of hooks does not 
            % affect the checksum results
            [classNames{1:length(hooks)}] = deal(hooks.className);
            [~,idx] = sort(classNames);
            hooks=hooks(idx);
            rtw.pil.BuildHook.setBuildHooks(model,hooks);
        end

        function removeHook(model, hookClass)
            hooks=rtw.pil.BuildHook.getBuildHooks(model);
            idx_to_keep = logical(1:length(hooks));
            for i=1:length(hooks)
                if strcmp(hooks(i).className, hookClass)
                    % remove entry for this hook
                    idx_to_keep(i) = false;
                else
                    idx_to_keep(i) = true;
                end
            end
            hooks = hooks(idx_to_keep);
            if isempty(hooks)
                % Replace empty struct with plain regular array
                hooks=[]; 
            end
            % write update BuildHooks in base workspace
            rtw.pil.BuildHook.setBuildHooks(model,hooks);
        end
    end

    methods (Access = public)

        function error(varargin)
        % default implementation is empty
        end

        function entry(varargin)
        % default implementation is empty
        end

        function before_tlc(varargin)
        % default implementation is empty
        end

        function after_tlc(varargin)
        % default implementation is empty
        end

        function before_make(varargin)
        % default implementation is empty
        end

        function after_code_generation(varargin)
        % default implementation is empty
        end

        function after_make(varargin)
        % default implementation is empty
        end

        function exit(varargin)
        % default implementation is empty
        end

        function before_target_make(varargin)
        % The target application may (e.g. for PIL or SIL) be built separately from the
        % model's generated code; this hook point is invoked prior to building
        % the target application; default implementation is empty
        end

        function after_target_make(varargin)
        % default implementation is empty
        end

        function after_on_target_execution(varargin) % e.g. PIL simulation
        % default implementation is empty
        end

    end

    methods (Access=protected)
        
        function excludedMdls = getExcludedModels(this)
            excludedMdls = this.ExcludedModels;
        end

        function setBuildPathPrepends(this, pathPrepends)
            argCheck = iscellstr(pathPrepends);
            if ~argCheck
                rtw.pil.ProductInfo.error('pil', 'InvalidPathPrepends');
            end
            this.BuildPathPrepends = pathPrepends;
        end

        function setLaunchEnvironmentVariables(this, names, values)
            argCheck = ...
                iscellstr(names) && ...
                iscellstr(values) && ...
                length(names)==length(values);

            if ~argCheck
                rtw.pil.ProductInfo.error('pil', 'InvalidEnvVars');
            end
            this.LaunchEnvVarNames = names;
            this.LaunchEnvValues = values;
        end


        function setBuildEnvironmentVariables(this, names, values)
            argCheck = ...
                iscellstr(names) && ...
                iscellstr(values) && ...
                length(names)==length(values);

            if ~argCheck
                rtw.pil.ProductInfo.error('pil', 'InvalidEnvVars');
            end
            this.BuildEnvVarNames = names;
            this.BuildEnvValues = values;
        end
    end

    methods (Static, Access = private)

        function active = isHookActive(hook, model, topModel)
            
            excludeRefModels = ...
                isfield(hook,'includeReferencedModels') && ...
                strcmp(hook.includeReferencedModels,'off');
            excludeTopModel = ...
                isfield(hook,'includeTopModel') && ...
                strcmp(hook.includeTopModel,'off');
            
            if any(strcmp(hook.excludedModels, model)) || ...
                    (excludeRefModels && ~strcmp(model,topModel)) || ...
                    (excludeTopModel && strcmp(model,topModel) || ...
                    ~strcmp(hook.enabled,'on'))
                active = false;
            else
                active = true;
            end 
        end
        
        
        function allArgsForComponent = getAllArgsForComponent(model, topModel, hook)
            argsAllComponents={};
            argsThisComponent= {};
            
            if isfield(hook,'argsAllComponents') && ~isempty(hook.argsAllComponents)
                argsAllComponents = hook.argsAllComponents;
            end
            if strcmp(model, topModel)
                if isfield(hook,'argsTopModelOnly') && ~isempty(hook.argsTopModelOnly)
                    argsThisComponent = hook.argsTopModelOnly;
                end
            end

            allArgsForComponent = [argsAllComponents argsThisComponent];
        end
        
                    
        function hooks = getBuildHooks(model)
            hooks = get_param(model, 'RTWBuildHooks');
        end

        function setBuildHooks(model,hooks) 
            set_param(model,'RTWBuildHooks',hooks);
        end

        function handles = createHookClasses(hooks, model, topModel)
            handles = cell(size(hooks));
            for i=1:length(hooks)
                hook = hooks(i);
                
                if rtw.pil.BuildHook.isHookActive(hook, model, topModel)
                    hookClass = hook.className;
                    thisClass = mfilename('class');
                    allArgs = rtw.pil.BuildHook.getAllArgsForComponent(model, topModel, hook);
                    h = feval(hookClass,allArgs{:});
                    if ~isa(h, thisClass)
                        rtw.pil.ProductInfo.error('pil','IncorrectBuildHookClass', ...
                            hookClass, thisClass);
                    end    
                    if ~strcmp(get_param(model,'IsERTTarget'),'on')
                        if isa(h,'rtw.pil.CodeCoverage')
                            h='';
                        end
                    end
                else
                    h = '';
                end
                handles{i} = h;
            end
            % Remove any empty handles
            handles = handles(~strcmp(handles,''));
        end

        function checkClassExists(hookClass)
            thisClass = mfilename('class');
            if isempty(meta.class.fromName(hookClass))
                rtw.pil.ProductInfo.error('pil','MissingBuildHookClass', ...
                                          hookClass, thisClass);
            end
        end

    end

    methods (Access=private)

        function applyBuildPathPrepends(this, verbose, dispHook)
            pathPrepends = this.BuildPathPrepends;
            newpath = getenv('PATH');
            for i=1:length(pathPrepends)
                newpath = [ pathPrepends{i} pathsep newpath ]; %#ok
                if verbose==true
                    feval(dispHook{:},...
                          ['### Added directory ' pathPrepends{i} ' to the PATH']);
                end
            end
            setenv('PATH',newpath);
        end

        function clearBuildPathPrepends(this, verbose, dispHook)
            pathPrepends = this.BuildPathPrepends;
            newpath = getenv('PATH');
            % strip of previously added directories in reverse order
            for i=length(pathPrepends):-1:1
                strToRemove = [pathPrepends{i} pathsep];
                assert(1==strmatch(strToRemove, newpath),[...
                    'Cannot remove ' strToRemove ' from the PATH '...
                    'environment variable because it was not found '...
                    'at the beginning of the PATH, ' newpath]);
                newpath = newpath(1+length(strToRemove):end);
                if verbose==true
                    feval(dispHook{:},...
                          ['### Removed directory ' pathPrepends{i} ' from the PATH']);
                end
            end
            setenv('PATH',newpath);
        end


        function origValues = applyEnvironmentVariables(~, verbose, dispHook, ...
                                                        envVarNames, envVarValues)

            origValues = cell(size(envVarNames));
            for i=1:length(envVarNames)
                name = envVarNames{i};
                value = envVarValues{i};
                origValues{i} = getenv(name);
                if verbose==true
                    feval(dispHook{:},...
                          ['### Setting environment variable: ' name '=''' value '''']);
                end
                setenv(name, value);
            end
        end

        function clearEnvironmentVariables(~, verbose, dispHook,...
                                           envVarNames,...
                                           origValues)
            for i=1:length(envVarNames)
                name = envVarNames{i};
                value = origValues{i};
                if verbose==true
                    feval(dispHook{:},...
                          ['### Restoring original value of environment variable: ' name '=''' value '''' ]);
                end
                setenv(name, value);
            end
        end
    end

end
