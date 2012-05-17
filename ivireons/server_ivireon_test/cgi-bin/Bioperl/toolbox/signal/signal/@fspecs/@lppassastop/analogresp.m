function ha = analogresp(h)
%ANALOGRESP   Compute analog response object.

%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:15:14 $

% Compute analog frequency
wp = tan(pi*h.Fpass/2);

% Construct analog specs object
ha = fspecs.alppassastop(h.FilterOrder,wp,h.Apass,h.Astop);


% [EOF]
