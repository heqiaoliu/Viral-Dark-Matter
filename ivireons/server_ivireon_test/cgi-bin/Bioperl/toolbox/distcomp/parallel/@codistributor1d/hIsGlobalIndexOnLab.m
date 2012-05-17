function tf = hIsGlobalIndexOnLab(codistr, dim, gIndexInDim, lab)
%hIsGlobalIndexOnLab  Implementation for codistributor1d.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/18 15:50:38 $

[e, f] = codistr.hGlobalIndicesImpl(dim, lab);
tf = (e <= gIndexInDim & gIndexInDim <= f);
end % End of hIsGlobalIndexOnLab.
