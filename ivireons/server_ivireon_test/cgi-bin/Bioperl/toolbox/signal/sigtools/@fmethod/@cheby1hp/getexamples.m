function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/10/23 18:52:33 $

examples = {{ ...
    'Design a highpass Chebyshev type I filter in the DF1TSOS structure.', ...
    'h  = fdesign.highpass(''N,Fp,Ap'');', ...
    'Hd = design(h, ''cheby1'', ''FilterStructure'', ''df1tsos'');'}};

% [EOF]
