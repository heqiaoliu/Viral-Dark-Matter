classdef CodeCoverage < handle
%CODECOVERAGE provides access to code coverage results 
%
%   This is an undocumented class. Its methods and properties are likely to
%   change without warning from one release to the next.

%   Copyright 2010 The MathWorks, Inc.

    properties (Access=private)
        Model;
        CodeGenFolder;
    end
    
    methods (Access=private, Static=true)
        
        function srcs = getCovSummaryData(covData)
            numSrcs = length(covData.srcs);
            preAlloc=cell(numSrcs,1);
            srcs = struct('srcPath',preAlloc,'cd_total',preAlloc,...
                          'cd_cov',preAlloc, 'cd_percent',preAlloc,...
                          'fn_total',preAlloc,'fn_cov',preAlloc,...
                          'fn_percent',preAlloc);
            for i=1:numSrcs
                src=covData.srcs(i);
                cd_cov=src.cd_cov;
                cd_total=src.cd_total;
                if cd_total~=0
                    cd_percent=cd_cov/cd_total*100;
                else
                    cd_percent=[];
                end
                fn_cov=src.fn_cov;
                fn_total=src.fn_total;
                if fn_total~=0
                    fn_percent=fn_cov/fn_total*100;
                else
                    fn_percent=[];
                end
                srcs(i).srcPath=src.srcPath;
                srcs(i).cd_total=cd_total;
                srcs(i).cd_cov=cd_cov;
                srcs(i).cd_percent=cd_percent;
                srcs(i).fn_total=fn_total;
                srcs(i).fn_cov=fn_cov;
                srcs(i).fn_percent=fn_percent;
            end
        end
    
    end

    methods (Access=public)
        
        function this = CodeCoverage(model)
            
            if nargin ~= 1
                DAStudio.error('RTW:codeCoverage:IncorrectNumberArgs');
            end

            if ~ischar(model)
                DAStudio.error('RTW:utility:invalidArgType','char array');
            end
            
            if (exist(model,'file') ~= 4) && ...
                    isempty(find_system('type','block_diagram','name',model))
                DAStudio.error('RTW:utility:invalidModel',model);
            end
                
            this.Model=model;
            
            bDirInfo = RTW.getBuildDir(model);
            rootFolder = bDirInfo.CodeGenFolder;
            this.CodeGenFolder=rootFolder;
            
        end
    
        function clearSharedUtilsCodeCoverage(this)

            % Get the coverage results file objects
            [~,~,covResultsFileShared] = this.getResultsFiles;

            if ~isempty(covResultsFileShared)
                if ~covResultsFileShared.checkSrcTimestamps...
                        (this.CodeGenFolder);
                    covResultsFileShared.deleteCovFile;
                else
                    covResultsFileShared.clear;
                    covResultsFileShared.save;
                end
            end
            
        end
        
        
        function clearCodeCoverage(this)

            % Get the coverage results file objects
            [covResultsFileTopModel, covResultsFileModelRef] = ...
                this.getResultsFiles;
            
            % Clear coverage data
            if ~isempty(covResultsFileTopModel)
                if ~covResultsFileTopModel.checkSrcTimestamps...
                        (this.CodeGenFolder);
                    covResultsFileTopModel.deleteCovFile;
                else
                    covResultsFileTopModel.clear;
                    covResultsFileTopModel.save;
                end
            end
            
            if ~isempty(covResultsFileModelRef)
                if ~covResultsFileModelRef.checkSrcTimestamps...
                        (this.CodeGenFolder);
                    covResultsFileModelRef.deleteCovFile;
                else
                    covResultsFileModelRef.clear;
                    covResultsFileModelRef.save;
                end
            end
            
        end

        
        function srcs = getCodeCoverage(this)
            
            srcs='';
            
            [covResultsFileTopModel, covResultsFileModelRef, ...
             covResultsFileShared] = this.getResultsFiles;
            
            
            includeModelRef=~isempty(covResultsFileModelRef);
            includeTopModel=~isempty(covResultsFileTopModel);
            includeSharedUtils=~isempty(covResultsFileShared);

            if includeTopModel
                if ~covResultsFileTopModel.checkSrcTimestamps...
                        (this.CodeGenFolder);
                    DAStudio.error('RTW:codeCoverage:TopModelCovDataInvalid',...
                                   this.Model);
                end
                covData=covResultsFileTopModel.getCovData;
                srcs = cov.CodeCoverage.getCovSummaryData(covData);
            end
            
            if includeModelRef
                if ~covResultsFileModelRef.checkSrcTimestamps...
                        (this.CodeGenFolder);
                    DAStudio.error('RTW:codeCoverage:ModelRefCovDataInvalid',...
                                   this.Model);
                end               
                covData=covResultsFileModelRef.getCovData;
                srcsModelRef = cov.CodeCoverage.getCovSummaryData(covData);
                if ~isempty(srcsModelRef)
                    if isempty(srcs)
                        srcs=srcsModelRef;
                    else
                        len=length(srcsModelRef);
                        srcs(end+1:end+len) = srcsModelRef;
                    end
                end                
            end
            
            if includeSharedUtils
                if ~covResultsFileShared.checkSrcTimestamps...
                        (this.CodeGenFolder);
                    DAStudio.error('RTW:codeCoverage:SharedCovDataInvalid');
                end
                covDataShared = covResultsFileShared.getCovData;
                srcsShared = cov.CodeCoverage.getCovSummaryData...
                    (covDataShared);
                if ~isempty(srcsShared)
                    if isempty(srcs)
                        srcs=srcsShared;
                    else
                        len=length(srcsShared);
                        srcs(end+1:end+len) = srcsShared;
                    end
                end
            end
            
            if isempty(srcs)
                DAStudio.error('RTW:codeCoverage:NoCoverageData',this.Model);
            end

            % Ensure column data
            srcs=srcs(:);
            
        end
    end
    
    methods (Access=private)
        
        function [buildDir, sharedUtilsDir] = getBuildDir(this, targetType) 
            
            model = this.Model;
            if isempty(model)
                model=new_system;
                model=get_param(model,'Name');
            end
            
            bDirInfo = RTW.getBuildDir(model);
            rootFolder = bDirInfo.CodeGenFolder;
            
            if strcmp(targetType, 'TopModel')
                buildDir=bDirInfo.BuildDirectory;
            else
                buildDir=fullfile(rootFolder,...
                                  bDirInfo.ModelRefRelativeBuildDir);
            end            
            
            sharedUtilsDir = fullfile(rootFolder,...
                                      'slprj','ert','_sharedutils');
        end
        
        function [covResultsFileTopModel, covResultsFileModelRef, ...
                  covResultsFileShared] = getResultsFiles(this)
            
            model = this.Model;

            % Get all build directories for related to this model
            bDirInfo = RTW.getBuildDir(model);
            rootFolder = bDirInfo.CodeGenFolder;
            buildDirTopModel=bDirInfo.BuildDirectory;
            buildDirModelRef=fullfile(rootFolder, ...
                                      bDirInfo.ModelRefRelativeBuildDir);
            sharedUtilsDir = fullfile(rootFolder,...
                                      'slprj','ert','_sharedutils');
            
            covResultsFileTopModel = ...
                cov.CoverageResultsFile(buildDirTopModel);
            covResultsFileModelRef = ...
                cov.CoverageResultsFile(buildDirModelRef);
            
            if covResultsFileTopModel.exists
                covResultsFileTopModel.load;
            else
                covResultsFileTopModel='';
            end

            if covResultsFileModelRef.exists
                covResultsFileModelRef.load;
            else
                covResultsFileModelRef='';
            end

            covResultsFileShared = ...
                cov.CoverageResultsFile(sharedUtilsDir);
            if covResultsFileShared.exists
                covResultsFileShared.load;
            else
                covResultsFileShared='';
            end
            
        end
        
        
    end
end
