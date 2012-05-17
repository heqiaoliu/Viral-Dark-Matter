function ha = analogresp(h)
%ANALOGRESP   Compute analog response object.

%   Author(s): R. Losada
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:29:20 $

% Compute analog frequency
c = cparam(h);
wc = abs(sin(pi*h.F3dB2)/(cos(pi*h.F3dB2) - c));

% Construct analog specs object
ha = fspecs.alpcutoff(h.FilterOrder,wc);


% [EOF]
