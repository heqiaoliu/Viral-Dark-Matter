function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/10/23 18:51:21 $

examples = {{ ...
    'Design a lowpass Butterworth filter in the DF2TSOS structure.', ...
    'h  = fdesign.lowpass(''N,F3dB'');', ...
    'Hd = design(h, ''butter'', ''FilterStructure'', ''df2tsos'');'}};

% [EOF]
