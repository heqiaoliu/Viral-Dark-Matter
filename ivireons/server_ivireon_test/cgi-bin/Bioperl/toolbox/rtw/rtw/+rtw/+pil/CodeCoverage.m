classdef (Hidden = true) CodeCoverage < rtw.pil.BuildHook
%CODECOVERAGE provides code coverage utilities
%   CODECOVERAGE
%
%   See also 
%
%   This is an undocumented class. Its methods and properties are likely to
%   change without warning from one release to the next.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $

    properties (Access=private)
        ToolPath;
        ToolName;
        ValidateToolInstallationFile;
    end
    
    methods (Static, Access=public)
        
        function codeCoverageClass = getActiveCodeCoverageClass...
                (hooks, topModelPILBuild)
            % Returns the name of the active code coverage class, or an empty string if no
            % code coverage is active

            codeCoverageClass='';
            
            for i=1:length(hooks)
                hook = hooks(i);
                h = feval(hook.className);
                if isa(h, 'rtw.pil.CodeCoverage')
                    
                    % Test if this is a Model block SIL or PIL simulation
                    % with code coverage for referenced models switched off
                    % (i.e. code coverage is effectively switched off)
                    modelBlockSilOrPilWithNoCodeCov = ...
                        ~topModelPILBuild && ...
                        strcmp(hook.includeReferencedModels,'off');
                    % Filter out arguments that should not affect the checksum
                    if strcmp(hook.enabled,'on') && ...
                            ~modelBlockSilOrPilWithNoCodeCov
                        codeCoverageClass = hook.className;
                    end
                end
            end
            
        end
        
        function checksum = getSharedUtilsChecksum(hooks, topModelPILBuild)
        % Returns a checksum based on constructor arguments for any build hook that is
        % identified as a code coverage class.  This checksum is used to
        % determine whether shared utility functions must be re-built.

            checksum = sfprivate('md5',[]);
            
            codeCoverageClass = rtw.pil.CodeCoverage.getActiveCodeCoverageClass...
                (hooks, topModelPILBuild);

            if ~isempty(codeCoverageClass)
                checksum = sfprivate('md5',checksum, codeCoverageClass);
            end
        end
    end
        
    methods (Access=public)
        
        function setToolPath(this, toolPath)
            toolName = this.ToolName;
            assert(~isempty(toolName), 'The code coverage tool must be specified');
            
            % If a non-empty path is specified then validate it
            prefGroup = ['CodeCoverage_' toolName];
            prefName = 'Path';
            if ~isempty(toolPath)
                this.validateToolPath(toolPath, toolName);
                setpref(prefGroup,prefName, toolPath);
            else
                if ispref(prefGroup, prefName)
                    rmpref(prefGroup, prefName);
                end
            end
            this.ToolPath = toolPath;
        end
        
        function toolPath = getToolAltPath(this)
        % Alternate form of path to handle spaces
            toolPath = RTW.transformPaths(...
                this.getToolPath,'pathType','alternate');
        end
        function toolPath = getToolPath(this)
            toolName = this.ToolName;
            assert(~isempty(toolName), 'The code coverage tool must be specified');
            if ~isempty(this.ToolPath)
                toolPath = this.ToolPath;
            else
                prefGroup = ['CodeCoverage_' toolName];
                if ispref(prefGroup,'Path')
                    toolPath = getpref(prefGroup,'Path');
                    this.validateToolPath(toolPath, toolName);
                    this.ToolPath = toolPath;
                else                
                    DAStudio.error('RTW:codeCoverage:toolPathNotSet',...
                                   toolName);
                end
            end
        end
    end
    
    methods (Access=protected)
        
        function setToolName(this, toolName)
            this.ToolName = toolName;
        end
        
        function setValidateToolInstallationFile(this, validateFile)
            this.ValidateToolInstallationFile=validateFile;
        end
        
    end

    
    methods (Access=private)
        
       function validateToolPath(this, toolPath, toolName)

           markerFile = this.ValidateToolInstallationFile;
           assert(~isempty(markerFile),...
                  ['A marker file must be specified to validate the '...
                   'coverage tool installation']);
           fullMarkerFilePath = fullfile(toolPath, markerFile);
           if ~exist(fullMarkerFilePath, 'file')
               DAStudio.error('RTW:codeCoverage:toolPathInvalid',...
                              toolPath, toolName, fullMarkerFilePath)
           end
       end
    
    end
    
end
