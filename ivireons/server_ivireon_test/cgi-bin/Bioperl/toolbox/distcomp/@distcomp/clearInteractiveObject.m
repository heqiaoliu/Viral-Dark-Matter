function clearInteractiveObject()
; %#ok Undocumented
%clearInteractiveObject Clear the singleton lab or client object.
%   We need to clear this after every parallel or MatlabPool job.
%   Otherwise, a later job will not recreate it as it still exists.

% Copyright 2006-2007 The MathWorks, Inc.

% $Revision: 1.1.6.1 $    $Date: 2007/10/10 20:40:21 $

distcomp.pGetInteractiveObject('clear');
