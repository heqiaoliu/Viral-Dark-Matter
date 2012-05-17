function fs_listener(hObj, eventData)
%FS_LISTENER Listener to the fsspecifier

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/28 19:12:58 $

indx = get(hObj, 'Index');

hfs = getcomponent(hObj, '-class', 'siggui.fsspecifier');

fs.Value = get(hfs, 'Value');
fs.Units = get(hfs, 'Units');

bfs = get(hObj, 'BackupFs');

if indx,
    bfs(indx) = fs;
else
    bfs = repmat(fs, 1, length(bfs));
end
set(hObj, 'BackupFs', bfs);

set(hObj, 'isApplied', 0);

% [EOF]
