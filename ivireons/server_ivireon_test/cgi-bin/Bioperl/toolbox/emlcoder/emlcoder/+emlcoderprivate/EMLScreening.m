
%   Copyright 2009 The MathWorks, Inc.

classdef EMLScreening
    
    properties
        pVersion = '0.1';
        pMATLABVersion = '';
        pComputer = '';
        pFilename = '';
        pReportLocation = 1; % String or 1 or 2.
        pFcnInfo = {}; % Information about all directly and indirectly called functions.
        pUserFcns = {};
        ToolboxUsed = {};
        pUnsupportedEML = {};
        pSupportedEML = {};
        pScripts = {};
        pUnknownFileType = {};
        pNeedsEMLPragma = {};
        pUsesClass = false;
        pUsesFnHandle = false;
        pUsesCellArray = false;
        pUsesGlobal = false;
        pNestedFunctions = false;
        pMEXFile = false;
        pNrLines = 0;
        pObfuscate = false;
    end
    
    methods
        
        % Constructor initializes the object but does not do any analysis.      
        function obj = EMLScreening(filename,reportLocation, obfuscate)
            % Remove .m extension if it was passed in
            filename = regexprep(filename,'\.m','');
            obj.pFilename = filename;
            obj.pReportLocation = reportLocation;
            if strcmp(obfuscate,'-o')
                obj.pObfuscate = true;
            else
                obj.pObfuscate = false;
            end
            obj.pMATLABVersion = version('-release');
            obj.pComputer = computer;
        end
        
        function fid = open(obj)
            if ischar(obj.pReportLocation)
                fid = fopen(obj.pReportLocation,'w');
            else
                fid = obj.pReportLocation;
            end
        end
        
        function close(obj,fid)
           if ischar(obj.pReportLocation)
               fclose(fid);
           end
        end
    end
end