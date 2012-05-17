function examples = getexamples(this) %#ok<INUSD>
%GETEXAMPLES   Get the examples.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/04/21 16:31:28 $

examples = {{ ...
    'Design a lowpass generalized Butterworth IIR filter.', ...
    'h  = fdesign.lowpass(''Nb,Na,F3dB'', 10, 8, 0.3);', ...
    'Hd = design(h, ''butter'');'}};

% [EOF]
