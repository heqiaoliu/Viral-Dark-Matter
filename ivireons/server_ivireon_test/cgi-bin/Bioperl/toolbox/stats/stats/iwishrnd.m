function [a,di] = iwishrnd(sigma,df,di)
%IWISHRND Generate inverse Wishart random matrix
%   W=IWISHRND(SIGMA,DF) generates a random matrix W from the inverse
%   Wishart distribution with parameters SIGMA and DF.  The inverse of W
%   has the Wishart distribution with covariance matrix inv(SIGMA) and DF
%   degrees of freedom.
%
%   W=IWISHRND(SIGMA,DF,DI) expects DI to be lower triangular so that
%   DI'*DI = INV(SIGMA), i.e., the transpose of inverse of the Cholesky
%   factor of SIGMA. If you call IWISHRND multiple times using the same
%   value of SIGMA, it's more efficient to supply DI instead of computing
%   it each time.
%
%   [W,DI]=IWISHRND(SIGMA,DF) returns DI so it can be used again in
%   future calls to IWISHRND.
%
%   Note that different sources use different parameterizations for the
%   inverse Wishart distribution.  This function defines the parameter
%   SIGMA so that the mean of the output matrix is SIGMA/(DF-K-1), where
%   K is the number of rows and columns in SIGMA.
%
%   See also WISHRND.

%   Copyright 1993-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:14:56 $

% Error checking
if nargin<2
   error('stats:iwishrnd:TooFewInputs','Two arguments are required.');
end

[n,m] = size(sigma);
if n~=m
   error('stats:iwishrnd:BadCovariance','Covariance matrix must be square.');
end

% Factor sigma unless that has already been done
if nargin<3
   [d,p] = cholcov(sigma,0);
   if p~=0
      error('stats:iwishrnd:BadCovariance',...
            'Covariance matrix must be symmetric and positive definite.');
   end
   if nargout > 1
      di = d' \ eye(size(d));
   end
elseif ~isempty(sigma)
   if ~isequal(size(di),size(sigma))
      error('stats:iwishrnd:BadCovFactor',...
            'DI must be the same size as SIGMA.')
   end
else
   n = size(di,2);
end

if (~isscalar(df)) || (df<=0)
   error('stats:iwishrnd:BadDf',...
         'Degrees of freedom must be a positive scalar.')
elseif (df<n) % require this to ensure invertibility
   error('stats:iwishrnd:BadDf',...
         'Degrees of freedom must be no smaller than the dimension of SIGMA.');
end

% For small degrees of freedom, generate the matrix using the definition
% of the Wishart distribution; see Krzanowski for example
if (df <= 81+n) && (df==round(df))
   x = randn(df,n);

% Otherwise use the Smith & Hocking procedure
else
   % Load diagonal elements with square root of chi-square variates
   x = diag(sqrt(chi2rnd(df-(0:n-1))));

   % Load upper triangle with independent normal (0, 1) variates
   x(itriu(n)) = randn(n*(n-1)/2,1);
end

% Desired random matrix is INV(DI'*(X'*X)*DI) = D'*INV(X'*X)*D

% Use Cholesky factor for Sigma, D ...
if nargin<3
   [Q,R] = qr(x,0);
   T = d' / R;
   
% ... or use the Cholesky factor for inv(Sigma), DI
else
   [Q,R] = qr(x*di,0);
   T = R \ eye(size(R,2));
end

a = T*T';


% --------- get indices of upper triangle of p-by-p matrix
function d = itriu(p)

d = ones(p*(p-1)/2,1);
d(1+cumsum(0:p-2)) = p+1:-1:3;
d = cumsum(d);
