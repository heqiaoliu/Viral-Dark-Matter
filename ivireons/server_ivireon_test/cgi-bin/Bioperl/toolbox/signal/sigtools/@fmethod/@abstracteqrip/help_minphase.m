function help_minphase(this)
%HELP_MINPHASE   

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:42:51 $

minphase_str = sprintf('%s\n%s', ...
    '    HD = DESIGN(..., ''MinPhase'', MPHASE) designs a minimum-phase filter', ...
    '    when MPHASE is TRUE.  MPHASE is FALSE by default.');

disp(minphase_str);
disp(' ');


% [EOF]
