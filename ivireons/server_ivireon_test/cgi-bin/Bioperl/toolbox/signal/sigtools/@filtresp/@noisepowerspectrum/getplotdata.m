function [W, P] = getplotdata(hObj, H, W, P, Nf)
%GETPLOTDATA Return the data to plot

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/08/29 13:58:33 $

for indx = 1:length(P),
    
    % Divide by two because this is already in power.
    P{indx} = convert2db(P{indx})/2;
end

% [EOF]
