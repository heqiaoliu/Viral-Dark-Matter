function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/30 17:38:04 $

examples = {{ ...
    'Design a bandpass Equiripple filter in a transposed structure.', ...
    'h  = fdesign.bandstop(''Fp1,Fst1,Fst2,Fp2,Ap1,Ast,Ap2'');', ...
    'Hd = design(h, ''equiripple'', ''FilterStructure'', ''dffirt'');'}};

% [EOF]
