function psi = transphi(phi,tr)
%TRANSPHI Utility function for parameter transformations in nlmefit and
%   nlmefitsa.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:30:37 $

psi=phi;
i1=(tr==1);     % lognormal
if any(i1)
   psi(:,i1)=exp(phi(:,i1));
end
i2=(tr==2);           % probit
if any(i2)
    psi(:,i2)=normcdf(phi(:,i2));
end
i3=(tr==3);           % logit
if any(i3)
    psi(:,i3)=1./(1+exp(-phi(:,i3)));
end
