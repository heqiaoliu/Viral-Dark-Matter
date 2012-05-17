function N_A = saturationDF(gamma)
% Function to compute describing function of a saturation nonlinearity with
% slope 1 and upper/lower limit of 0.5
%
%  Copyright 2003-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/05/23 08:20:13 $

N_A = zeros(size(gamma));
for ct = 1:numel(gamma)
    if gamma(ct) < -1
        N_A(ct) = -1;
    elseif gamma(ct) <=1
        N_A(ct) = (2/pi)*(asin(gamma(ct))+(gamma(ct)*sqrt(1-gamma(ct)^2)));
    else
        N_A(ct) = 1;
    end
end