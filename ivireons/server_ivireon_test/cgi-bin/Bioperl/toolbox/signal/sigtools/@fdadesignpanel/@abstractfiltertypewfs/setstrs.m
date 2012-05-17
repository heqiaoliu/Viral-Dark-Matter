function [strs, lbls] = setstrs(hObj)
%SETSTRS Strings to set and get

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/04/13 00:19:26 $

strs = allprops(hObj);
lbls = cell(length(strs), 1);

for indx = 1:length(strs)
    lbls{indx} = [fvw(hObj) strs{indx}(2:end) ':'];
end

% [EOF]
