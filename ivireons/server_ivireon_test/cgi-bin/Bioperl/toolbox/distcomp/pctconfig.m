function varargout = pctconfig(varargin)
%PCTCONFIG configures a Parallel Computing Toolbox session.
%
%    CONFIG = PCTCONFIG() returns a struct, CONFIG, of the configuration 
%    property names and values.
%
%    CONFIG = PCTCONFIG('P1', V1, 'P2', V2,...) configures the properties 
%    of the Parallel Computing Toolbox which are passed as 
%    parameter/value pairs, P1, V1, P2, V2.  The parameter/value pairs can 
%    be specified as a cell array or a struct.  The function then returns a 
%    struct, CONFIG, of the configuration property names and values.
%  
%    If the property is 'portrange', the specified value is used to set the
%    range of ports to by used by the client session of the Parallel Computing Toolbox 
%    The value should either be a 2 element vector [minport, maxport]
%    or 0 to specify that the client session should use ephemeral ports.
%
%    If the property is 'hostname', the specified value is used to set the
%    hostname for the client session of the Parallel Computing Toolbox.
%
%    Note: The values set by this function do not persist between MATLAB
%    sessions.  To guarantee its effect, call pctconfig before calling any 
%    other Parallel Computing Toolbox functions.
%
%    Examples:
%    % Set client to use ports between 30000 and 30010
%    % and hostname 'fdm4'
%    pctconfig('portrange', [30000, 30010], 'hostname', 'fdm4');
%
%    % Set the client to use ephemeral ports 
%    pctconfig('portrange', 0);
 

% Copyright 2007-2010 The MathWorks, Inc.
  
    mlock;
    persistent stored_config;
    persistent stored_undoc;
    % obtain default configuration information
    if isempty(stored_config)
        stored_config = iSetDefaultValues();
        stored_undoc = iSetDefaultUndocValues();
    end
    try
        % if we don't have any input arguments, just return the current config
        if ~isempty(varargin)
            [params, values] = parallel.internal.convertToPVArrays(varargin{:});
            [params, values, pUndoc, vUndoc] = iGetUndocParams(params, values);
            if ~isempty(params)
                % check to make sure all arguments are valid properties
                [params, values] = iArgCheck(params, values, stored_config, stored_undoc);
                stored_config = iSetValues(stored_config, params, values);
            end
            if ~isempty(pUndoc)
                % check to make sure all arguments are valid properties
                [pUndoc, vUndoc] = iArgCheckUndoc(pUndoc, vUndoc);
                stored_undoc = iSetValues(stored_undoc, pUndoc, vUndoc);
            end
        end
    catch err
        rethrow(err);
    end
    varargout{1} = stored_config;
    if nargout > 1
        varargout{2} = stored_undoc;
    end
end


% Throws an error if any of the PV pairs don't match the ones that this function
% is expecting.
function [params, values] = iArgCheck(params, values, stored_config, stored_undoc)
    for i = 1:length(params)
        param = params{i};
        value = values{i};
        switch param
            case 'portrange'
                values{i} = iCheckValidPortRange(value);
            case 'hostname'
                values{i} = iCheckClientSessionHostname(value, stored_config, stored_undoc);
            case {'port', 'pmodeport'}
                    % These properties have been replaced by portrange.
                if iIsEphemeralPort(value)
                    portrange = value;
                else
                    portrange = [value, value+1000];
                end
                warning('distcomp:pctconfig:DeprecatedProperty', ...
                    ['Setting the "%s" property is deprecated and will be ',...
                    'removed in a future release. Please set the "portrange" ',...
                    'property instead.',...
                    '\nSetting "portrange" to [%s]'], ...
                    param, num2str(portrange));
                params{i} = 'portrange';
                values{i} = iCheckValidPortRange(portrange);
            otherwise
                error('distcomp:pctconfig:invalidPVPair', ...
                    ['unrecognized parameter: ' param]);
        end
    end
end

