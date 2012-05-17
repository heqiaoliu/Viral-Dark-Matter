function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/30 17:38:18 $

examples = {{ ...
    'Design a lowpass Equiripple filter in a transposed structure.', ...
    'h  = fdesign.highpass(''Fst,Fp,Ast,Ap'');', ...
    'Hd = design(h, ''equiripple'', ''FilterStructure'', ''dffirt'');'}};

% [EOF]
