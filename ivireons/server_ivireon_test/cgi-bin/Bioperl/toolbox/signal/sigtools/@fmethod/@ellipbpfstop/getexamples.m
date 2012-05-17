function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/10/23 18:54:50 $

examples = {{ ...
    'Design a bandpass Elliptic filter in the DF1SOS structure.', ...
    'h  = fdesign.bandpass(''N,Fst1,Fp1,Fp2,Fst2,Ap'');', ...
    'Hd = design(h, ''ellip'', ''FilterStructure'', ''df1sos'');'}};

% [EOF]
