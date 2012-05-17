function CI = confinterval(this,x,Pxx,~,CL)
%CONFINTERVAL  Confidence Interval for AR spectrum estimation methods.
%   CI = CONFINTERVAL(THIS,X,PXX,W,CL) calculates the confidence
%   interval CI for spectrum estimate PXX based on confidence level CL. THIS is a
%   spectrum object and W is the frequency vector. X is the data used for
%   computing the spectrum estimate PXX.
% 
%   Reference : Steven M.Kay, "Modern spectral Estimation",
%   Prentice Hall, 1988, Chapter 6, pp 194-195
% 
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.3 $  $Date: 2009/07/14 04:03:24 $
% 

alfa = 1-CL;
normval = norminverse(1-alfa/2,0,1);

N = length(x);
p = this.Order;

if( N/(2*p) > normval^2)
    beta = sqrt(2*p/N)* normval;
    CI = Pxx*[1-beta 1+beta];
else
    CLmsgid = generatemsgid('InsufficientData');   
    warning(CLmsgid,'Confidence intervals cannot be calculated. Provide more data or decrease confidence level');
    CI = [];
end


%--------------------------------------------------------------------------
function [x] = norminverse(p,mu,sigma)
%NORMINVERSE Inverse of the normal cumulative distribution function (cdf).
%   X = NORMINVERSE(P,MU,SIGMA) returns the inverse cdf for the normal
%   distribution with mean MU and standard deviation SIGMA, evaluated at
%   the value in P.  
%
%   Default values for MU and SIGMA are 0 and 1, respectively.
%
%
%   References:
%      [1] Abramowitz, M. and Stegun, I.A. (1964) Handbook of Mathematical
%          Functions, Dover, New York, 1046pp., sections 7.1, 26.2.
%      [2] Evans, M., Hastings, N., and Peacock, B. (1993) Statistical
%          Distributions, 2nd ed., Wiley, 170pp.

if nargin<1
    error(generatemsgid('Nargchk'),'Input argument P is undefined.');
end

if nargin < 2
    mu = 0;
end

if nargin < 3
    sigma = 1;
end

if(sigma <=0)
    error(generatemsgid('InvalidParam'),'Invalid value for sigma');
end

if(p < 0 || 1 < p)
     error(generatemsgid('InvalidParam'),'Invalid value for P');
end

x0 = -sqrt(2).*erfcinv(2*p);
x = sigma*x0 + mu;

% [EOF]

