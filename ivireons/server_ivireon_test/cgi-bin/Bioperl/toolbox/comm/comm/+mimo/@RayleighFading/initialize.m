function initialize(h)
%INITIALIZE  Initialize rayleighfading object.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/21 03:05:16 $

% Reset source, including random state.
if legacychannelsim
    WGNState = 0;
    reset(h, WGNState);
else
    reset(h);
end
