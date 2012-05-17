classdef HelpContainerFactory
    % HELPCONTAINERFACTORY - factory class that creates HelpContainer
    % objects based on the input.
    %
    %
    % HELPOBJ = HELPUTILS.CONTAINERS.HELPCONTAINERFACTORY.CREATE(FILEPATH) returns a HelpContainerFactory
    % object that stores all the relevant help information related to the
    % M-file specified by FILEPATH.
    %
    % HELPOBJ = HELPUTILS.CONTAINERS.HELPCONTAINERFACTORY.CREATE(CLASSFILEPATH,
    % 'onlyLocalHelp', T/F)   If the flag onlyLocalHelp is set to TRUE, then
    % the created HELPCONTAINER object will contain the entire help
    % comments for all class members that meet the following requirements:
    %
    % Properties should not:
    %    - Have SetAccess and GetAccess attributes that are BOTH set to Private
    %    - Be inherited from any superclsses
    %
    % Methods must not be:
    %    - Hidden
    %    - Private
    %    - Defined in a superclass
    %    - Defined outside the classdef M-file
    %
    % By default, flag onlyLocalHelp is set to FALSE and the HELPCONTAINER
    % only stores the first line of help comments.
    %
    %
    % Remark:
    %   The onlyLocalHelp flag is ignored for M-files that are not MATLAB
    %   Class Object System class definitions.
    
    %    Copyright 2009 The MathWorks, Inc.
    methods (Static)
        function this = create(filePath, varargin)
            % CREATE - factory method that creates a helpContainer based on input filepath.
            % If the input file is a classdef M-file, then a CLASSHELPCONTAINER
            % is created, otherwise a FUNCTIONHELPCONTAINER is created.
            %
            % Examples
            %
            %   % Example 1: Create a HelpContainer for an M-function
            %
            % 	filePath = which('addpath.m');
            %	hC = helpUtils.containers.HelpContainerFactory.create(filePath);
            %
            %   % Example 2: Create a HelpContainer for a classdef M-file
            %
            % 	filePath = which('RandStream.m');
            %
            %	hC = helpUtils.containers.HelpContainerFactory.create(filePath, ...
            %                                               'onlyLocalHelp', true);
            %
            %   hC will not contain help information on properties/methods
            %   inherited from RandStream's superclass: the handle class
            %
            % NOTE:
            %   If the input M-file path is NOT on the MATLAB Path, then CREATE
            %   returns a FUNCTIONHELPCONTAINER irrespective of the nature of the
            %   M-file.
            if ~ischar(filePath)
                error('MATLAB:HelpContainerFactory:InvalidFilePath', ...
                    'File path must be a string');
            end
            
            % Check for onlyLocalHelp property pair
            p = inputParser;
            
            % p is case insensitive by default
            p.addParamValue('onlyLocalHelp', false, @islogical);
            
            p.parse(varargin{:});
            
            checkFilePath(filePath);
            
            metaInfo = getMetaInfo(filePath);
            
            if ~isempty(metaInfo) % filePath is a classdef M-file
                this = helpUtils.containers.ClassHelpContainer(filePath, ...
                    metaInfo, p.Results.onlyLocalHelp);
            else
                this = helpUtils.containers.FunctionHelpContainer(filePath);
            end
        end
    end
end

function checkFilePath(filePath)
    % CHECKFILEPATH - checks if input file path is valid
    pathStr = fileparts(filePath);
    
    if isempty(pathStr) || ~exist(filePath, 'file')
        error('MATLAB:HelpContainerFactory:InvalidFilePath', ...
            '%s must be the full path to an M-file on the MATLAB Search Path', filePath);
    end
    
end

function metaInfo = getMetaInfo(filePath)
    % GETMETAINFO - returns the meta.class information if FILEPATH
    % corresponds to a classdef M-file, otherwise it returns an empty
    % array.
    if helpUtils.isClassMFile(filePath)
        % True for both old and new MATLAB Class Object System
        qualifiedName = helpUtils.containers.getQualifiedFileName(filePath);
        
        % metaInfo is empty for old MATLAB Class Object System classes.
        metaInfo = meta.class.fromName(qualifiedName);
    else
        metaInfo = [];
    end
end
