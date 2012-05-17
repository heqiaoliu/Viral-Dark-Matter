function ha = analogresp(h)
%ANALOGRESP   Compute analog response object.

%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:12:35 $

% Compute analog frequency
c = cparam(h);
wc = abs(sin(pi*h.Fcutoff2)/(cos(pi*h.Fcutoff2) - c));

% Construct analog specs object
ha = fspecs.alpcutoff(h.FilterOrder,wc);


% [EOF]
