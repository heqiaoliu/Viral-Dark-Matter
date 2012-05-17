function varargout = target_code_flags(method,target,varargin)
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.4.2.7 $  $Date: 2008/12/01 08:08:16 $
result = [];

switch(method)
case 'get'
    if(length(varargin)>=1)
        flagNames = varargin{1};
        result = get_target_code_flags(target,flagNames);
    else
        result = target_methods('codeflags',target);
    end
    varargout{1} = result;
case 'set'
    if(length(varargin)==2)
        flagNames = varargin{1};
        flagValues = varargin{2};
        set_target_code_flags(target,flagNames,flagValues);
    elseif(length(varargin)==1 && ...
            isstruct(varargin{1}) &&...
            isfield(varargin{1},'name') &&...
            isfield(varargin{1},'value'))
        % better be a struct array of flags
        set_target_code_flags_kernel(target,varargin{1});
    else
        error('Stateflow:UnexpectedError','target_code_flags(''set'') called with wrong arguments');
    end
case 'fill'
    result = fill_target_code_flag_values(target,varargin{1});
    varargout{1} = result;
case 'reset'
    reset_code_flags(target);
otherwise,
    error('Stateflow:UnexpectedError','Unknown method %s passed to target_code_flags',method);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flagValues = get_target_code_flags(target,flagNames)

flagValues = {};
if(ischar(flagNames))
    flagNames = {flagNames};
end

flags = target_methods('codeflags',target);
if(~isempty(flags))
    existingFlagNames = {flags.name};
else
    existingFlagNames = {};
end

for i=1:length(flagNames)
    index = find(strcmp(existingFlagNames,flagNames{i}));
    if(~isempty(index))
        flagValues{i} = flags(index(1)).value;
    else
        flagValues{i} = 0;
    end
end

if length(flagValues) == 1
    % For sigleton, return the direct flag value rather than cellarray
    flagValues = flagValues{1};
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flags = fill_target_code_flag_values(target,flags)

str = get_target_props(target,'.codeFlags');
existingFlags = tokenize_code_flags(str);
if(~isempty(existingFlags))
    existingFlagNames = {existingFlags.name};
else
    existingFlagNames = [];
end
for i=1:length(flags)
    index = find(strcmp(existingFlagNames,flags(i).name));
    if(~isempty(index))
        flags(i).value = existingFlags(index(1)).value;
    else
        flags(i).value = flags(i).defaultValue;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function set_target_code_flags_kernel(target,flags)
str = get_target_props(target,'.codeFlags');
newStr = kotenize_code_flags(flags);

if(~strcmp(str,newStr))
    % set it only if necessary
    set_target_props(target,'.codeFlags',newStr);
    if sf('get',target,'target.simulationTarget')
        machineId = sf('get',target,'target.machine');
        eml_man('notify_options',machineId);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function set_target_code_flags(target,flagNames,flagValues)

if(ischar(flagNames))
    flagNames = {flagNames};
end

numFlags = length(flagNames);

if ~iscell(flagValues)
    % For backward compatibility, flagValues was numeric vector
    fvs = {};
    for i = 1:numFlags
        fvs{i} = flagValues(i);
    end
    flagValues = fvs;
end

flags = target_methods('codeflags',target);

if(~isempty(flags))
    existingFlagNames = {flags.name};
else
    existingFlagNames = {};
end
for i=1:numFlags
    index = find(strcmp(existingFlagNames,flagNames{i}));
    if(~isempty(index))
        flags(index(1)).value = flagValues{i};
    else
        flags(end+1).name = flagNames{i};
        flags(end).value = flagValues{i};
    end
end

set_target_code_flags_kernel(target,flags);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function reset_code_flags(target)

str = get_target_props(target,'.codeFlags');

flags = tokenize_code_flags(str);

for i=1:length(flags)
    if isnumeric(flags(i).value)
        flags(i).value = 0;
    end
end
newStr = kotenize_code_flags(flags);

if(~strcmp(str,newStr))
	% set it only if necessary
    set_target_props(target,'.codeFlags',newStr);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = kotenize_code_flags(flags)

str = '';
for i=1:length(flags)
    if ischar(flags(i).value)
        formatStr = '%s %s=%s';
    else
        formatStr = '%s %s=%d';
    end
    str = sprintf(formatStr, str, flags(i).name, flags(i).value);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flags = tokenize_code_flags(str)

[first last tokens] = regexp(str,'(\w+)=(\w+)');

flags = [];
for i = 1:length(first)
    flags(i).name = str(tokens{i}(1,1):tokens{i}(1,2));
    flags(i).value = str(tokens{i}(2,1):tokens{i}(2,2));
    if ~isempty(regexp(flags(i).value, '^\d+$', 'once'))
        % Numeric value
        flags(i).value = str2num(flags(i).value);
    end
end
