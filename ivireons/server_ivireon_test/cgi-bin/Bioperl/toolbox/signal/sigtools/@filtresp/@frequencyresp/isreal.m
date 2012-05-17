function b = isreal(hObj)
%ISREAL Returns true if all the filters are real

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2003/01/27 19:09:53 $

Hd = get(hObj, 'Filters');
b = true;
for indx = 1:length(Hd),
    b = all([b isreal(Hd(indx).Filter)]);
end

% [EOF]
