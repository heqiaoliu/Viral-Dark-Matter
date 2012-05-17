function localLinInd = hFindDiagElementsInLocalPart(codistr)
%hFindDiagElementsInLocalPart Return the local linear indices of the diagonal 
% elements of the local part for codistributor1d.
% Note that this is restricted to finding the local diagonal elements of a
% 2D matrix.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/05/03 16:06:12 $
 
globalSz = codistr.Cached.GlobalSize;
par = codistr.Partition;
[e,f] = codistr.globalIndices(codistr.Dimension, labindex);
cumPar = cumsum(par);
switch codistr.Dimension
    case 1
        offset = 0;
        if labindex > 1
            offset = par(labindex)*cumPar(labindex-1);
        end
        localSz = codistr.hLocalSize();
        localLinInd = offset+1 : par(labindex)+1 : min(prod(localSz),par(labindex)^2+offset);
    case 2
        if e <= globalSz(1)
            if f <= globalSz(1)
                localLinInd = e:globalSz(1)+1:globalSz(1)*par(labindex);
            else
                if (labindex > 1)
                    offset = cumPar(labindex-1);
                else
                    offset = 0;
                end
                localLinInd = e:globalSz(1)+1:globalSz(1)*(globalSz(1)-offset);
            end
        else
            localLinInd = [];
        end
    otherwise
        if par(labindex) ~= 0
            localLinInd = 1:globalSz(1)+1:prod(globalSz);
        else
            localLinInd = [];
        end
end
