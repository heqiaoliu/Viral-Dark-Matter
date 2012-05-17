function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/10/23 18:52:13 $

examples = {{ ...
    'Design a bandstop Chebyshev type I filter in the DF2SOS structure.', ...
    'h  = fdesign.bandstop(''N,Fp1,Fp2,Ap'');', ...
    'Hd = design(h, ''cheby1'', ''FilterStructure'', ''df2sos'');'}};

% [EOF]
