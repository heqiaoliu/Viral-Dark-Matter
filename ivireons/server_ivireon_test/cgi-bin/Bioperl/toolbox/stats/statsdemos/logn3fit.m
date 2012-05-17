function paramEsts = logn3fit(x)
%LOGN3FIT Fit a 3-param lognormal dist'n using cumulative probabilities.
%
% Used in the Statistics Toolbox demo "Fitting a Univariate Distribution Using
% Cumulative Probabilities".
%
% See also CDFFITDEMO

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:31:19 $

x = sort(x);
n = length(x);
pEmp = ((1:n)-0.5)' ./ n;
wgt = 1./sqrt(pEmp.*(1-pEmp));
LN3obj = @(params) ...
    sum(wgt.*(logncdf(x-params(3),params(1),exp(params(2)))-pEmp).^2);
c0 = .95*min(x);
mu0 = mean(x-c0); sigma0 = std(x-c0);
opts = optimset('MaxIter',1000, 'MaxFunEval',2000);
paramEsts = fminsearch(LN3obj, [mu0,log(sigma0),c0], opts);
paramEsts(2) = exp(paramEsts(2));
