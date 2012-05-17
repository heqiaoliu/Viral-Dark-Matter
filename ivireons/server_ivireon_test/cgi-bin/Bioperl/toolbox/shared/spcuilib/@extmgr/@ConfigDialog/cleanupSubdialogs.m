function cleanupSubdialogs(this)
%CLEANUPSUBDIALOGS 

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/04/21 21:49:08 $

iterator.visitImmediateChildrenBkwd(this, ...
    @(hChild) lclRemove(hChild));

% -------------------------------------------------------------------------
function lclRemove(hChild)

disconnect(hChild);
delete(hChild);

% [EOF]
