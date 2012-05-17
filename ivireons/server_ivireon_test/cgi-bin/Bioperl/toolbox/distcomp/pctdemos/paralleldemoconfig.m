function config = paralleldemoconfig(varargin)
%PARALLELDEMOCONFIG Configure the demos in a Parallel Computing Toolbox 
%session.
%   CONFIG = PARALLELDEMOCONFIG() returns a struct, CONFIG, of the 
%   configuration property names and values.
%
%   CONFIG = PARALLELDEMOCONFIG('reset') resets the demo configuration to its 
%   default values and returns the resulting configuration.
%
%   CONFIG = PARALLELDEMOCONFIG('param1', value1, 'param2', value2,...) 
%   sets the named demo configuration properties to the specified values and 
%   returns the resulting configuration.  
%   The parameter/value pairs can be specified as a cell array or a struct.  
%   The function then returns a struct, CONFIG, of the configuration property 
%   names and values.
% 
%   PARALLELDEMOCONFIG PARAMETERS
%
%   NumTasks - The number of tasks to create 
%          [positive integer]
%   Difficulty - The normalized demo difficulty level [positive scalar]
%   NetworkDir - A directory on the shared file system that the demos can
%          use for sharing data between the client and the workers.  The 
%          directory is specified both as a Windows UNC path and as a UNIX  
%          directory.  
%          [A struct with the fields 'pc' and 'unix']
%
%   Examples:
%   Configure the demos to create 10 tasks:
%       paralleldemoconfig('NumTasks', 10);
%
%   See also defaultParallelConfig
    
%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/02/25 08:02:16 $
  
    mlock;
    persistent stored_config;
    % Obtain the default configuration information.
    if isempty(stored_config)
        stored_config = iSetDefaultValues();
    end
    if (numel(varargin) == 1 && ischar(varargin{1}) ...
        && strcmp(varargin{1}, 'reset'))
        stored_config = iSetDefaultValues();
        config = stored_config;
        return;
    end
    try
        % If we do not have any input arguments we only return the current 
        % config.
        if ~isempty(varargin)
            [properties, values] = convertToPVArrays(varargin{:});
            % Check to make sure all arguments are valid properties.
            iArgCheck(properties, values);
            stored_config = iSetValues(stored_config, properties, values);
        end
    catch err
        rethrow(err);
    end
    config = stored_config;
end % End of paralleldemoconfig.

function iArgCheck(params, values)
% Throw an error if any of the PV pairs do not match the ones that this 
% function is expecting.  The function uses a case-insensitive comparison to 
% validate the properties.
    tc = pTypeChecker();
    for i = 1:length(params)
        param = params{i};
        value = values{i};
        switch lower(param)
            case 'numtasks'
                % Check that number of tasks is an integer > 0.
                if ~tc.isIntegerScalar(value, 1, Inf)
                    error('distcomp:demo:InvalidArgument', ...
                          ['NumTasks parameter must an integer greater ' ...
                           'than 0']);
                end                  
          case 'networkdir'
                % Check that we have a struct with the fields 'pc' and 'unix'.
                if ~(tc.isStructWithFields(value, 'pc', 'unix')  ...
                     && iscellstr(struct2cell(value)))
                    error('distcomp:demo:InvalidArgument', ...
                          ['NetworkDir parameter must be a struct with ' ...
                           'the fieldnames pc and unix, and their ' ...
                           'values must be strings']);
                end
          case 'difficulty'
                % Check that we have a single real number > 0.
                if ~tc.isRealScalar(value, realmin, Inf)
                    error('distcomp:demo:InvalidArgument', ...
                          'difficulty parameter must be a scalar greater than 0');
                end
          otherwise
              error('distcomp:demo:InvalidArgument', ...
                    'unrecognized parameter:%s', param);
        end
    end
end % End of iArgCheck.


function config = iSetDefaultValues()
% Creates a default configuration
    numTasks = 'NumTasks';
    numTasksDefault = 4;
    
    networkDir = 'NetworkDir';
    networkDirDefault = struct('pc', '', 'unix', '');
    
    difficulty = 'Difficulty';
    difficultyDefault = 1;

    config = struct(numTasks, numTasksDefault,...
                    networkDir, networkDirDefault, ...
                    difficulty, difficultyDefault);
end % End of iSetDefaultValues.


function config = iSetValues(config, params, values)
% Add values to a configuration.  The property names must be valid fields in the
% config structure (modulo case), and the values must be valid property values.
    allFields = fieldnames(config);
    for i = 1:length(params)
        param = params{i};
        ind = strcmpi(param, allFields);
        currField = allFields{ind};
        config.(currField) = values{i};
    end
end % End of iSetValues.
