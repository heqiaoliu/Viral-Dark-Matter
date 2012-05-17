function cmdispatch(command, file, dirty, modaldlgs)
%CMDISPATCH Simulink/Stateflow version control access.
%   CMDISPATCH(COMMAND, FILE) performs a valid COMMAND
%   on FILE, a fullpath to a Simulink model.
%
%   CMDISPATCH(COMMAND, FILE, DIRTY) performs a valid COMMAND
%   on FILE using the DIRTY flag, supplied as a string that is either 'on'
%   or 'off'.
%
%   CMDISPATCH works only for Simulink and Stateflow.
%
%   See also CHECKIN, CHECKOUT, and UNDOCHECKOUT.
%

% Copyright 1998-2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2008/03/17 22:44:26 $


% CMDISPATCH is called in response to a user selecting source control
% operations from the Simulink or Stateflow editor file menus. It is used
% only on UNIX platforms.
%
% Undocumented fourth input, modaldlgs, switches between showing modal
% error dialogs and throwing hard errors.
if nargin < 4,
    modaldlgs = true;
end

% Is source control configured?
if ~issourcecontrolconfigured,
    % No source control. Display the same error text as MATLAB checkin
    % command, for consistency of reporting
     i_errordlg('No source control system specified. Set in preferences.', ...
         modaldlgs)
    return
end

% BackwardsCompatibility
%   {
% This function is intended for internal use only but may have been
% discovered & used by others, so check for the old syntax when called from
% Stateflow:
if isnumeric(file),
    % file is not a string containing a filename but is instead assumed to
    % be the machine ID of a state machine:
    modelH = sf('get', file, 'machine.simulinkModel');
    if isempty(modelH),
        % it wasn't a State Machine ID:
        error('simulink:cmdispatch:UnknownInput',...
            'File input should be a full-path to a filename, or a State Machine ID (deprecated)')
    end        
    file = get_param(modelH, 'FileName');
    % warn about this depreciated calling syntax
    warning('simulink:cmdispatch:OldSyntax',...
        'Calling cmdispatch using a State Machine ID is deprecated. Use the file name instead.')
end
% 	}

% Get the name of the Simulink model
[junk, modelName] = fileparts(file);
modelH = get_param(modelName, 'handle');

if nargin < 3,
    dirty = get_param(modelH, 'dirty');
end

% OPERATE ON THE APPROPRIATE COMMAND.
% CHECKIN
if (strcmp(command, 'CHECKIN')),
    try
        % ckeckinwin can throw errors:
        checkinwin(file, 1);
        sysName = get_param(modelH, 'Name');
        reloadsys(sysName);
    catch E
        i_errordlg(E.message, modaldlgs);
    end
    return
end

% If dirty, see if the user wants to proceed.
if strcmp(dirty, 'on') && ~modaldlgs,
    userSelection = questdlg(['This model has changed.' char(10) ...
        'If you proceed, you will lose your changes.' char(10) ...
        'Continue?'], ...
        'Source Control', 'Yes', 'No', 'No');
    if (strcmp(userSelection, 'No'))
        return
    end
end

% CHECKOUT and UNDOCHECKOUT
switch (command)
    case 'CHECKOUT'
        try
            % checkoutwin can throw errors:
            checkoutwin(file, 1);
            sysName = get_param(modelH, 'Name');
            reloadsys(sysName);
        catch E
            i_errordlg(E.message, modaldlgs)
            return
        end
    case 'UNDOCHECKOUT'
        try
            undocheckout(file);
            sysName = get_param(modelH, 'Name');
            reloadsys(sysName);
        catch E
            i_errordlg(E.message, 'Error', 'modal');
            return;
        end
    otherwise
        error('simulink:cmdispatch:UnknownCommand', 'Unknown command: %s.', command);
end

% end function cmdispatch(command, file, dirty)

% -------------------------------------------------------------------------
% Show a modal dialog or throw a hard error.
function i_errordlg(msg, modaldlgs)
if modaldlgs
    errordlg(msg, 'Source Control Error', 'modal');
else
    error('simulink:cmdispatch:SCError', msg)
end

    
    


