function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/10/23 18:56:12 $

examples = {{ ...
    'Design a lowpass Elliptic filter in the DF2TSOS structure.', ...
    'h  = fdesign.lowpass(''N,Fp,Fst,Ap'');', ...
    'Hd = design(h, ''ellip'', ''FilterStructure'', ''df2tsos'');'}};

% [EOF]
