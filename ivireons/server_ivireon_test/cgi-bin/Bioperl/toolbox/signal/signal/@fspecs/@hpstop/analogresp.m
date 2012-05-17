function ha = analogresp(h)
%ANALOGRESP   Compute analog response object.

%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:14:41 $

% Compute analog frequency
ws = cot(pi*h.Fstop/2);

% Construct analog specs object
ha = fspecs.alpstop(h.FilterOrder,ws,h.Astop);


% [EOF]
