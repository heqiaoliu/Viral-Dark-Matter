function D = propagate(D,lags,Tf,maxlevel)
% Propagates discontinuties MAXLEVEL times.

%   Author: L.F. Shampine and P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:22 $
MaxPoints = 100;
Nlags = length(lags);
vl = D;
for level = 1:maxlevel
    nvl = length(vl);
    vlp1 = zeros(1,nvl*Nlags);    
    for i = 1:Nlags
        vlp1(nvl*(i-1)+1:nvl*i) = vl + lags(i);
    end
    vl = vlp1(vlp1 <= Tf);
    if isempty(vl)
       break
    else
       D = sort([D vl]);
       D = D([true,abs(diff(D))>10*eps*abs(D(2:end))]);      
       if length(D)>MaxPoints
          break
       end
    end
end
% For programming purposes, it is convenient to add Tf to D.
if D(end)<Tf
   D = [D Tf];
end

