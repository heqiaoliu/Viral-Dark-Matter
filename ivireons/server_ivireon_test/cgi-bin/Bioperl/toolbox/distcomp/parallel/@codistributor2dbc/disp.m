function disp(dist)
%DISP Display codistributor
%
%   See also DISP, CODISTRIBUTOR

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/15 23:00:04 $

dispNames = {'BlockSize', ...
             'LabGrid', ...
             'Orientation', ...
             'Cached.GlobalSize'};
dispValues = {int2str(dist.BlockSize), ...
              mat2str(dist.LabGrid), ....
              dist.Orientation, ....
              mat2str(dist.Cached.GlobalSize)};

AbstractCodistributor.pDispNamesAndValues(dispNames, dispValues);

end % End of disp.
