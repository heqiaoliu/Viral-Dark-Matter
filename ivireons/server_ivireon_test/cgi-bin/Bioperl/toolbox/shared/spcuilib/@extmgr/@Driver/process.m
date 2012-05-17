function process(this, hConfig, varargin)
%PROCESS Process one extension configuration enable state.
%   process(hDriver, hConfig) process a single configuration's enable
%   state, including property merging and extension instantiation.  This
%   method is called by the listener to the ConfigEnableChanged event.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/09/09 21:29:00 $

% Find registration for extension that has changed enable state
hRegister = findRegister(this.RegisterDb, hConfig);
if isempty(hRegister)
    % Registration info not found
    
    % Throw a message and disable extension
    local_RegNotFoundErrMsg(this,hConfig);
    hConfig.Enable = false;
    errorIfConstraintViolation(this);
    
    % We refresh dialog if open, so don't return early
else
    % Registration info found
    %
    if hConfig.Enable 
        % Extension enabled
        if isempty(getExtension(this.ExtensionDb, hRegister))
            
            % Add the extension to the database.
            add(this.ExtensionDb, hRegister, hConfig, varargin{:});
        end

        % Even when there's an error, we still want to update the
        % property dialog ... say, to remove a bogus extension.
        % So don't return early!
    else
        % Disable extension

        % Extension was just disabled
        % Remove from instance list, if present.
        remove(this.ExtensionDb, hRegister, varargin{:});
    end
end

% Update preferences dialog to reflect any changes in enable state,
% additional property dialog tabs, etc, but only if dialog is open.
%
editConfigSet(this,false); % don't create new dialog; update only, look 
                           % into doing this with listeners

%%
function local_RegNotFoundErrMsg(this,hConfig)
% Error occurred when attempting to find Register
% corresponding to Config instance.

hMessageLog = this.MessageLog;
if ~isempty(hMessageLog)
    % Send error to MessageLog
    summary = 'Could not find extension registration.';
    details=sprintf([ ...
        'Failed to find extension registration.<br>' ...
        '<ul>' ...
        '<li><b>Type:</b> %s<br>' ...
        '<li><b>Name:</b> %s<br>' ...
        '</ul>' ...
        '<b>Cannot enable this extension.</b><br>'], ...
        hConfig.Type, hConfig.Name);
    hMessageLog.add('Fail','Extension',summary,details);
end

% [EOF]
