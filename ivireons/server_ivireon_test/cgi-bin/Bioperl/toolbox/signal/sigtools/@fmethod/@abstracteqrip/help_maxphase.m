function help_maxphase(this)
%HELP_MINPHASE   

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:04:25 $

maxphase_str = sprintf('%s\n%s', ...
    '    HD = DESIGN(..., ''MaxPhase'', MPHASE) designs a maximum-phase filter', ...
    '    when MPHASE is TRUE.  MPHASE is FALSE by default.');

disp(maxphase_str);
disp(' ');


% [EOF]