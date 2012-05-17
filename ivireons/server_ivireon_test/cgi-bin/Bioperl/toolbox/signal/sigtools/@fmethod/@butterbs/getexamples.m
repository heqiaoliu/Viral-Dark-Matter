function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/10/23 18:50:32 $

examples = {{ ...
    'Design a bandstop Butterworth filter in the DF2SOS structure.', ...
    'h  = fdesign.bandstop(''N,F3dB1,F3dB2'');', ...
    'Hd = design(h, ''butter'', ''FilterStructure'', ''df2sos'');'}};

% [EOF]
