function [b, errstr, errid] = isslfxptinstalled
%ISSLFXPTINSTALLED   Returns true if the Simulink Fixed Point is installed.

%   Author(s): P. Costa
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:58:03 $

b = builtin('license','test','Fixed-Point_Blocks') && ~isempty(ver('fixpoint'));

if b
    errstr = '';
    errid  = '';
else
    errstr = sprintf('%s\n%s', 'Simulink Fixed Point is not available.', ...
        'Make sure that it is installed and that a license is available.');
    errid  = 'noSLFxpt';
end

% [EOF]
