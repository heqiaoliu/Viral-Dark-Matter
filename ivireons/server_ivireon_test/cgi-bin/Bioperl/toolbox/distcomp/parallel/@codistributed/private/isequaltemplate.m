function tf = isequaltemplate(F, varargin)
%ISEQUALTEMPLATE Template for ISEQUAL and ISEQUALWITHEQUALNANS

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/08/11 15:40:30 $

    %check if all inputs have the same size
    varSizes = cellfun(@size, varargin, 'UniformOutput', false);
    isSizeCompatible = isequal(varSizes{:});

    if ~isSizeCompatible
        tf = false;
        return
    end

    % We determine the target codistributor to use for all the input cell
    % arrays.  Any replicated cell arrays will be distributed according to 
    % this target codistributor, while the codistributed arrays will be 
    % redistributed if necessary.  The local parts are returned.
    [cellLPs, targetDist] = codistributed.pRedistSameSizeToSingleDist(varargin); %#ok<DCUNK>

    tf = targetDist.hIsequaltemplateImpl(F, cellLPs);  
end
