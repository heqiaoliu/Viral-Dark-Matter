function tf = isreal(X)
%ISREAL True for real codistributed array
%   TF = ISREAL(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       rp = 3 * codistributed.ones(N);
%       ip = 4 * codistributed.ones(N);
%       D = complex(rp, ip);
%       f = isreal(D)
%   end
%   
%   returns f = false.
%   
%   See also ISREAL, CODISTRIBUTED, CODISTRIBUTED/COMPLEX, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/08/11 15:40:37 $

% Check that isreal is true on all processors.

xDist = getCodistributor(X);
localX = getLocalPart(X);

tf = xDist.hIsrealImpl(localX);
