function hPropDb = getPropertyDb
%GETPROPERTYDB Get the propertyDb.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/03/31 18:44:27 $

hPropDb = extmgr.PropertyDb;

% Scope title bar control
%
% Show full path in title bars
% Default: short display (no path)
hPropDb.add('DisplayFullSourceName','bool',false);

% MessageLog AutoOpenMode preference
% Default: show all new messages
hPropDb.add('MessageLogAutoOpenMode','AutoOpenModeType', ...
    'for warn/fail messages');

% MessageLog initial dialog position
% Value is the position vector, [x y dx dy]
% Not shown in property dialog - only influenced by moving dialog
%
hPropDb.add('MessageLogDialogPosition','MATLAB array', ...
    [20 520 450 500]);

% Control visibility of status bar and options toolbar
%
% These appear in the GUI itself (installation handled by CreateGUI),
% but do not appear in the properties dialog.
hPropDb.add('ShowMainToolbar', 'bool', true);
hPropDb.add('ShowPlaybackToolbar', 'bool', true);
hPropDb.add('ShowStatusbar', 'bool', true);
hPropDb.add('ShowNewAction', 'bool', true);
hPropDb.add('ShowLoadConfigSet', 'bool', true);
hPropDb.add('ShowSaveConfigSet', 'bool', true);
hPropDb.add('ShowFullPathAction', 'bool', true);

hPropDb.add('FigureProperties', 'mxArray');

% [EOF]
