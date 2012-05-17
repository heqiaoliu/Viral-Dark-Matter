function [b, errstr, errid] = isccslinkinstalled
%ISCCSLINKINSTALLED   Returns true if the Embedded IDE Link is installed.

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/05/18 21:17:20 $

b = license('test', 'Embedded_IDE_Link') && ~isempty(ver('idelink'));

if b
    errstr = '';
    errid  = '';
else
    errstr = sprintf('%s\n%s', 'Embedded IDE Link(TM) is not available.', ...
        'Make sure that it is installed and that a license is available.');
    errid  = 'noHDLCoder';
end

% [EOF]
