function hPropDb = getPropertyDb
%GETPROPERTYDB Get the propertyDb.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/04/28 03:27:18 $

hPropDb = extmgr.PropertyDb;

% Respect source navigation-control repeat/autoreverse flag
% when using keyboard navigation
%
% Default: allow repeat/autoreverse
hPropDb.add('PlaybackCmdMode','bool',true);

% Number of entries to maintain in "recent sources" list
hPropDb.add('RecentSourcesListLength','double',8);

% Control visibility of source playback toolbar
% All sources have this toolbar, even if unused
%
% This option appears in the GUI itself (installation handled by
% CreateGUI), but does not appear in the properties dialog.
hPropDb.add('PlaybackToolbar','bool',true);

hPropDb.add('ShowRecentSources', 'bool', true);
hPropDb.add('ShowPlaybackCmdMode', 'bool', true);

% [EOF]
