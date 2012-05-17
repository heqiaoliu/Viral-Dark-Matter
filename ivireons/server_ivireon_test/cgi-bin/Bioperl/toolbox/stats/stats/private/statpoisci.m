function lambdaci = statpoisci(m,lambdahat,alpha)
%STATPOISCI confidence interval for Poisson lambda parameter

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:30:21 $

lsum = m*lambdahat;
k = (lsum < 100);
if any(k)
    % Chi-square exact method
    lb(k) = chi2inv(alpha/2, 2*lsum(k))/2;
    ub(k) = chi2inv(1-alpha/2, 2*(lsum(k)+1))/2;
end
k = ~k;
if any(k)
    % Normal approximation
    lb(k) = norminv(alpha/2,lsum(k),sqrt(lsum(k)));
    ub(k) = norminv(1 - alpha/2,lsum(k),sqrt(lsum(k)));
end

lambdaci = [lb;ub]/m;
