classdef CompilerConfigurationFactory
%
    
% CompilerConfigurationFactory class is for creating CompilerConfigurations
%   CompilerConfigurationFactory is a class that creates
%   CompilerConfigurations and returns a set of them that satisfy the
%   inputs Lang, and List.
%
%   It has methods CompilerConfigurationFactory, the constructor and
%   process which returns a CompilerConfigurations.
%
%   See also MEX MEX.getCompilerConfigurations
%   MEX.CompilerConfigurationFactory.CompilerConfigurationFactory
%   MEX.CompilerConfigurationFactory.process

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/04/21 21:31:50 $
%% ----------------------------------
    properties(SetAccess = private, GetAccess = private)
        Lang                            % Set of languages that are requested.
        List                            % Grouping of configurations requested.
        % The following properties may need to be overridden in a subclass
        RootOfStorageLocation           % Directory where storage files can be found
        DefaultStorageFileName          % Name of default options file
        PotentialStorageFileNames       % Cell array of all options file
        PatternOfStorageSetupFileNames  % Pattern of options file
    end %properties

    
%% ----------------------------------
    methods(Access = public)
%% ----------------------------------
        function obj = CompilerConfigurationFactory(Lang,List)
        %
        
        % CompilerConfigurationFactory constructor
        %   CompilerConfigurationFactory(LANG,LIST) creates CompilerConfigurationFactory
        %   whose process method creates CompilerConfigurations.
        %
        %   The constructor initializes properties and validates inputs.
        %   See help for MEX.getCompilerConfigurations for more information
        %   on input arguments.
        %
        %   See also MEX MEX.getCompilerConfigurations
        %   MEX.CompilerConfigurationFactory
        %   MEX.CompilerConfigurationFactory.process 

            errStruct = struct('identifier','MATLAB:CompilerConfiguration:invalidLang',...
                               'message',['The first input must be a string with supported language, '...
                                          'either ''C'', ''CPP'', ''C++'', ''Fortran'', or ''Any''.']);
            if ~ischar(Lang)
                    error(errStruct);
            end

            switch lower(Lang)
                case 'any'
                    obj.Lang = {'C','C++','Fortran'};
                case 'c'
                    obj.Lang = {'C','C++'};
                case {'cpp','c++'}
                    obj.Lang = {'C++'};
                case 'fortran'
                    obj.Lang = {'Fortran'};
                otherwise
                    error(errStruct);
            end

            if ischar(List) && any(strcmpi(List,{'selected','installed','supported'}));
                obj.List = lower(List);
            else
                error('MATLAB:CompilerConfiguration:invalidList',...
                    'The second input, LIST, must be a string of value ''Selected'', ''Installed'', or ''Supported''.')
            end
            
            if ispc
                obj.RootOfStorageLocation = fullfile(matlabroot,'bin',computer('arch'),'mexopts');
                obj.DefaultStorageFileName = 'mexopts.bat';
                obj.PotentialStorageFileNames = {''};
                obj.PatternOfStorageSetupFileNames = '*opts.stp';
            else
                obj.RootOfStorageLocation = fullfile(matlabroot,'bin');
                obj.DefaultStorageFileName = 'mexopts.sh';
                obj.PotentialStorageFileNames = {'mexopts.sh','gccopts.sh'};
                obj.PatternOfStorageSetupFileNames = '';
            end
        end

