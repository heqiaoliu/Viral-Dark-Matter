function tf = issparse( obj )
%ISSPARSE True for sparse distributed matrix
%   TF = ISSPARSE(D)
%   
%   Example:
%       N = 1000;
%       D = distributed.speye(N,N);
%       t = issparse(D)
%       f = issparse(full(D))
%   
%   returns t = true and f = false.
%   
%   See also ISSPARSE, DISTRIBUTED, DISTRIBUTED/SPEYE.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $   $Date: 2009/05/14 16:51:41 $

% Protect against broken distributed.
errorIfInvalid( obj );

tf = obj.SparseFlag;
end
