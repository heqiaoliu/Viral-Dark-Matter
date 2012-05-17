function reset(h)
%RESET  Reset axes object.

%   Copyright 1996-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/12/27 20:28:04 $

h.mpanimateaxes_reset;

axis(h.AxesHandle, [-3 3 -3 3]);
axis(h.AxesHandle, 'square');

% Need to reset because aspect ratio has changed.
setaxesposition(h);