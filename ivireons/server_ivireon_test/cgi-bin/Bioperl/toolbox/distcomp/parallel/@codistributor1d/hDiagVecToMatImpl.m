function [matLP, matDist] = hDiagVecToMatImpl(codistr, vecLP, k)
% hDiagVecToMatImpl:  Implementation of diag for codistributor1d with input
% vector and output matrix.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:40:24 $
    
    szVec = codistr.Cached.GlobalSize;

    if ~all(szVec)
        % This handles the empty edge cases of zeros(0, 1) or zeros(1, 0).
        matDist = codistributor1d(1, zeros(1,numlabs), [0, 0]);
        matLP = distributedutil.Allocator.create(matDist.hLocalSize(), vecLP);
        return
    end
    
    % The output matrix should be distributed along the maximum size dimension 
    % of the input vector) in order for it to be well-balanced across the labs.  
    [lenVec, distrDim] = max(szVec);
     
    m = lenVec + abs(k);
    matDist = codistributor1d(distrDim, codistributor1d.defaultPartition(m), [m, m]);
    
    [vecLP, codistr] = iAlignVectorWithMatrix(matDist, vecLP, k, codistr);    
    matLP = distributedutil.Allocator.create(matDist.hLocalSize(), vecLP);
    
    % Only the labs which store part of the vector must do something.
    if codistr.Partition(labindex) ~= 0
        k = matDist.pConvertGlobalDiagToLocal(k, labindex);
        
        % If k is a subdiagonal, it begins at row |k| + 1 and column 1 of the 
        % local part.  If k is a superdiagonal, it begins at row 1 and column
        % |k| + 1.  The main diagonal fits into either case, but we've chosen to 
        % treat it as a superdiagonal.
        diagStartRowCol = cell(1, 2);
        diagStartRowCol{1, (k < 0) + 1} = 1;
        diagStartRowCol{1, (k >= 0) + 1} = abs(k) + 1;
        
        % While we have the local k value for the lab, we cannot call the 
        % built-in diag on the local part.  That would fill in the correct 
        % diag in the local part, but it would also have the side effect 
        % of resizing matLP to be square.  We want to fill in the
        % appropriate diagonal while keeping the size determined by the
        % call to hLocalSize() so we use linear indexing to fill in matLP.
        linIndex = sub2ind(size(matLP), diagStartRowCol{:}); 
        matLP(linIndex: size(matLP, 1) + 1: linIndex + (length(vecLP) - 1)*(size(matLP, 1) + 1)) = vecLP;
    end

end % End of hDiagVecToMatImpl.

%--------------

function [vecLP, codistr] = iAlignVectorWithMatrix(matDist, vecLP, k, origVecDistr)
% iAlignVectorWithMatrix:  This subfunction creates a new partition of 
% the input vector so that the DIAG output matrix will be partitioned
% as evenly as possible.
%    
% Input:  default distribution for output matrix DIAG should return, initial 
%         vector local part, and diagonal of interest (k).  
% Output: new vector local part and its corresponding codistributor that 
%         allows the diag function to proceed without any global communication.
%
% Example:  input:       
%                          |  Lab 1  |  Lab 2  |  Lab 3  | Lab 4  |
%                   vecLP  |    1    |    2    |         |        |
%                   k = 2; matDist has Dimension = 2, Partition = [1 1 1 1], 
%                   Cached.GlobalSize = [4, 4] 
%
%    
%           output:        |  Lab 1  |  Lab 2  |  Lab 3  | Lab 4  |
%                   vecLP  |         |         |    1    |    2   |
%                   codistr has Dimension  = 2, Partition = [0 0 1 1], and
%                   Cached.GlobalSize = [1, 2]
%    
% We need to repartition the vector so that it matches the output matrix
% partitioning.  We start by setting up a new vector partition that is exactly
% the same as the matrix partition.  However, for k ~= 0, the vector will have 
% fewer elements than the matrix partition allows for.  The boolean flag 
% endOfVecAlignedWithLastLab determines whether the vector is inserted into the 
% partition as a chunk of data with its last element filling the last position on 
% the last lab.  Otherwise the vector is inserted into the partition so that its 
% first element fills the first position on the first lab.
    
    vecPartNew = matDist.Partition;  
    
    endOfVecAlignedWithLastLab = ((k > 0) && (matDist.Dimension == 2)) || ...
                                 ((k < 0) && (matDist.Dimension == 1));
    
    if endOfVecAlignedWithLastLab
        % We should create the vector partition so that it matches the matrix 
        % partition starting with the last lab, not the first.
        vecPartNew = fliplr(vecPartNew);
    end
 
    % cumPart tracks the cumulative number of elements that can  be stored. 
    cumPart = [0 cumsum(vecPartNew)];
    
    % The variable fillUntil is the point at which the vector and matrix 
    % partitions begin to differ. We only modify the parts of the 
    % vector partitioning that differ from the matrix partitioning.
    fillUntil = find(cumPart >= max(origVecDistr.Cached.GlobalSize), 1);
    vecPartNew(1, fillUntil - 1) = max(origVecDistr.Cached.GlobalSize) - cumPart(fillUntil-1);
    vecPartNew(1, fillUntil:end) = 0;
    
    if endOfVecAlignedWithLastLab
        % We created the vector partitioning in reverse. We need to flip 
        % it back before using it. 
        vecPartNew = fliplr(vecPartNew);
    end
      
    % Create a new vector codistributor based on the new partitioning.
    codistr = codistributor1d(matDist.Dimension, vecPartNew, origVecDistr.Cached.GlobalSize);
   
    % redistribute vector 
    [vecLP, ~] = distributedutil.Redistributor.redistribute(origVecDistr, vecLP, codistr);
end % End of iAlignVectorWithMatrix.

%--------------
