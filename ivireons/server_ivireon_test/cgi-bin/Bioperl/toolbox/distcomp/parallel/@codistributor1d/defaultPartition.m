function p = defaultPartition(n)
%codistributor1d.defaultPartition Default partition across the labs
%   codistributor1d.defaultPartition is the basis for DRANGE loops (Distributed
%   RANGE for-loops) and the default distribution of codistributed arrays.
%
%   P = codistributor1d.defaultPartition(N) is a vector of length NUMLABS
%   with SUM(P) = N. Most of the elements of P are equal to
%   FLOOR(N/NUMLABS) but the first REM(N,NUMLABS) elements of P are equal
%   to CEIL(N/NUMLABS). 
%
%   Example:
%   With numlabs = 4
%
%     spmd
%         p = codistributor1d.defaultPartition(10)
%     end
%
%   returns p = [3 3 2 2] a vector of length 4 with sum(p) = 10.
%
%   This same p is used implicitly in a parallel for loop over 10 iterates:
%
%     spmd
%         x = [];
%         for i = drange(1 : 10)
%            x = [x i];
%         end
%         x
%     end
%
%   returns length p(labindex) vectors x on each lab.
%
%   The same p is also the default partition for a codistributed matrix with
%   10 columns:
%
%     spmd
%         D = eye(10,codistributor('1d'))
%         dist = getCodistributor(D);
%         p = dist.Partition;
%     end
%
%   See also NUMLABS, LABINDEX, CODISTRIBUTED, CODISTRIBUTED/COLON
%   CODISTRIBUTOR1D/EYE.

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/15 22:59:30 $

error(nargchk(1, 1, nargin, 'struct'));

% Note that in the degenerate case where n equals 0, we return
% codistributor1d.unsetPartition.

p = zeros(1,numlabs);
p(:) = floor(double(n)/numlabs);
p(1:rem(n,numlabs)) = ceil(double(n)/numlabs);

end % End of defaultPartition.
