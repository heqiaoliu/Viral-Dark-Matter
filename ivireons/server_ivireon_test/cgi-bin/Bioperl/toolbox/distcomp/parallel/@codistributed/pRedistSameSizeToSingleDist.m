function [cellOfLPs, targetDist] = pRedistSameSizeToSingleDist(inputCells)
%pRedistSameSizeToSingleDist Redistribute distributed and replicated cell 
%   arrays of the same size to the same distribution scheme.  
%   
%   [cellOfLPs, targetDist] = pRedistSameSizeToSingleDist(inputCells) 
%   distributes all elements of inputCells according to the same 
%   codistributor, targetDist, and returns a cell array of the local 
%   parts, cellOfLPs.  At least one element of inputCells must be 
%   codistributed.


%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:40:44 $

    % This function assumes that all elements of inputCells have the 
    % same size.  Therefore the redistributions should always succeed.   
        
    % Get target codistributor for several input cells.  The cells may be 
    % either distributed or replicated, and this is tracked by the variable
    % isDistributedCells.
    
    isDistributedCells = cellfun(@(x) iscodistributed(x), inputCells);  
    firstDistrCell = find(isDistributedCells, 1);
    
    if isempty(firstDistrCell)
        error('distcomp:codistributed:pRedistSameSizeToSingleDist:AllReplicated', ...
              'At least one input argument should be codistributed.');
    end
    
    targetDist = getCodistributor(inputCells{firstDistrCell});

    % Get the local parts of all cells. iGetLP (re)distributes if necessary 
    % so cellOfLPs are all using targetDist.
    cellOfLPs = cellfun(@(x) iGetLP(targetDist, x), inputCells, ...
                        'UniformOutput', false);
end % End pRedistSameSizeToSingleDist

%------------------------------------
function localA = iGetLP(targetDist, A)
    if iscodistributed(A)
        % redistribute to targetDist, getting localA as result
        A = redistribute(A, targetDist);
        localA = getLocalPart(A);
    else
        % build from replicated
        localA = targetDist.hBuildFromReplicatedImpl(0, A);
    end   
end % End of iGetLP

            
