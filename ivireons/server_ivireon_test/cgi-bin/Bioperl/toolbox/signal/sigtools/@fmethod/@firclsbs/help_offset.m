function help_offset(this)
%HELP_OFFSET

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:37:36 $

offset_str = sprintf('%s\n%s', ...
    '    HD = DESIGN(..., ''PassbandOffset'', PASSBANDOFFSET) specifies the ', ...
    '    passband gain in dB. PASSBANDOFFSET is a row vector of length 2',...
    '    where the first and the second elements specify the gain values for the first and the second',...
    '    passband respectively. PASSBANDOFFSET is [0 0] by default.');
disp(offset_str);
disp(' ');

% [EOF]
