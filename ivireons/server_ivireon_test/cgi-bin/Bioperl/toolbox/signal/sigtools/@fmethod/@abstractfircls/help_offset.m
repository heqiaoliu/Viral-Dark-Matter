function help_offset(this) %#ok<INUSD>
%HELP_OFFSET

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:37:20 $

offset_str = sprintf('%s\n%s', ...
    '    HD = DESIGN(..., ''PassbandOffset'', PASSBANDOFFSET) specifies the ', ...
    '    passband band gain in dB. PASSBANDOFFSET is 0 dB by default.');
disp(offset_str);
disp(' ');

% [EOF]
