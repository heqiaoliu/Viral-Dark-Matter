function reset(h)
%RESET  Reset axes object.

%   Copyright 1996-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/12/27 20:27:52 $

h.mpanimateaxes_reset;

axis(h.AxesHandle, [-9e-3 0 -40 10])
set(h.AxesHandle, 'xticklabel', '');