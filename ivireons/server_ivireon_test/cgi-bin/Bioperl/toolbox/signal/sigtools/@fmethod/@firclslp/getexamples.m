function examples = getexamples(this) %#ok<INUSD>
%GETEXAMPLES   Get the examples.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:37:48 $

examples = {{ ...
    'Design a lowpass constrained least-squares FIR filter.', ...
    'h  = fdesign.lowpass(''N,Fc,Ap,Ast'', 50, 0.3, 2, 30);', ...
    'Hd = design(h, ''fircls'');'}};

% [EOF]