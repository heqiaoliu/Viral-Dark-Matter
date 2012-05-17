function M = blkdiag(M1,M2)
% Fast version for double matrices.

%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/31 18:36:01 $
[ny1,nu1] = size(M1);
[ny2,nu2] = size(M2);
M = zeros(ny1+ny2,nu1+nu2);
M(1:ny1,1:nu1) = M1;
M(ny1+1:ny1+ny2,nu1+1:nu1+nu2) = M2;