%% ----------------------------------
        function aCompilerConfigurationArray = process(obj)
        % MEX.CompilerConfigurationFactory.process returns CompilerConfigurations
        %    The process method returns CompilerConfigurations for the Lang
        %    and List that were used to create the
        %    CompilerConfigurationFactory object.
        %
        %   See also MEX MEX.getCompilerConfigurations
        %   MEX.CompilerConfigurationFactory
        %   MEX.CompilerConfigurationFactory.CompilerConfigurationFactory 

            aCompilerConfigurationArray = [];
            
            storageLocations = identify(obj);

            for index = 1:length(storageLocations)

                rawTextFromStorage = fileread(storageLocations{index});
                
                basicStructArray = getBasicStructArray(obj, rawTextFromStorage, storageLocations{index});

                % getBasicStructArray returns an empty if storage doesn't
                % contain the requested Language, so short circuit the loop.
                if isempty(basicStructArray)
                     continue;
                end

                detailsStruct = getFullDetailsStruct(obj, rawTextFromStorage);

                newBasicStructArray = [];
                for numberOfLangs=1:length(basicStructArray)
                    basicStructArray(numberOfLangs).Location = determineLocation(obj, storageLocations{index}, basicStructArray, detailsStruct);
                    % If LIST is "Installed" but Location could not be determined, then don't add basicStructArray to array.
                    if ~(strcmp(obj.List,'installed') && isempty(basicStructArray(numberOfLangs).Location))
                        newBasicStructArray = [newBasicStructArray basicStructArray(numberOfLangs)];
                    end
                end

                detailsStructArray = populateDetailsStructArray(obj,detailsStruct,newBasicStructArray);
                tempCompilerConfigurationArray = package(obj,newBasicStructArray,detailsStructArray);
                aCompilerConfigurationArray = [aCompilerConfigurationArray tempCompilerConfigurationArray];

            end

        end
        
%% ----------------------------------
    end %methods public

    
%% ----------------------------------
    methods(Access = private, Sealed)
%% ----------------------------------
        function pathsToStorage = identify(obj)
            switch obj.List
                case 'selected'
                    pathsToStorage = {fullfile(pwd,obj.DefaultStorageFileName)};
                    
                    if ~exist(pathsToStorage{:},'file')
                        pathsToStorage = {fullfile(prefdir,obj.DefaultStorageFileName)};
                        
                        if ~exist(pathsToStorage{:},'file')
                            pathsToStorage = {fullfile(obj.RootOfStorageLocation,obj.DefaultStorageFileName)};
                        
                            if ~exist(pathsToStorage{:},'file')
                                error('MATLAB:CompilerConfiguration:NoSelectedOptionsFile',...
                                      'A ''Selected'' compiler was not found.  You may need to run mex -setup.')
                            end
                        end
                    end

                case {'supported','installed'}
                    if ispc
                        % Get list of options files that have STP files in RootOfStorageLocation
                        allSTPFiles = dir(fullfile(obj.RootOfStorageLocation,obj.PatternOfStorageSetupFileNames));
                        fullFileSTPFiles = cellfun(@(x)fullfile(obj.RootOfStorageLocation,x),...
                            {allSTPFiles.name},'UniformOutput',false);
                        pathsToStorage = regexprep(fullFileSTPFiles','\.stp','\.bat');
                    else
                        % Get list of options files from list in obj.PotentialStorageFileNames
                        pathsToStorage = cellfun(@(x)fullfile(obj.RootOfStorageLocation,x),...
                            obj.PotentialStorageFileNames,'UniformOutput',false);
                    end
            end
        end

%% ----------------------------------
        function basicStructArray = getBasicStructArray(obj, rawTextFromStorage, storageLocation)
            
            basicStructArray = [];
            
            if ~ispc
                %Get the section of the options for for the given architecture.
                rawTextFromStorage = regexp(rawTextFromStorage,[computer('arch') '(.*?)\;\;'],'match','once');
            end

            % Test for current storage type and warn otherwise.
            storageversionNumber = str2double(regexp(rawTextFromStorage,'\s*(?:rem|#)\s+StorageVersion: ([\d\.]+)','tokens','once'));
            if isempty(storageversionNumber) || storageversionNumber < 1.0
                warning('MATLAB:CompilerConfiguration:OldStyleStorage',...
                    ['The storage type used is an old style.  The following '...
                    'file is out of date:\n%s'], storageLocation);
                return
            elseif storageversionNumber > 1
                warning('MATLAB:CompilerConfiguration:storageTooNew',...
                    ['The storage type used is newer that the currently supported version.  The following '...
                    'file storage version does not match:\n%s'], storageLocation);
                return                
            end

            % Get KEYS and VALUES and put into an array for each language
            for numberOfLanguages = 1:length(obj.Lang)
                % The following regular expression is matching the following pattern:
                % a) A comment string, either rem or #.
                % b) A key of the form C++keyName, where Name is capture, for example.
                % c) A colon and then optionally a whitespace character that is not a NEWLINE or Carriage Return.
                % d) The value associate with the key which can be anything that is not a NEWLINE or Carriage Return.
                propsStruct = regexp(rawTextFromStorage,...
                    ['\s*(?:rem|#)\s+' regexptranslate('escape',obj.Lang{numberOfLanguages})...
                    'key(?<KEYS>\w*):(?:(?![\r\n])\s)*(?<VALUES>[^\r\n]*)'],'names');

                if ~isempty(propsStruct)
                    % Manipulate output of REGEXP into a structure
                    basicStructTemp = {propsStruct.KEYS; propsStruct.VALUES};
                    basicStruct = struct(basicStructTemp{:});

                    basicStructArray = [basicStructArray basicStruct];
                end
            end
        end

