function examples = getexamples(this) %#ok<INUSD>
%GETEXAMPLES   Get the examples.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:37:28 $

examples = {{ ...
    'Design a bandpass constrained least-squares FIR filter.', ...
    'h  = fdesign.bandpass(''N,Fc1,Fc2,Ast1,Ap,Ast2'', 50, 0.3, 0.6, 30, 1, 50);', ...
    'Hd = design(h, ''fircls'');'}};

% [EOF]