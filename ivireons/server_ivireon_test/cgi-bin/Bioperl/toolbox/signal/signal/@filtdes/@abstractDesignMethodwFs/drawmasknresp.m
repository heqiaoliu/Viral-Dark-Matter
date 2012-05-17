function drawmasknresp(d, Hd)
%DRAWMASKNRESP Draw the mask and the response

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2004/04/13 00:01:16 $

Hd = dfilt.dfiltwfs(Hd, getnyquist(d)*2);

opts = getfvtooloptions(d);
if ~strncmpi(d.frequnits, 'normalized', 10),
    opts = {opts{:}, 'NormalizedFrequency', 'Off'};
end

h = fvtool(Hd, opts{:}, 'DesignMask', 'On');

% [EOF]
