function help_force(this)
%HELP_FORCE   

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/30 17:37:13 $

force_str = sprintf('%s\n%s\n\n%s\n\n%s', ...
    '    HD = DESIGN(..., ''MinOrder'', ''any'') designs a minimum-order filter.', ...
    '    The order of the filter can be even or odd. This is the default.', ...  
    '    HD = DESIGN(..., ''MinOrder'', ''even'') designs an minimum-even-order filter.', ...
    '    HD = DESIGN(..., ''MinOrder'', ''odd'') designs an minimum-odd-order filter.');

disp(force_str);
disp(' ');

% [EOF]
