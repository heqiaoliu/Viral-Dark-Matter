function out_filename = save_system(varargin)
%SAVE_SYSTEM Save a Simulink system.
%   SAVE_SYSTEM saves the current top-level system to a file with its
%   current name.
%
%   SAVE_SYSTEM('SYS') saves the specified top-level system to a file with
%   its current name.  The system must be currently open.
%     SYS can be a string, a cell array of strings, a numeric handle, or
%     an array of numeric handles.
%
%   SAVE_SYSTEM('SYS','NEWNAME') saves the specified top-level system to a
%   file with the specified new name.  The system must be currently open.
%   NEWNAME can be empty, in which case the current name is used.
%     If SYS refers to more than one block diagram, NEWNAME must be a cell
%     array of new names.
%
%   Additional arguments must be supplied as name-value pairs.  Allowed names are:
%     ErrorIfShadowed: true or false (default: false)
%     BreakUserLinks: true or false (default: false)
%     SaveAsVersion: MATLAB version name (default: current)
%     OverwriteIfChangedOnDisk: true or false (default: false)
%     SaveModelWorkspace: true or false (default: false)
% The same options are applied to all the block diagrams which are saved.
% Options are case-insensitive on all platforms.
%
% SAVE_SYSTEM returns the full name of the file which was saved, as a string.
% If multiple files were saved, the return value is a cell array of strings.

%   Copyright 1996-2010 The MathWorks, Inc.

try
    if nargout
        out_filename = i_save_system(varargin{:});
    else
        i_save_system(varargin{:});
    end
catch e
    throw(e);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out_filename = i_save_system(sys,newname,arg3,arg4,varargin)

oldflags = {'ErrorIfShadowed','BreakLinks','SaveModelWorkspace'};
switch nargin
    case 0
        filename = i_builtin(bdroot);
    case 1
        filename = i_builtin(sys);
    case 2
        filename = i_builtin(sys,newname);
    case 3
        % Old usage.  Warn and convert to new usage.
        i_warn_old_usage();
        filename = i_old_usage(sys,newname,arg3,[]);
    case 4
        % This is less easy.  If this is the old usage, the third argument can be
        % BreakLinks or ErrorIfShadowed or SaveModelWorkspace or empty, and the
        % fourth argument can be a MATLAB release name or empty.  Anything
        % else is the new usage.
        if isempty(arg3) || iscell(arg3)
            % Old usage.  Warn and convert.
            i_warn_old_usage();
            filename = i_old_usage(sys,newname,arg3,arg4);
        elseif ischar(arg3) && ismember(arg3,oldflags) ...
                && (iscell(arg4) || (ischar(arg4) && ismember(arg4,oldflags)))
            % Old usage.  Warn and convert.
            i_warn_old_usage();
            filename = i_old_usage(sys,newname,arg3,arg4);
        else
            % New usage
            filename = i_builtin(sys,newname,arg3,arg4);
        end
    otherwise
        % New usage.
        filename = i_builtin(sys,newname,arg3,arg4,varargin{:});
end

if nargout
    out_filename = filename;
end

%%%%%%%%%%%%%%%%%%%%%%%%%
function filename = i_old_usage(sys,newname,arg3,arg4)

saveasversion = [];

if iscell(arg3)
    n = numel(arg3);
elseif iscell(arg4)
    n = numel(arg4);
    saveasversion = cell(n,1);
else
    n = 1;
end
errorifshadowed = false(n,1);
breaklinks = false(n,1);
savemodelworkspace = false(n,1);

if isempty(arg3)
    % ignore
elseif ischar(arg3)
    switch lower(arg3)
        case ''
            % ignore
        case 'errorifshadowed'
            errorifshadowed = true(n,1);
        case 'breaklinks'
            breaklinks = true(n,1);
        case 'savemodelworkspace'
            savemodelworkspace = true(n,1);
        otherwise
            i_error_input(3);
    end
elseif iscell(arg3)
    for i=1:numel(arg3)
        if isempty(arg3{i})
            % Empty entries are allowed
            continue;
        end
        switch lower(arg3{i})
            case 'errorifshadowed'
                errorifshadowed(i) = true;
            case 'breaklinks'
                breaklinks(i) = true;
            case 'savemodelworkspace'
                savemodelworkspace(i) = true;
            otherwise
                i_error_input(3);
        end
    end
else
    i_error_input(3);
end

if isempty(arg4)
    % ignore
elseif ischar(arg4)
    switch lower(arg4)
        case 'errorifshadowed'
            errorifshadowed = true(n,1);
        case 'breaklinks'
            breaklinks = true(n,1);
        case 'savemodelworkspace'
            savemodelworkspace = true(n,1);
        otherwise
            saveasversion = arg4;
    end
elseif iscell(arg4)
    for i=1:numel(arg4)
        if isempty(arg4{i})
            % Empty entries are allowed
            continue;
        end
        switch lower(arg4{i})
            case 'errorifshadowed'
                errorifshadowed(i) = true;
            case 'breaklinks'
                breaklinks(i) = true;
            case 'savemodelworkspace'
                savemodelworkspace(i) = true;
            otherwise
                saveasversion{i} = arg4{i}; %#ok<AGROW>
        end
    end
else
    i_error_input(4);
end
filename = i_builtin(sys,newname,...
    'ErrorIfShadowed',errorifshadowed,...
    'BreakAllLinks',breaklinks,... % Use BreakAllLinks for backward compatibility
    'SaveModelWorkspace',savemodelworkspace,...
    'SaveAsVersion',saveasversion);

%%%%%%%%%%%%%%%%%%%%%%%%
function i_warn_old_usage

DAStudio.warning('Simulink:utility:SaveSystemOldUsage');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_error_input(num)

DAStudio.error('Simulink:utility:SaveSystemInvalidInput',num);

%%%%%%%%%%%%%%%%%%%%%%%
function filename = i_builtin(varargin)

filename = slInternal('save_system',varargin{:});