%% ----------------------------------
        function detailsStruct  = getFullDetailsStruct(obj, rawTextFromStorage) %#ok<MANU>
            if ispc
                detailsStructTemp = regexp(rawTextFromStorage,...
                    '(?<!rem )set (?<KEY>\w*)=(?<VALUE>[\w\S ]*)\r?\n+','names');
            else
                firstPart = regexp(rawTextFromStorage,'^.*case "\$Arch','match','once');
                archPart = regexp(rawTextFromStorage,[computer('arch') '\>(.*?);;'],'match','once');
                pattern = '(?<KEY>\w+)=([''"])?(?<VALUE>[^''"\r\n]+)(?(2)[''"])';
                firstPartStruct = regexp(firstPart,pattern,'names');
                archPartStruct = regexp(archPart,pattern,'names');
                detailsStructTemp = [firstPartStruct archPartStruct];
            end

            detailsStruct = expandEnvironmentVariables(detailsStructTemp);
        end
        
%% ----------------------------------
        function location = determineLocation(obj, storageLocation, basicStruct, detailStruct)
            
            if ~ispc
                location = '';
                return
            end
            
            locationPerlFile = fullfile(matlabroot,'toolbox','matlab','general','+mex','getCompilerPath.pl');

            if strcmp(obj.List,'selected')
                storageLocation = fullfile(obj.RootOfStorageLocation,lower(basicStruct.FileName));
                outputType = 'environmentVariable';
            else
                outputType = 'location';
            end
            
            if (ispc && strncmp(pwd,'\\',2)) % UNC path
                origPWD = cd('C:');
                goBackToOrigPWD = onCleanup(@()cd(origPWD));
            end
            
            [outputValue, success] = perl(locationPerlFile,'-matlabroot',matlabroot,...
                                          '-storageLocation',storageLocation,'-outputType',outputType);
            if success~=1
                error('MATLAB:CompilerConfigurationFactory:perlError',...
                    'Perl file erred finding compiler location with following message:\n%s', outputValue);
            end
            
            if strcmp(obj.List,'selected')
                location = detailStruct.(outputValue);
            else
                location = outputValue;
            end

        end 

%% ----------------------------------
    end %methods private

    
    methods(Access = protected)

%% ----------------------------------
        function aCompilerConfiguration = package(obj, basicStruct, detailStuct) %#ok<MANU>
        % This method will potentially be overridden to call a derivatives
        % of the CompilerConfiguration classes below. It is likely that
        % this method will be entirely replaced.
        
            aCompilerConfiguration = mex.CompilerConfiguration.empty(1,0);
        
            for numberOfLanguages = 1:length(basicStruct)
                ccDetails = mex.CompilerConfigurationDetails(detailStuct(numberOfLanguages));
                tempCompilerConfiguration = mex.CompilerConfiguration(basicStruct(numberOfLanguages),ccDetails);
                aCompilerConfiguration = [aCompilerConfiguration tempCompilerConfiguration];
            end
        end

