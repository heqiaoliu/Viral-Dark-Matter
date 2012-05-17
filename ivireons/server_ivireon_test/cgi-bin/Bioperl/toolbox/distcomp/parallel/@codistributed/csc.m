function Y = csc(X)
%CSC Cosecant of codistributed array in radians
%   Y = CSC(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = csc(D)
%   end
%   
%   See also CSC, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:58:34 $

if nargin==0
  error('distcomp:codistributed:csc:NotEnoughInputs', ...
      'Not enough input arguments.');
end

Y = codistributed.pElementwiseUnaryOp(@csc, X);
