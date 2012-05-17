function reset(h)
%RESET  Reset axes object.

%   Copyright 1996-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/12/27 20:28:01 $

h.mpanimateaxes_reset;

axis(h.AxesHandle, [0 1e-6 0 2]);
h.ChannelSmoothIRTimeDomain = [0 1e-6];