% creates a default configuration
function config = iSetDefaultValues()
    % create a new configuration struct
    config = struct('portrange', {}, 'hostname', {});
    config(1).portrange = [27370, 27470];
    try
        hostname = java.net.InetAddress.getLocalHost.getHostName;
        dotpos = hostname.indexOf('.');
        if dotpos > -1
            hostname = hostname.substring(0, dotpos);
        end
    catch e  %#ok<NASGU>
        hostname = 'localhost';
    end
    config(1).hostname = char(hostname);
end

% adds values to a configuration
function config = iSetValues(config, params, values)
    for i = 1:length(params)
        param = params{i};
        value = values{i};
        config.(param) = value;
    end
end

% Creates the default undocumented values.
function undoc = iSetDefaultUndocValues()
    undoc = struct('preservejobs', false, 'initclienthasrun', false);
end

% Separates the undocumented PV-pairs from the list of PV-pairs
function [params, values, pUndoc, vUndoc] = iGetUndocParams(params, values)
    allUndoc = {'preservejobs' 'initclienthasrun'};
    ind = ismember(params, allUndoc);
    pUndoc = params(ind);
    vUndoc = values(ind);
    params(ind) = [];
    values(ind) = [];
end

% Throws an error if any of the PV pairs don't match the undocumented PV pairs
% that this function is expecting.
function [pUndoc, vUndoc] = iArgCheckUndoc(pUndoc, vUndoc)
    for i = 1:length(pUndoc)
        param = pUndoc{i};
        value = vUndoc{i};
        switch param
            case 'preservejobs'
                if ~(isscalar(value) && islogical(value))
                    error('distcomp:pctconfig:invalidPVPair', ...
                          'preservejobs must be a logical value.');
                end
            case 'initclienthasrun'
                if ~(isscalar(value) && islogical(value))
                    error('distcomp:pctconfig:invalidPVPair', ...
                          'initclientrun must be a logical value.');
                end            
            otherwise
                error('distcomp:pctconfig:invalidPVPair', ...
                      ['unrecognized parameter: ' param]);
        end
    end
end

function value = iCheckClientSessionHostname(value, stored_config, stored_undoc)
% Check whether the input is a valid client session hostname.  Return the value
% that we are willing to assign it to.
    % Check that hostname is a 1xN char array
    if ~(ischar(value) && (size(value, 2) == numel(value)))
        error('distcomp:pctconfig:invalidPVPair', ...
              'hostname parameter must be a string');
    end
    if stored_undoc.initclienthasrun 
        currentHostname = stored_config.hostname;
        if ~strcmp(value, currentHostname) 
            % It's too late to change the hostname, so override what the user
            % requested.
            warning('distcomp:pctconfig:HostnameAlreadySet', ...
                ['Ignoring request to change client session hostname to %s.\n', ...
                'The client session is already using hostname %s, ', ...'
                'and will\ncontinue using that hostname for the duration ', ...
                'of this MATLAB session.'], value, currentHostname);
            value = currentHostname;
        end
    end
end

function value = iCheckValidPortRange(value)
    validPortRange = [1, intmax('uint16')];    
    
    if iIsValidPortRange(value, validPortRange)
        if isunix && value(1) < 1024
            warning('distcomp:pctconfig:UsingWellKnownPortNumber', ...
                ['Using a port number below 1024 often requires administrative ',...
                'privileges. Consider using a higher port number.']);
            
        end
    elseif iIsEphemeralPort(value)
        % ok
    else
        e = MException('distcomp:pctconfig:invalidPVPair', ...
                       ['"portrange" should be a vector [minPort, maxPort] where ', ...
                        'maxPort > minPort and both ports are between %d and %d,'], ...
                       validPortRange(1), validPortRange(2) );
        throwAsCaller(e);
    end
end

function valid = iIsValidPortRange(value, validRange)
    valid = isnumeric(value) && numel(value)==2 ...
            && iIsValidPort(value(1), validRange) ...
            && iIsValidPort(value(2), validRange) ...
            && value(2) > value(1);
end

function valid = iIsEphemeralPort(value)
    valid = isnumeric(value) && isscalar(value) && value == 0;
end

function valid = iIsValidPort(value, validRange)
    % Check that port is a 1x1 integer in the correct range.
    valid = isnumeric(value) && isscalar(value) ...
            && round(value) == value ...
            && value>=validRange(1) && value<=validRange(2);
end
