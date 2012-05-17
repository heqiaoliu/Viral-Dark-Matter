function help_densityfactor(this, dfactor)
%HELP_DENSITYFACTOR   

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:42:23 $

if nargin < 2
    dfactor = 16;
end

density_str = sprintf('%s\n%s', ...
    '    HD = DESIGN(..., ''DensityFactor'', DENS) specifies the grid density DENS', ...
    sprintf('    used in the optimization.  DENS is %d by default.', dfactor));

disp(density_str);
disp(' ');

% [EOF]
