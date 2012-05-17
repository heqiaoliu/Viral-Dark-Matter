function setup_fsspecifier(hObj, indx)
%SETUP_FSSPECIFIER Setup the fsspecifier

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/28 19:13:07 $

if nargin < 2, indx = get(hObj, 'Index'); end

% Set up the fsspecifier
hfs = getcomponent(hObj, '-class', 'siggui.fsspecifier');
bfs = get(hObj, 'BackupFs');

if indx,
    set(hfs, bfs(indx));
else
    set(hfs, bfs(1));
end

% [EOF]
