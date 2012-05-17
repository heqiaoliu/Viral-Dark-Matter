function help_zerophase(this) %#ok<INUSD>
%HELP_ZEROPHASE

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:37:21 $

offset_str = sprintf('%s\n%s', ...
    '    HD = DESIGN(..., ''Zerophase'', ZEROPHASE) designs a filter with a zero-phase response', ...
    '    if ZEROPHASE is true. ZEROPHASE is false by default.');
disp(offset_str);
disp(' ');

% [EOF]
