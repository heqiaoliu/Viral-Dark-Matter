function examples = getexamples(this) %#ok<INUSD>
%GETEXAMPLES   Get the examples.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:37:43 $

examples = {{ ...
    'Design a highpass constrained least-squares FIR filter.', ...
    'h  = fdesign.highpass(''N,Fc,Ast,Ap'', 50, 0.3, 30, 2);', ...
    'Hd = design(h, ''fircls'');'}};

% [EOF]