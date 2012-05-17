function varargout = hGlobalIndicesImpl(dist, dim, lab)
%hGlobalIndicesImpl The implementation of global indices without the error checking.
%
%   See also codistributor1d/globalIndices.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/07/18 15:50:37 $

part = dist.Partition;

if dim == dist.Dimension
    [varargout{1:nargout}] = partitionIndices(part, lab);
    return;
end

% We only arrive here if the dimension is not equal to the distribution
% dimension.  
gSize = dist.Cached.GlobalSize;
if dim > length(gSize)
    dimSize = 1;
else
    dimSize = gSize(dim);
end

if nargout <= 1
    varargout{1} = 1:dimSize;
elseif nargout == 2
    varargout{1} = 1;
    varargout{2} = dimSize;
else
    error('distcomp:hGlobalIndicesImpl:TooManyOutputArguments', ...
          'Too many output arguments.');
end

end % End of hGlobalIndicesImpl.
