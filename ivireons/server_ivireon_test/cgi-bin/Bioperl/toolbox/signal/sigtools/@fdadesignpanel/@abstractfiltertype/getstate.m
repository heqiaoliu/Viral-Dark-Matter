function s = getstate(hObj)
%GETSTATE Get the state of the object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 22:53:00 $

s = get(hObj);

h = getspecs(hObj);

f = fieldnames(s);

% Keep the Tag and Version
for i = 3:length(f)
    if ~strcmpi(f{i}, h),
        s = rmfield(s, f{i});
    end
end

% [EOF]
