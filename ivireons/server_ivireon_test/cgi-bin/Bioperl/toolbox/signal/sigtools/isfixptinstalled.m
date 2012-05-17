function [b, errstr, errid] = isfixptinstalled
%ISFIXPTINSTALLED   Returns true if fixedpoint is installed.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2005/12/22 19:05:20 $

%This is for the compiler - LICENSE and VER do not work for compiled
%applications so we need to check for the presence of the fixedpoint
%toolbox directory in the CTF root (compiled archived root)
if isdeployed
    dir_present = exist(fullfile(ctfroot,'toolbox','fixedpoint'));
    if (dir_present==7)
        b = true; errstr = ''; errid = '';
    else
        b = false;
        errstr = sprintf('%s\n%s', 'Fixed-Point Toolbox is not available.', ...
            'Make sure that it is installed and that a license is available.');
        errid  = 'noFixPt';
    end
else

    b = license('test', 'Fixed_Point_Toolbox') && ~isempty(ver('fixedpoint'));
    if b
        errstr = '';
        errid  = '';
    else
        errstr = sprintf('%s\n%s', 'Fixed-Point Toolbox is not available.', ...
            'Make sure that it is installed and that a license is available.');
        errid  = 'noFixPt';
    end
end

% [EOF]
