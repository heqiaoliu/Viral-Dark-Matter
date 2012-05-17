function ha = analogresp(h)
%ANALOGRESP   Compute analog response object.

%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:12:25 $

% Compute analog frequency
c = cparam(h);
ws1 = (c-cos(pi*h.Fstop1))/sin(pi*h.Fstop1);
ws2 = (c-cos(pi*h.Fstop2))/sin(pi*h.Fstop2);
ws = min(abs([ws1,ws2]));


% Construct analog specs object
ha = fspecs.alpstop(h.FilterOrder,ws,h.Astop);


% [EOF]
