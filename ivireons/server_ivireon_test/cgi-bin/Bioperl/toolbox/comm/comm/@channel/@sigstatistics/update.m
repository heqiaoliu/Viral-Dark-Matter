function y = update(h, x);
%UPDATE  Signal statistics update.
%
%   x   - Input signal (length x numchannels)
%   h   - Channel object

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:22:11 $
 
% Minor overriding of buffer update to allow "statistics ready" flag to be
% reset.  Major overriding is in flush method.

h.Ready = 0;
y = buffer_update(h, x);
