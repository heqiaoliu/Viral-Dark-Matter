function flag = isreplicated(x)
%ISREPLICATED True for a replicated array
%   TF = ISREPLICATED(X) returns true for a replicated array and false
%   otherwise.
%
%   Note: ISREPLICATED(X) requires checking for equality of the array X
%   across all labs. This may be extremely time and communication
%   intensive. ISREPLICATED is most useful for debugging or error checking
%   small arrays. A distributed array is not replicated.
%
%   Example:
%      A = magic(3)
%      t = isreplicated(A) % returns t = true
%      B = magic(labindex)
%      f = isreplicated(B) % returns f = false
%
%   See also CODISTRIBUTED.

%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2008/08/26 18:14:01 $

y = labBroadcast(1,x);
flag = gop(@and,isequalwithequalnans(x,y) && ...  % numeric value
                strcmp(class(x),class(y)) && ...  % class
                issparse(x) == issparse(y));      % sparsity
