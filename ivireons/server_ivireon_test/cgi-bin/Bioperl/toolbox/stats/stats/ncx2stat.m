function [m,v]= ncx2stat(nu,delta)
%NCX2STAT Mean and variance for the noncentral chi-square distribution.
%   [M,V] = NCX2STAT(NU,DELTA) returns the mean and variance
%   of the noncentral chi-square pdf with NU degrees of freedom and
%   noncentrality parameter, DELTA.
%
%   See also NCX2CDF, NCX2INV, NCX2PDF, NCX2RND, CHI2STAT.

%   Reference:
%      [1]  Evans, Merran, Hastings, Nicholas and Peacock, Brian,
%      "Statistical Distributions, Second Edition", Wiley
%      1993 p. 50-51.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:16:17 $

if nargin < 2, 
    error('stats:ncx2stat:TooFewInputs','Requires two input arguments.'); 
end

[errorcode, nu, delta] = distchck(2,nu,delta);

if errorcode > 0
    error('stats:ncx2stat:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize the mean and variance to NaN.
if isa(nu,'single') || isa(delta,'single')
   m = NaN(size(nu),'single');
else
   m = NaN(size(nu));
end
v = m;

% Compute mean and variance for valid parameter values.
k = (nu > 0 & delta >= 0);
if any(k(:))
    m(k) = delta(k) + nu(k);
    v(k) = 2*(nu(k) + 2*(delta(k)));
end
