function isOnEdge = pIsOnLabGridEdge(codistr, dim)
%pIsOnLabGridEdge Return true iff this lab is in processor row/column 1.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/06/08 13:25:37 $
if dim == 1
    isOnEdge = (codistr.pLabindexToProcessorRow(labindex) == 1);
elseif dim == 2
    isOnEdge = (codistr.pLabindexToProcessorCol(labindex) == 1);
else
    error('distcomp:codistributor2dbc:IsOnLabGridEdge:InvalidDimension', ...
          'Dimension must be 1 or 2.');
end
