function [vecLP, vecDist] = hDiagMatToVecImpl(codistr, matLP, k)
% hDiagMatToVecImpl:  Implementation of diag for codistributor1d with input
% matrix and output vector.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/10/12 17:28:14 $

    vecDist = iCreateVectorCodistributor(codistr, k);
    vecLPSize = vecDist.hLocalSize();
    
    if ~all(vecLPSize)
        % There is nothing to be filled in, so we return an empty vecLP.
        vecLP = distributedutil.Allocator.create(vecLPSize, matLP);
        return
    end
    
    % We get the local diagonal value before we fill in the vector LP.
    k = codistr.pConvertGlobalDiagToLocal(k, labindex);
 
    if isvector(matLP)
        % When the matrix local part is actually a vector, we cannot 
        % call the built-in diag directly. The built-in would return a 
        % matrix when instead we want the single entry of the diagonal 
        % that intersects this local part.
        
        % Since k is a local diagonal number, for a vector it is 
        % equivalent to the |k| + 1 vector element.
        vecLP = matLP(abs(k) + 1); 
    else
        vecLP = diag(matLP, k);
    end
end % End of hDiagMatToVecImpl.

function vecDist = iCreateVectorCodistributor(codistr, k)
% iCreateVectorCodistributor: Create the codistributor for the vector output
% of hDiagMatToVecImpl.

    dim = codistr.Dimension;
    pMat = codistr.Partition;
    szMat = codistr.Cached.GlobalSize;
       
    % We need to treat three different cases: 
    % (1) Empty input matrix ( zeros(0,0); zeros(0, n) and zeros(n, 0) where
    %     n > 1; or [] )
    % (2) Nontrivial matrix
    %     (a) Distribution dimension > 2 
    %     (b) Distribution dimension of 1 or 2
    
    if ~all(szMat)
        gsize = [0, 0];
        % The dimension, dim, remains the same for empty matrices.  When 
        % dim > 2, the entire 2-D matrix is stored on one lab and the global 
        % size of the output vector doesn't affect the partition.  For 
        % dim <= 2, however, the partition should be zeros over all labs in 
        % order to agree with gsize.
        if dim <= length(szMat)
            pMat = zeros(1, numlabs);
        end
    elseif dim > 2
        % Calculate the global size of the resulting column vector.
        gsize = ones(1, 2);
        sizeInDimThatIntersectsStartOfDiag = szMat((k > 0) + 1);  
        sizeInOtherDim = szMat((k <= 0) + 1);
        gsize(1) = max(0, min(sizeInDimThatIntersectsStartOfDiag - abs(k), sizeInOtherDim)); 
    else
        % We create a matrix, szMatLPs, that holds the size of the local part 
        % on each lab.  
        szMatLPs = repmat(szMat, numlabs, 1);
        szMatLPs(:, dim) = pMat'; 
   
        % We compute the local diagonal number on each lab.  This information is then
        % used to compute the length of the vector local part on each lab.
        localKVals = codistr.pConvertGlobalDiagToLocal(k, 1:numlabs);
   
        % We calculate the number of vector elements which are stored on each lab.  
        sizeInDimThatIntersectsStartOfDiag = zeros(numlabs, 1); 
        sizeInOtherDim = zeros(numlabs, 1);
       
        for n = 1:numlabs
            sizeInDimThatIntersectsStartOfDiag(n) = szMatLPs(n, (localKVals(n) > 0) + 1);  
            sizeInOtherDim(n) = szMatLPs(n, (localKVals(n) <= 0) + 1);
        end
        
        lenVecLPs = max(0, min(sizeInDimThatIntersectsStartOfDiag - abs(localKVals), sizeInOtherDim));

        % Create a column vector distributed by rows.
        dim = 1;
        pMat = lenVecLPs';
        gsize = [sum(lenVecLPs), 1];
    end
    % This information is then used to construct the vector codistributor.
    vecDist = codistributor1d(dim, pMat, gsize);
end % End of iCreateVectorCodistributor.
    
%-------------------------
