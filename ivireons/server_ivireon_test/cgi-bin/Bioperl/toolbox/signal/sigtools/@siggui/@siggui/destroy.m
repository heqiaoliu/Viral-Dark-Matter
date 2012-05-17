function destroy(h)
%DESTROY Delete the SIGGUI object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 23:31:44 $

if isrendered(h),
    unrender(h);
end

delete(h);
clear h

% [EOF]
