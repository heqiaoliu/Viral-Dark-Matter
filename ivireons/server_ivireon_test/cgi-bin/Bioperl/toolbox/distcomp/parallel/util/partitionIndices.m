function [e,f] = partitionIndices(part,lab)
%PARTITIONINDICES   Local span of a partition
%   The local span of a partition is the index range in the distributed
%   dimension for the associated codistributed array on a particular lab.
%
%   With one input argument and one output argument
%      K = PARTITIONINDICES(PART)
%   returns a vector K so that LOCALPART(D) = D(...,K,...) on the current lab,
%   where PART = a nonnegative vector of length NUMLABS.
%
%   With one input argument and two output arguments
%      [E,F] = PARTITIONINDICES(PART)
%   returns two integers E and F so that LOCALPART(D) = D(...,E:F,...) on the
%   current lab, where PART = a nonnegative vector of length NUMLABS.
%
%   With two input arguments and one output argument
%      K = PARTITIONINDICES(PART,LAB)
%   returns a vector K so that LOCALPART(D) = D(...,K,...) on the specified
%   lab, where PART = a nonnegative vector of length NUMLABS.
%
%   With two input arguments and two output arguments
%      [E,F] = PARTITIONINDICES(PART,LAB)
%   returns two integers E and F so that getLocalPart(D) = D(...,E:F,...) on the
%   specified lab, where PART = a nonnegative vector of length NUMLABS.
%
%   In all of the above syntaxes, if the partition is unspecified, then K,
%   E and F are -1.
%
%   Example: with numlabs = 4
%      part = [6 6 5 5]
%      On lab 1, K = partitionIndices(part) returns K = 1:6.
%      On lab 2, [E,F] = partitionIndices(part) returns E = 7, F = 12.
%      K = partitionIndices(part,3) returns K = 13:17.
%      [E,F] = partitionIndices(part,4) returns E = 18, F = 22.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/03/25 21:57:01 $

if nargin < 2
   lab = labindex;
end
if isscalar(part) && part==-1
    e = -1;
    f = -1;
    return;
end
if lab < 1
   f = 0;
   e = 1;
elseif lab > numlabs
   f = sum(part);
   e = f+1;
else
   f = sum(part(1:lab));
   e = f-part(lab)+1;
end
if nargout < 2
   e = e:f;
end
