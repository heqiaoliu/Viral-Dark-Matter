function initialize(h)
%INITIALIZE  Initialize multipath channel object.

%   Copyright 1996-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/04/21 03:05:34 $

% Reset channel, including random state.
if legacychannelsim || h.PrivLegacyMode
    WGNState = 0;
    reset(h, WGNState);
else
    reset(h);
end
