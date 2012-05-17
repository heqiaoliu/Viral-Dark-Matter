function backupfs_listener(hObj, eventData)
%BACKUPFS_LISTENER Listener to the backupfs property

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/28 19:12:52 $

% Sync the FsSpecifier with the fs from the filterobjs
setup_fsspecifier(hObj);

% [EOF]
