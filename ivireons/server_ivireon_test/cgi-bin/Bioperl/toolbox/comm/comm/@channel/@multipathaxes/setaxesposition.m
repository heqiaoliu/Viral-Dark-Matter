function setaxesposition(h, axPos);
%SETAXESPOSITION  Set axis position for multipath axes object.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:21:36 $

% If no position specified, do nothing.
if nargin==1
    return;
end

% Set axes position.
set(h.AxesHandle, 'position', axPos);
