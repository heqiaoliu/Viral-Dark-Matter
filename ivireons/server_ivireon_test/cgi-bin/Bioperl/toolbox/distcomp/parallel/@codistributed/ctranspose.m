function A = ctranspose(A)
%' Complex conjugate transpose of codistributed array
%   E = D'
%   E = CTRANSPOSE(D)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = complex(codistributed.rand(N),codistributed.rand(N))
%       E = D'
%   end
%   
%   See also CTRANSPOSE, CODISTRIBUTED, CODISTRIBUTED/COMPLEX.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/12/03 19:00:51 $

A = transposetemplate(A, @ctranspose);
    

