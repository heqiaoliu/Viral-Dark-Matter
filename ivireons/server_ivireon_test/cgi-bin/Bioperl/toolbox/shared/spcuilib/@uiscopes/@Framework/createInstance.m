function scope = createInstance(this)
%CREATEINSTANCE Create new instance based on current app's configuration

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/11/18 02:14:47 $

hScopeCfg = feval(class(this.ScopeCfg));

% We need to match the current dock state, not the dock state at launch.
% This will make new mplay's launched from docked mplays also docked.
wStyle = get(this.Parent, 'WindowStyle');
if ~strcmpi(wStyle, 'docked')
    wStyle = 'undocked';
end
hScopeCfg.WindowStyle = wStyle;

scope = uiscopes.new(hScopeCfg);

% [EOF]
