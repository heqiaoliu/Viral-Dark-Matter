function y = fpdf(x,v1,v2)
%FPDF   F probability density function.
%   Y = FPDF(X,V1,V2) returns the F distribution probability density
%   function with V1 and V2 degrees of freedom at the values in X.
%
%   The size of Y is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.    
%
%   See also FCDF, FINV, FRND, FSTAT, PDF.

%   References:
%      [1] J. K. Patel, C. H. Kapadia, and D. B. Owen, "Handbook
%      of Statistical Distributions", Marcel-Dekker, 1976.

%   Copyright 1993-2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:13:49 $

if nargin < 3, 
    error('stats:fpdf:TooFewInputs','Requires three input arguments.'); 
end

[errorcode x v1 v2] = distchck(3,x,v1,v2);

if errorcode > 0
    error('stats:fpdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize Y to zero; it stays zero for x<0
if isa(x,'single') || isa(v1,'single') || isa(v2,'single')
   y = zeros(size(x),'single');
else
   y = zeros(size(x));
end

% Special case for invalid parameters
k1 = (v1 <= 0 | v2 <= 0 | isnan(x));
if any(k1(:))
    y(k1) = NaN;
end

% Regular case with valid parameters and positive x
k = (x > 0 & v1 > 0 & v2 > 0 & ~isnan(x));
if any(k(:))
    xk = x(k);
    temp = (v1(k) ./ v2(k)) .^ (v1(k)/2) .* xk .^ ((v1(k)-2)/2) ./ beta(v1(k)/2,v2(k)/2);
    y(k) = temp .* (1 + v1(k) ./v2(k) .* xk) .^ (-(v1(k) + v2(k)) / 2);
end

% Special case at x==0, result depends only on the value of v1
k = (x==0) & (v1>0) & (v2>0);
if any(k)
    y(k & v1==2) = 1;
    y(k & v1<2) = Inf;
    y(k & v1>2) = 0;
end
