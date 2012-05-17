function J = jordbloc(n, lambda, classname)
%JORDBLOC Jordan block.
%   GALLERY('JORDBLOC',N,LAMBDA) is the N-by-N Jordan block
%   with eigenvalue LAMBDA.  LAMBDA = 1 is the default.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2005/11/18 14:15:04 $

if isempty(lambda), lambda = ones(classname); end

J = lambda*eye(n,classname) + diag(ones(n-1,1,classname),1);
