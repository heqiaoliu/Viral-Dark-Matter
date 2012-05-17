function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/10/23 18:55:11 $

examples = {{ ...
    'Design a bandstop Elliptic filter in the DF2SOS structure.', ...
    'h  = fdesign.bandstop(''N,Fp1,Fp2,Ap,Ast'');', ...
    'Hd = design(h, ''ellip'', ''FilterStructure'', ''df2sos'');'}};

% [EOF]
