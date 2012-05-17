function examples = getexamples(this) %#ok<INUSD>
%GETEXAMPLES   Get the examples.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/04/21 16:31:23 $

examples = {{ ...
    'Design a lowpass maximally flat FIR filter.', ...
    'h  = fdesign.lowpass(''N,F3dB'', 50, 0.3);', ...
    'Hd = design(h, ''maxflat'');'}};

% [EOF]