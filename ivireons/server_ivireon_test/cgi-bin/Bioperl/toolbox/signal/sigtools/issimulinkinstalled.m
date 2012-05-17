function [b, errstr, errid] = issimulinkinstalled
%ISSIMULINKINSTALLED   Returns true if Simulink is installed.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:23:24 $

b = license('test', 'Simulink') && ~isempty(ver('simulink'));

if b
    errstr = '';
    errid  = '';
else
    errstr = sprintf('%s\n%s', 'Simulink is not available.', ...
        'Make sure that it is installed and that a license is available.');
    errid  = 'noSimulink';
end

% [EOF]
