function fs = getfsvalue(hObj, fs)
%GETFSVALUE Returns the Fs specified in Hz.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/03/28 19:16:26 $

if nargin < 2,
    fs = getfs(hObj);
end
if isfield(fs, 'Units'), fs.units = fs.Units; end
if isfield(fs, 'Value'), fs.value = fs.Value; end

if ~strncmpi(fs.units, 'normalized', 10),
    fs = convertfrequnits(fs.value, fs.units, 'Hz');
else
    fs = [];
end

% [EOF]
