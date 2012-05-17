function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/30 17:38:01 $

examples = {{ ...
    'Design a bandpass Equiripple filter in a transposed structure.', ...
    'h  = fdesign.bandpass(''Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2'');', ...
    'Hd = design(h, ''equiripple'', ''FilterStructure'', ''dffirt'');'}};

% [EOF]
