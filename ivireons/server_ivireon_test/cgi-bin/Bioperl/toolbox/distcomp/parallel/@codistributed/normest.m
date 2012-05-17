function nrm = normest(A)
%NORMEST Estimate the codistributed matrix 2-norm
%   N = NORMEST(D)
%   
%   Limitations: Matrix NORMEST will return slightly different results for the
%   same matrix distributed over a different number of labs, or distributed in
%   a different manner.
%   
%   Example:
%   spmd
%       N = 1000;
%       D = diag(codistributed.colon(1,N))
%       n = normest(D)
%   end
%   
%   returns n = 1000.
%   
%   See also NORMEST, CODISTRIBUTED, CODISTRIBUTED/COLON, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/05/14 16:51:13 $

if ndims(A) > 2 
    error('distcomp:codistributed:normest:notVectorOrMatrix',...
          'Input must be a vector or a matrix.')
end
    
if all(size(A) > 1)
   % Matrix
   if isempty(getLocalPart(A))
       % artificially set the norm to be as small as possible
       localEstNorm = 0;
   else
       % actually estimate the norm
       localEstNorm = normest(getLocalPart(A));
   end
   nrm = gop(@max, localEstNorm);
else
   % Vector
   if isempty(getLocalPart(A))
       % artificially set the norm to be 0 since no data exists
       localTwoNorm = 0;
   else
       % actually calculate the two norm
       localTwoNorm = norm(getLocalPart(A));
   end
   nrm = gop(@hypot, localTwoNorm);
end
