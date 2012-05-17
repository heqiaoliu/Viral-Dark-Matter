function disp(hKeyMgr)
%DISP Display key manager object.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:48:10 $

fprintf('KeyMgr object "%s" (%d children)\n', ...
    hKeyMgr.titlePrefix, iterator.numImmediateChildren(hKeyMgr));

fprintf('  KeyMgr Properties:\n');
get(hKeyMgr)

% Get count of immediate children
fprintf('  KeyMgr Children:\n');
iterator.visitImmediateChildren(hKeyMgr,@disp);

% [EOF]
