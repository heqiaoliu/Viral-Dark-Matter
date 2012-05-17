function xy = cov(x,varargin)
%COV Covariance matrix.
%   COV(X), if X is a vector, returns the variance.  For matrices,
%   where each row is an observation, and each column a variable,
%   COV(X) is the covariance matrix.  DIAG(COV(X)) is a vector of
%   variances for each column, and SQRT(DIAG(COV(X))) is a vector
%   of standard deviations. COV(X,Y), where X and Y are matrices with
%   the same number of elements, is equivalent to COV([X(:) Y(:)]). 
%   
%   COV(X) or COV(X,Y) normalizes by (N-1) if N>1, where N is the number of
%   observations.  This makes COV(X) the best unbiased estimate of the
%   covariance matrix if the observations are from a normal distribution.
%   For N=1, COV normalizes by N.
%
%   COV(X,1) or COV(X,Y,1) normalizes by N and produces the second
%   moment matrix of the observations about their mean.  COV(X,Y,0) is
%   the same as COV(X,Y) and COV(X,0) is the same as COV(X).
%
%   The mean is removed from each column before calculating the
%   result.
%
%   Class support for inputs X,Y:
%      float: double, single
%
%   See also CORRCOEF, VAR, STD, MEAN.

%   Copyright 1984-2010 The MathWorks, Inc. 
%   $Revision: 5.16.4.9 $  $Date: 2010/02/25 08:08:29 $

if nargin==0 
  error('MATLAB:cov:NotEnoughInputs','Not enough input arguments.'); 
end
if nargin>3
  error('MATLAB:cov:TooManyInputs', 'Too many input arguments.'); 
end
if ~ismatrix(x)
  error('MATLAB:cov:InputDim', 'Inputs must be 2-D.'); 
end

nin = nargin;

% Check for cov(x,flag) or cov(x,y,flag)
if nin==3
  flag = varargin{end};
  if ~iscovflag(flag)
    error('MATLAB:cov:notScalarFlag', 'Third input must be 0 or 1.');
  end   
  nin = nin - 1;
elseif nin==2 && iscovflag(varargin{end})
  flag = varargin{end};
  nin = nin - 1;
else
  flag = 0;
end

scalarxy = false; % cov(scalar,scalar) is an ambiguous case
if nin == 2
  y = varargin{1}; 
  if ~ismatrix(y)
     error('MATLAB:cov:InputDim', 'Inputs must be 2-D.'); 
  end
  x = x(:);
  y = y(:);
  if length(x) ~= length(y), 
    error('MATLAB:cov:XYlengthMismatch', 'The number of elements in x and y must match.');
  end
  scalarxy = isscalar(x) && isscalar(y);
  x = [x y];
end

if isvector(x) && ~scalarxy
  x = x(:);
end

[m,n] = size(x);
if isempty(x);
  if (m==0 && n==0)
      xy = NaN(class(x));
  else
      xy = NaN(n,class(x));
  end
  return;
end    

if m == 1  % One observation
    
  % For single data, unbiased estimate of the covariance matrix is not defined. 
  % Return the second moment matrix of the observations about their mean.
  xy = zeros(n,class(x)); 
  
else
    
  xc = bsxfun(@minus,x,sum(x,1)/m);  % Remove mean
  if flag
    xy = (xc' * xc) / m;
  else
    xy = (xc' * xc) / (m-1);
  end

end

function y = iscovflag(x)
% flag for cov must be 0 or 1. 
  y = isscalar(x) && (x==0 || x==1);
