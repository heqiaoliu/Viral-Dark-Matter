function Y = imag(X)
%IMAG Complex imaginary part of codistributed array
%   Y = IMAG(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       rp = 3 * codistributed.ones(N);
%       ip = 4 * codistributed.ones(N);
%       D = complex(rp, ip);
%       E = imag(D)
%   end
%   
%   See also IMAG, CODISTRIBUTED, CODISTRIBUTED/COMPLEX, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:59:08 $

Y = codistributed.pElementwiseUnaryOp(@imag, X);
