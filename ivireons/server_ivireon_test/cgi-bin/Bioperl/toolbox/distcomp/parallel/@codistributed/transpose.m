function A = transpose(A)
%.' Transpose of codistributed array
%   E = D.'
%   E = TRANSPOSE(D)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.rand(N);
%       E = D.'
%   end
%   
%   See also TRANSPOSE, CODISTRIBUTED, CODISTRIBUTED/RAND.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/12/03 19:01:05 $

A = transposetemplate(A, @transpose);

