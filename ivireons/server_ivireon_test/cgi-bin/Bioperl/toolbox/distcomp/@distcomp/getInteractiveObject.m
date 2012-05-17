function c = getInteractiveObject()
; %#ok Undocumented
%getInteractiveObject Return a singleton lab or client object.
%   The return type depends on whether this is invoked on a lab or on the 
%   client and whether it is a MatlabPool job or not.

% Copyright 2006-2007 The MathWorks, Inc.

% $Revision: 1.1.6.2 $    $Date: 2007/10/10 20:40:22 $

c = distcomp.pGetInteractiveObject('create');