%% ----------------------------------        
        function detailsStructArray = populateDetailsStructArray(obj, detailsStruct, basicStruct) %#ok<MANU>
        % This method will potentially be overridden to add additional
        % details properties.  It is likely that this parent method will
        % bee called first to have fields added to the work that it
        % does.  One might find the following line of code useful for
        % the purpose.
        % detailsStructArray = populateDetailsStructArray@mex.CompilerConfigurationFactory(obj, detailsStruct, basicStruct);

            detailsStructArray = [];

            for numberOfLanguages = 1:length(basicStruct)
                if ispc
                    detailsStructArray(numberOfLanguages).CompilerExecutable = detailsStruct.COMPILER;
                    detailsStructArray(numberOfLanguages).CompilerFlags = detailsStruct.COMPFLAGS;
                    detailsStructArray(numberOfLanguages).OptimizationFlags = detailsStruct.OPTIMFLAGS;
                    detailsStructArray(numberOfLanguages).DebugFlags = detailsStruct.DEBUGFLAGS;
                    detailsStructArray(numberOfLanguages).LinkerExecutable = detailsStruct.LINKER;
                    detailsStructArray(numberOfLanguages).LinkerFlags = detailsStruct.LINKFLAGS;
                    detailsStructArray(numberOfLanguages).LinkerOptimizationFlags = detailsStruct.LINKOPTIMFLAGS;
                    detailsStructArray(numberOfLanguages).LinkerDebugFlags = detailsStruct.LINKDEBUGFLAGS;
                elseif (isfield(basicStruct,'Language') && ~isempty(basicStruct(numberOfLanguages).Language))
                    switch basicStruct(numberOfLanguages).Language
                        case 'C'
                            detailsStructArray(numberOfLanguages).CompilerExecutable = detailsStruct.CC;
                            detailsStructArray(numberOfLanguages).CompilerFlags = detailsStruct.CFLAGS;
                            detailsStructArray(numberOfLanguages).OptimizationFlags = detailsStruct.COPTIMFLAGS;
                            detailsStructArray(numberOfLanguages).DebugFlags = detailsStruct.CDEBUGFLAGS;
                        case 'C++'
                            detailsStructArray(numberOfLanguages).CompilerExecutable = detailsStruct.CXX;
                            detailsStructArray(numberOfLanguages).CompilerFlags = detailsStruct.CXXFLAGS;
                            detailsStructArray(numberOfLanguages).OptimizationFlags = detailsStruct.CXXOPTIMFLAGS;
                            detailsStructArray(numberOfLanguages).DebugFlags = detailsStruct.CXXDEBUGFLAGS;
                        case 'Fortran'
                            detailsStructArray(numberOfLanguages).CompilerExecutable = detailsStruct.FC;
                            detailsStructArray(numberOfLanguages).CompilerFlags = detailsStruct.FFLAGS;
                            detailsStructArray(numberOfLanguages).OptimizationFlags = detailsStruct.FOPTIMFLAGS;
                            detailsStructArray(numberOfLanguages).DebugFlags = detailsStruct.FDEBUGFLAGS;
                    end
                    detailsStructArray(numberOfLanguages).LinkerExecutable = detailsStruct.LD;
                    detailsStructArray(numberOfLanguages).LinkerFlags = detailsStruct.LDFLAGS;
                    detailsStructArray(numberOfLanguages).LinkerOptimizationFlags = detailsStruct.LDOPTIMFLAGS;
                    detailsStructArray(numberOfLanguages).LinkerDebugFlags = detailsStruct.LDDEBUGFLAGS;
                end
            end
        end

%% ----------------------------------
    end %methods protected
    
end %classdef


%% ----------------------------------
% Helper functions (Private subfunctions)
%% ----------------------------------
function structOfExpandedVars = expandEnvironmentVariables(inputStruct)

structOfExpandedVars = struct;

for index = 1:length(inputStruct)
    if ~any(strcmp(inputStruct(index).KEY,fieldnames(structOfExpandedVars)))
        % This branch is that the field name has not been
        % encountered yet, then add the field.
        structOfExpandedVars.(inputStruct(index).KEY) = inputStruct(index).VALUE;
    else
        % If the field already exists in the structure, then
        % expand it and override the old value.
        envVarKey = regexptranslate('escape',inputStruct(index).KEY);
        oldEnvValue = regexptranslate('escape',structOfExpandedVars.(inputStruct(index).KEY));
        if ispc
            envVarPattern = ['%' envVarKey '%'];
        else
            envVarPattern = ['\$' envVarKey];
        end
        structOfExpandedVars.(inputStruct(index).KEY) = regexprep(inputStruct(index).VALUE,envVarPattern,oldEnvValue);
    end
end

end


