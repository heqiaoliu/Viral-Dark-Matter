function state = getState(this)
%GETSTATE Get the state.

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2010/01/25 22:47:44 $

% Copy the scope configuration that was used to launch this scope.
state = copy(this.ScopeCfg);

% Update the properties which might have changed.
state.CurrentConfiguration = getLatestConfiguration(this.ExtDriver);
state.Position             = get(this.Parent, 'Position');
state.WindowStyle          = convertWindowStyle(get(this.Parent, 'WindowStyle'));

state.ScopeCLI = uiscopes.ScopeCLI(source(this));
state.ScopeCLI.parseCmdLineArgs;

% -------------------------------------------------------------------------
function wStyle = convertWindowStyle(wStyle)

if strcmp(wStyle, 'normal')
    wStyle = 'undocked';
end

% [EOF]
