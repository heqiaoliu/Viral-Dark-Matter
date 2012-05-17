function fs = getfs(hFs)
%GETFS Returns the Sampling Frequency structure

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/14 23:26:02 $

fs = getstate(hFs);

if strcmpi(fs.Units,'normalized (0 to 1)'),
    fs.value = [];
else
    fs.value = evaluatevars(fs.Value);
end

fs.units = fs.Units;

fs = rmfield(fs, {'Value', 'Units'});

% [EOF]