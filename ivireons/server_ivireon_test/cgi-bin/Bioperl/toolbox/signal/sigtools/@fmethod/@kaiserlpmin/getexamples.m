function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/06/27 23:40:25 $

examples = {{ ...
    'Design a lowpass Kaiser windowed FIR filter.', ...
    'h  = fdesign.lowpass(''Fp,Fst,Ap,Ast'');', ...
    'Hd = design(h, ''kaiserwin'', ''ScalePassband'', false);'}};

% [EOF]
