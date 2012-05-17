function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/10/23 18:55:48 $

examples = {{ ...
    'Design a highpass Elliptic filter in the DF1TSOS structure.', ...
    'h  = fdesign.highpass(''N,Fst,Fp,Ap'');', ...
    'Hd = design(h, ''ellip'', ''FilterStructure'', ''df1tsos'');'}};

% [EOF]
