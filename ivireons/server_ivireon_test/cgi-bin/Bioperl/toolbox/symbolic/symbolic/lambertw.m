function W = lambertw(k,X)
%LAMBERTW Lambert's W function.
%   W = LAMBERTW(X) is the solution to w*exp(w) = x.
%   W = LAMBERTW(K,X) is the K-th branch of this multi-valued function.
%   Reference: Robert M. Corless, G. H. Gonnet, D. E. G. Hare,
%   D. J. Jeffrey, and D. E. Knuth, "On the Lambert W Function",
%   Advances in Computational Mathematics, volume 5, 1996, pp. 329-359.

%   More information available from:
%   http://www.apmaths.uwo.ca/~rcorless/frames/PAPERS/LambertW

%   Copyright 1993-2007 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2009/03/09 20:41:34 $

if nargin == 1
   W = double(lambertw(sym(k)));
else
   W = double(lambertw(sym(k),sym(X)));
end
