function dist = hBuildFromLocalPartImpl(dist, L, buildOption)
; %#ok<NOSEM> % Undocumented
  % Implementation of hBuildFromLocalPartImpl for codistributor2dbc.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/07/14 03:53:40 $

if ~distributedutil.Allocator.supportsCreation(L)
    error('distcomp:codistributor2dbc:BuildFromLocalPart:UnsupportedClass',...
          ['Class %s is not supported as the underlying class for ' ...
           'codistributed arrays.'], class(L));
end

% The 2dbc codistributor does not support matching the local parts.
if buildOption == distributedutil.BuildOption.MatchLocalParts
    error('distcomp:codistributor2dbc:build:InvalidBuildOption', ...
          'Codistributor2dbc does not support matching the local parts.');
end

if buildOption ~= distributedutil.BuildOption.CalculateSize ...
        && ~dist.isComplete()
    error('distcomp:codistributor2dbc:build:IncompleteCodistributor', ...
              ['Codistributor must be complete when building a codistributed ', ...
               'array from its local parts.']);
end
allowCommunication = (buildOption ~= distributedutil.BuildOption.NoCommunication);

lbgrid = dist.LabGrid;
blksize = dist.BlockSize;
siz = dist.Cached.GlobalSize;

% L can be a MATLAB array of any class, sparsity, complexity and size.
% All except complexity must match across all labs. 
if allowCommunication
    if ~isreplicated({'hBuildFromLocalPartImpl', class(L), issparse(L), ...
                      class(dist), lbgrid, blksize, siz})
        error('distcomp:codistributed:attributeMismatch', ...
              ['Local part must have the same class and', ...
               ' sparsity on all labs. All other arguments also need to ' ...
               'be replicated.']);
    end
end 

if buildOption == distributedutil.BuildOption.CalculateSize
    gsize = gop(@plus, size(L))./[lbgrid(2) lbgrid(1)];
    dist = dist.hGetCompleteForSize(gsize);
end

locSize = dist.hLocalSize();
if ~isequal(locSize, size(L))
    error('distcomp:codistributed:sizeMismatch2DimSize', ...
          ['Sizes of local part incompatible with specified ', ...
           'codistributor.  Expected size of local part was %s, ' ...
           'but actual size was %s.'], ...
          num2str(locSize), num2str(size(L)));
end

end % End of hBuildFromLocalPartImpl.
