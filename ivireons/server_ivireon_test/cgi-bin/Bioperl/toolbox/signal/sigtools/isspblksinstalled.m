function [b, errstr, errid] = isspblksinstalled
%ISSPBLKSINSTALLED   Returns true if Simulink and Signal Processing Blockset are installed.

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/05/20 03:10:25 $

[b, errstr, errid] = issimulinkinstalled;

if b,
    b = license('test', 'Signal_Blocks') && ~isempty(ver('dspblks'));
    if b
        errstr = '';
        errid  = '';
    else
        errstr = sprintf('%s\n%s', 'Signal Processing Blockset is not available.', ...
            'Make sure that it is installed and that a license is available.');
        errid  = 'noSPBlks';
    end
end

% [EOF]
