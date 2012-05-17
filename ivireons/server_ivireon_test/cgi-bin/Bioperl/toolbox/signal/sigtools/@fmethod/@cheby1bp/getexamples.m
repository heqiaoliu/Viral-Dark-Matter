function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/10/23 18:51:52 $

examples = {{ ...
    'Design a bandpass Chebyshev type I filter in the DF1SOS structure.', ...
    'h  = fdesign.bandpass(''N,Fp1,Fp2,Ap'');', ...
    'Hd = design(h, ''cheby1'', ''FilterStructure'', ''df1sos'');'}};

% [EOF]
