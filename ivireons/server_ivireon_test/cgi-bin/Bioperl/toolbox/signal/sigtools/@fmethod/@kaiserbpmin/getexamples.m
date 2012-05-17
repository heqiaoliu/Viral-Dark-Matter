function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/06/27 23:40:19 $

examples = {{ ...
    'Design a bandpass Kaiser windowed FIR filter.', ...
    'h  = fdesign.bandpass(''Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2'');', ...
    'Hd = design(h, ''kaiserwin'', ''ScalePassband'', false);'}};

% [EOF]
