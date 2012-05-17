function szs = hLocalSize(codistr, labidx)
%hLocalSize  Return the size of the local part of the codistributed array.
%   This method can only be called on a completely specified codistributor.
%   szs = hLocalSize(codistr) Returns the size of the local part.
%
%   See also codistributor1d/isComplete

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/14 03:53:33 $

if ~codistr.isComplete()
    error('distcomp:codistributor1d:hLocalSizeNotComplete', ...
          'Codistributor must be complete when obtaining the local size.');
end

if nargin < 2
    labidx = labindex;
end

szs = codistr.Cached.GlobalSize;
if codistr.Dimension <= length(szs)
    szs(codistr.Dimension) = codistr.Partition(labidx);    
else
    if codistr.Partition(labidx) == 0
        % Expand the size by 1's as necessary until we reach the 
        % distribution dimension.
        szs(end + 1:codistr.Dimension - 1) = 1;
        szs(codistr.Dimension) = 0;
    % else
    % Nothing needed to do on the lab that has the whole array because it has an
    % implicit size of 1 in the distribution dimension.
    end
end

% It is possible that the partition is such that we only have 1 slice in the
% distribution dimension, so we remove all trailing ones from the local size.
szs = distributedutil.Sizes.removeTrailingOnes(szs);

end % End of hLocalSize.
