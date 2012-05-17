function help_scalepassband(this)
%HELP_SCALEPASSBAND   

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:43:19 $

scale_str = sprintf('%s\n%s\n%s', ...
    '    HD = DESIGN(..., ''ScalePassband'', SCALE) scales the first passband so', ...
    '    that it has a magnitude of 0 dB after windowing when SCALE is TRUE.', ...
    '    SCALE is TRUE by default.');

disp(scale_str);
disp(' ');

% [EOF]
