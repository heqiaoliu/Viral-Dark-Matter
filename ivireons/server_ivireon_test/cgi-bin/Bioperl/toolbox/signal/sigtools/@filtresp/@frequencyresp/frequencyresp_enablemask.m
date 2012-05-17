function b = frequencyresp_enablemask(hObj)
%FREQUENCYRESP_ENABLEMASK

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.3 $  $Date: 2004/04/13 00:20:14 $

% This should be private

if isprop(hObj, 'Filters'),
    Hd = get(hObj, 'Filters');
    if length(Hd) == 1 & isprop(Hd.Filter, 'MaskInfo'),
        b = true;
    else
        b = false;
    end
    
else
    b = false;
end

% [EOF]
