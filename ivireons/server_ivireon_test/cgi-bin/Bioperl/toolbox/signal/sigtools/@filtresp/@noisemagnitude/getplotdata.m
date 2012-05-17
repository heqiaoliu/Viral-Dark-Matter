function [W, H] = getplotdata(hObj, H, W, P, Nf)
%GETPLOTDATA Return the data to plot

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/08/29 13:58:30 $

for indx = 1:length(H),
    H{indx} = convert2db(H{indx});
end

% [EOF]
