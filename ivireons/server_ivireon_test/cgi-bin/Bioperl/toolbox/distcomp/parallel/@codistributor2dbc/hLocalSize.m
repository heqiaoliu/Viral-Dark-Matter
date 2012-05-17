function szs = hLocalSize(codistr, labidx)
%hLocalSize  Return the size of the local part of the codistributed array.
%   This method can only be called on a completely specified codistributor.
%   szs = hLocalSize(codistr) Returns the size of the local part.
%
%   See also codistributor2dbc/isComplete.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/07/18 15:50:43 $

if ~codistr.isComplete()
    error('distcomp:codistributor2dbc:hLocalSizeNotComplete', ...
          'Codistributor must be complete when getting the local size.');
end

if nargin < 2
    labidx = labindex;
end

szs = zeros(1, 2);
for dim = 1:2
    [e, f] = codistr.globalIndices(dim, labidx);
    % Calculate the sum of the lengths of all of the extents, i.e.
    % sum of (f(i) - e(i) + 1)
    szs(dim) = sum(diff([e(:)'; f(:)']) + 1);
end

% We should not remove any trailing ones in the size vector because it is only
% of length 2.
end % End of hLocalSize.
