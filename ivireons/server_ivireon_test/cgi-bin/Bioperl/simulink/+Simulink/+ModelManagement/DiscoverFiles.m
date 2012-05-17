%DISCOVERFILES  Discover the dependent files for a given subset. Uses the
% Simulink Manifest Tools file dependency engine. 

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $

classdef DiscoverFiles < handle
    properties (GetAccess=private,SetAccess=private)
        % Files we start with:
        filesIn;
        % Files we discover, used as a temporary cache during analysis:
        filesFound;
        % Set of discovered design files, including filesIn:        
        designFiles;
        % Set of discovered derived files, including filesIn: 
        derivedFiles;
        % Set of discovered convenience files, including filesIn: 
        convenienceFiles;
        % Set of discovered artifact, including filesIn: 
        artifactFiles;
        % Missing, or wrongly-detected, files:
        missingFiles;
        % Remaining files that we do not know what to do with:
        unclassifiedFiles;        
    end
    
    methods (Access=public)
        % Constructor
        function obj = DiscoverFiles(filesIn)
            if ~iscell(filesIn)
                DAStudio.error('Simulink:utility:SLMM_DiscoverFiles_ExpectedCellArrayOfFilepaths')
            end
            obj.filesIn = filesIn;
            obj.derivedFiles = {};
            obj.designFiles = {};
            obj.convenienceFiles = {};
            obj.artifactFiles = {};
            obj.unclassifiedFiles = {};
            obj.missingFiles = {};
        end
        
        % ----------------------------------------------------------------
        function FindAll(obj)
            % Do Analysis
            obj.FindDependent;       
        end
        
        % ----------------------------------------------------------------
        function FindDependent(obj)
            opts = dependencies.AnalysisOptions.OptFileAnalysis;
            md = dependencies.ModelDependencies(opts);
            md.FilesForAnalysis = obj.filesIn;
            % Do the analysis:
            ds = md.Analyze('all');
            af = ds.getAllFiles();
            % Finding missing files is easy & cheap from FileStates:
            if ~isempty(af)
                missing = af( ~af.exist );
                if ~isempty(missing)
                    obj.missingFiles = missing.getFileNames;
                    af = af( af.exist );
                end
                if ~isempty(af)
                    af = af.getFileNames;                  
                else
                    % Replace empty handle with empty cell:
                    af = {};
                end
            end
            % Bin the files according to type:
            obj.SortFiles(af);
        end
        
        function SortFiles(obj, af)
            % Bin the files according to type:
            [~,~,ext] = cellfun(@fileparts, af, 'UniformOutput',false);
            ind = ones(size(af));            
            % Design files:
            designExt = {'.m'; '.mdl'; '.mat'; '.c'; '.h'; '.cpp'; '.hpp'};
            % Loop for now:
            ind = obj.pFilter(ind, af, ext, designExt, 'designFiles');
            
            % add all mexext ("mexext('all')") at some point:
            derivedExt = {mexext};
            ind = obj.pFilter(ind, af, ext, derivedExt, 'derivedFiles');
            
            % artifactFiles 
            artifactExt = {'.html','htm','.pdf','.doc','.docx'};
            ind = obj.pFilter(ind, af, ext, artifactExt, 'artifactFiles');

            % the rest:
            obj.unclassifiedFiles = af(~ind);            
        end
        
        
        
        % ----------------------------------------------------------------
        % Access methods:
        % ----------------------------------------------------------------
        function derivedFiles = GetDerivedFiles(obj)
            derivedFiles = obj.derivedFiles;
        end
        
        function designFiles = GetDesignFiles(obj)
            designFiles = obj.designFiles;
        end
        
        function convenienceFiles = GetConvenienceFiles(obj)
            convenienceFiles = obj.convenienceFiles;
        end        
        
        function artifactFiles = GetArtifactFiles(obj)
            artifactFiles = obj.artifactFiles;
        end
        
        function artifactFiles = GetUnclassifiedFiles(obj)
            artifactFiles = obj.artifactFiles;
        end
        
        function missingFiles = GetMissingFiles(obj)
            missingFiles = obj.missingFiles;
        end
        
        function files = GetAllFiles(obj)
            % All files EXCEPT missing:
            files = dependencies.cellcat( ...
                obj.derivedFiles, ...
                obj.designFiles, ...
                obj.convenienceFiles, ...
                obj.artifactFiles, ...
                obj.unclassifiedFiles ...
                );
        end      

    end
    
    % ---------------------------------------------------------------------
    methods(Access=private)
        function ind = pFilter(obj, ind, af, ext, filter, type)
            for jj=1:numel(filter);
                dfInd = strcmpi(ext, filter(jj));
                ind = ind & ~dfInd;
                obj.(type) = [obj.(type); af(dfInd)];
            end
        end
    end
     
    
end
