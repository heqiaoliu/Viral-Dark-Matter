classdef (Hidden = true) CoverageResultsFile < handle
%COVERAGERESULTSFILE manages access to the coverage results file
%
%   This is an undocumented class. Its methods and properties are likely to
%   change without warning from one release to the next.

%   Copyright 2010 The MathWorks, Inc.

    properties (GetAccess=private, Constant=true)
        TargetTypeValues={'TopModel','ModelReference'};
    end
    
    properties (GetAccess=private, SetAccess=private)
        CovDataFileName;
        CovData;
        BuildDir;
        CovFilePaths;
        CovFilesToDelete;
    end
    
    
    methods (Access=public)
        
        function valid = checkSrcTimestamps(this, codeGenFolder)
            
            oldDir = cd(codeGenFolder);
            c=onCleanup(@()cd(oldDir));
            
            valid=true;
            
            covData=this.CovData;
            srcPaths=cell(size(covData.srcs));
            [srcPaths{:}]=deal(covData.srcs.srcPath);
            timestamps=cell(size(covData.srcs));
            [timestamps{:}]=deal(covData.srcs.srcTimestamp);
            for i=1:length(srcPaths)
                srcPath=srcPaths{i};
                if exist(srcPath,'file')
                    d = dir(srcPath);
                    timestamp=d.datenum;
                    if timestamp ~= timestamps{i}
                        valid=false;
                        break;
                    end
                else
                    valid=false;
                    break;
                end
            end   
        end    
    
        function this = CoverageResultsFile(buildDir)
            
            covDataFile = fullfile(buildDir,'covData.mat');            
            this.CovDataFileName=covDataFile;
            this.BuildDir = buildDir;
            
        end
        
        function deleteCovFile(this)
            delete(this.CovDataFileName);
        end
        
        function addCovFilePath(this,covFilePath)
            if isempty(this.CovFilePaths)
                this.CovFilePaths={covFilePath};
            else
                this.CovFilePaths=union(this.CovFilePaths,covFilePath);
            end
        end
        
        function clearCovFilePaths(this)
            this.CovFilePaths='';
        end
        
        function covFilePaths = getCovFilePaths(this)
            covFilePaths = this.CovFilePaths;
        end
        
        function covDataFileExists = exists(this)
            covDataFileExists = (exist(this.CovDataFileName,'file')==2);
        end

        
        function covData = getCovData(this)
            covData = this.CovData;
        end
        
        function setCovData(this,covData)
            this.CovData = covData;
        end
        
        function load(this)

            data=load(this.CovDataFileName);
            this.CovData=data.componentCovData;   
            this.CovFilePaths=data.covFilePaths;
            
        end
        
        function clear(this)
            
            covData = this.CovData;
            for i=1:length(covData.srcs)
                for j=1:length(covData.srcs(i).probes)
                    kind=covData.srcs(i).probes(j).kind;
                    if ~strcmp(kind,'constant')
                        covData.srcs(i).probes(j).event='none';
                    end
                end
                covData.srcs(i).fn_cov=0;
                covData.srcs(i).cd_cov=0;
            end
            this.CovData = covData;
            
            this.CovFilesToDelete = this.CovFilePaths;
            
        end
        
        
        function save(this)
            componentCovData = this.CovData; %#ok
            covFilePaths = this.CovFilePaths; %#ok
            save(this.CovDataFileName,'componentCovData','covFilePaths');
            
            if ~isempty(this.CovFilesToDelete)
                for i=1:length(this.CovFilesToDelete)
                    dFile = fullfile(this.BuildDir, this.CovFilesToDelete{i});
                    if exist(dFile,'file')
                        delete(dFile)
                    end
                end
            end
        end
        
    end
end
