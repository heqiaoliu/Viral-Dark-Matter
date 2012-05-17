function x = finv(p,v1,v2);
%FINV   Inverse of the F cumulative distribution function.
%   X=FINV(P,V1,V2) returns the inverse of the F distribution 
%   function with V1 and V2 degrees of freedom, at the values in P.
%
%   The size of X is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.    
%
%   See also FCDF, FPDF, FRND, FSTAT, ICDF.

%   References:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.6.2

%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:13:47 $

if nargin <  3, 
    error('stats:finv:TooFewInputs','Requires three input arguments.'); 
end

[errorcode p v1 v2] = distchck(3,p,v1,v2);

if errorcode > 0
    error('stats:finv:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Weed out any out of range parameters or probabilities.
okV = (0 < v1 & v1 < Inf) & (0 < v2 & v2 < Inf);
k = (okV & (0 <= p & p <= 1));
allOK = all(k(:));

% Fill in NaNs for out of range cases.
if ~allOK
    if isa(p,'single') || isa(v1,'single') || isa(v2,'single')
       x = NaN(size(k),'single');
    else
       x = NaN(size(k));
    end

    % Remove the out of range cases.  If there's nothing remaining, return.
    if any(k(:))
        if numel(p) > 1, p = p(k); end
        if numel(v1) > 1, v1 = v1(k); end
        if numel(v2) > 1, v2 = v2(k); end
    else
        return;
    end
end

z = betaincinv(p,v2/2,v1/2,'upper');
xk = (v2 ./ z - v2) ./ v1;

% Broadcast the values to the correct place if need be.
if allOK
    x = xk;
else
    x(k) = xk;
end
