function close_system(varargin)
%CLOSE_SYSTEM Close a Simulink system window or a block dialog box.
%   CLOSE_SYSTEM closes the current system or subsystem window.  If the
%   system being closed has been modified, CLOSE_SYSTEM will issue an error.
%
%   CLOSE_SYSTEM('SYS') closes the specified system or subsystem window.
%     SYS can be a string, a cell array of strings, a numeric handle, or 
%     an array of numeric handles.
%
%   CLOSE_SYSTEM('SYS',SAVEFLAG), if SAVEFLAG is 1, saves the specified
%   top-level system to a file with its current name, then closes the system
%   and removes it from memory.  If SAVEFLAG is 0, this command closes the
%   system without saving it.
%      A single SAVEFLAG can be supplied, in which case it is applied to all
%      block diagrams.  Alternatively, separate SAVEFLAGs can be supplied for
%      each block diagram, as a numeric array.
%
%   CLOSE_SYSTEM('SYS','NEWNAME') saves the specified top-level system to a
%   file with the specified new name, then closes the system.
%     If SYS refers to more than one block diagram, NEWNAME must be a cell
%     array of new names.
%
%   Additional arguments can be supplied when saving a block diagram.
%   These are exactly the same as for save_system.
%     ErrorIfShadowed: true or false (default: false)
%     BreakUserLinks: true or false (default: false)
%     SaveAsVersion: MATLAB version name (default: current)
%     OverwriteIfChangedOnDisk: true or false (default: false)
%     SaveModelWorkspace: true or false (default: false)
%   These options are case-insensitive.
%
%   See also BDCLOSE, NEW_SYSTEM, OPEN_SYSTEM, SAVE_SYSTEM.

%   Copyright 1992-2010 The MathWorks, Inc.

try
    i_close_system(varargin{:});
catch e
    throw(e);
end

function i_close_system(sys,arg2,arg3,varargin)

switch nargin
    case 0
        i_builtin(gcs);
    case 1
        i_builtin(sys)
    case 2
        % arg2 can be a new name or a number indicating "save" or "don't save"
        i_builtin(sys,arg2);
    case 3
        % Old usage.  Warn and convert to new usage.
        i_warn_old_usage();
        switch lower(arg3)
            case 'errorifshadowed'
                i_builtin(sys,arg2,'ErrorIfShadowed',true);
            otherwise
                DAStudio.error('Simulink:utility:CloseSystemInvalidThirdInput');
        end
    otherwise
        % New usage.
        i_builtin(sys,arg2,arg3,varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%
function i_warn_old_usage

DAStudio.warning('Simulink:utility:CloseSystemOldUsage');

%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_builtin(varargin)

slInternal('close_system',varargin{:});
