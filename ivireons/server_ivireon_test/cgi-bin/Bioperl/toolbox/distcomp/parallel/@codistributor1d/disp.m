function disp(dist)
%DISP Display codistributor
%
%   See also DISP, CODISTRIBUTOR

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/04/15 22:59:31 $

if ~isequal(dist.Dimension, codistributor1d.unsetDimension)
    dimVal = int2str(dist.Dimension);
else
    dimVal = 'last non-singleton';
end
if ~isequal(dist.Partition, codistributor1d.unsetPartition)
    parVal = mat2str(dist.Partition);
else
    parVal = 'default';
end

dispNames = {'Dimension', ...
             'Partition', ...
             'Cached.GlobalSize'};

dispValues = {dimVal, ...
              parVal, ...
              mat2str(dist.Cached.GlobalSize)};

AbstractCodistributor.pDispNamesAndValues(dispNames, dispValues);

end % End of disp.
