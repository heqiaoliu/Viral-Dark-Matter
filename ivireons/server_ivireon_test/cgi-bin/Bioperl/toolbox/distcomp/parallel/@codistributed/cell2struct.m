function [s] = cell2struct( c, fields, dim)
%CELL2STRUCT Convert codistributed cell array to structure array
%   S = CELL2STRUCT(C,FIELDS,DIM)
%   
%   Example:
%   spmd
%       N = 1000;
%       C = codistributed(repmat({rand(7); char(64+7)}, 1, N))
%       f = {'matrix','name'}
%       S = cell2struct(C,f,1)
%       classC = classUnderlying(C)
%       classS = classUnderlying(S)
%   end
%   
%   takes the 2-by-N codistributed cell array c and converts it into a
%   N-by-1 codistributed struct array s, with fields named 'matrix' and
%   'name'.
%   classC is 'cell' while classS is 'struct'.
%   
%   See also CELL2STRUCT, CODISTRIBUTED.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/05/14 16:50:57 $

dim = distributedutil.CodistParser.gatherIfCodistributed(dim);
fields = distributedutil.CodistParser.gatherIfCodistributed(fields);
if ~isa(c, 'codistributed')
    %If only the other arguments were distributed, we can now call the
    %regular function.
    s = cell2struct(c, fields, dim);
    return;
end

% This implementation only supports codistributor1d.
codistributed.pVerifyUsing1d('cell2struct', c); %#ok<DCUNK> private static

cDist = getCodistributor(c);
d = cDist.Dimension;
if (d == dim)
    error('distcomp:codistributed:cell2struct:invalidDimension', ...
          'Distributed CELL2STRUCT does not support folding the distributed dimension.');
else
    s = cell2struct(getLocalPart(c), fields, dim);
    %If the dimension is less than Dimension, then one dimension has been
    %"folded" away, thus need to decrement the Dimension.
    if (dim < d)
        d = d - 1;
    end
        s = codistributed.build(s, codistributor1d(d), 'obsolete:matchLocalParts');
end

end % End of cell2struct.

