function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/10/23 18:54:42 $

examples = {{ ...
    'Design a bandpass Elliptic filter in the DF2TSOS structure.', ...
    'h  = fdesign.bandpass(''N,Fp1,Fp2,Ast1,Ap,Ast2'');', ...
    'Hd = design(h, ''ellip'', ''FilterStructure'', ''df2tsos'');'}};

% [EOF]
