function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/10/23 18:52:52 $

examples = {{ ...
    'Design a lowpass Chebyshev type I filter in the DF2TSOS structure.', ...
    'h  = fdesign.lowpass(''N,Fp,Ap'');', ...
    'Hd = design(h, ''cheby1'', ''FilterStructure'', ''df2tsos'');'}};

% [EOF]
