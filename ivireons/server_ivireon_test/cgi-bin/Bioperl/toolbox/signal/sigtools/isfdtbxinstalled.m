function [b, errstr, errid] = isfdtbxinstalled
%ISFDTBXINSTALLED   Returns true if filter design toolbox is installed.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/12/22 19:05:19 $

persistent isinstalled;

%This is for the compiler - LICENSE and VER do not work for compiled
%applications so we need to check for the presence of the filterdesign
%toolbox directory in the CTF root (compiled archived root)
if isdeployed
    dir_present = exist(fullfile(ctfroot,'toolbox','filterdesign'));
    if (dir_present==7)
        b = true; errstr = ''; errid = '';
    else
        b = false;
        errstr = sprintf('%s\n%s', 'Filter Design Toolbox is not available.', ...
            'Make sure that it is installed and that a license is available.');
        errid  = 'noFDTbx';
    end
else
    
    if isempty(isinstalled)
        isinstalled = ~isempty(ver('filterdesign'));
    end
    b = license('test', 'Filter_Design_Toolbox') && isinstalled;

    % This is the old code.  We called VER every time, but this was a little
    % too expensive, so we now use a persistent variable.
    % b = license('test', 'Filter_Design_Toolbox') && ~isempty(ver('filterdesign'));

    if b
        errstr = '';
        errid  = '';
    else
        errstr = sprintf('%s\n%s', 'Filter Design Toolbox is not available.', ...
            'Make sure that it is installed and that a license is available.');
        errid  = 'noFDTbx';
    end
end
% [EOF]
