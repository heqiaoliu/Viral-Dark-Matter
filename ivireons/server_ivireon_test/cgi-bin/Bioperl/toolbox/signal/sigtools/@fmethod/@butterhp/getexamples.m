function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/10/23 18:51:02 $

examples = {{ ...
    'Design a highpass Butterworth filter in the DF1TSOS structure.', ...
    'h  = fdesign.highpass(''N,F3dB'');', ...
    'Hd = design(h, ''butter'', ''FilterStructure'', ''df1tsos'');'}};

% [EOF]
