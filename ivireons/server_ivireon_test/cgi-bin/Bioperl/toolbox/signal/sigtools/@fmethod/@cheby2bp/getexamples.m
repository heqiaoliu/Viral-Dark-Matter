function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/10/23 18:53:19 $

examples = {{ ...
    'Design a bandpass Chebyshev type II filter in the DF1SOS structure.', ...
    'h  = fdesign.bandpass(''N,Fst1,Fst2,Ast'');', ...
    'Hd = design(h, ''cheby2'', ''FilterStructure'', ''df1sos'');'}};


% [EOF]
