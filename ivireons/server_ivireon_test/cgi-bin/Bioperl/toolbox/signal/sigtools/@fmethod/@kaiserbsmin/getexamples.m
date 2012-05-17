function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/06/27 23:40:21 $

examples = {{ ...
    'Design a bandstop Kaiser windowed FIR filter.', ...
    'h  = fdesign.bandstop(''Fp1,Fst1,Fst2,Fp2,Ap1,Ast,Ap2'');', ...
    'Hd = design(h, ''kaiserwin'', ''ScalePassband'', false);'}};

% [EOF]
