function BLP = redistributeInto(Acodistr, ALP, Bcodistr, BLP)
% Redistribution between two arbitrary tensor product codistributors.
% Acodistr and Bcodistr must be complete and support global indices, and
% Acodistr.Cached.GlobalSize must equal Bcodistr.Cached.GlobalSize.

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2009/09/23 13:59:34 $

% Since the inputs are tensor product codistributors, we get a complete
% understanding of them by the global indices in the dimensions dims(1), ...,
% dims(end).
dims = unique([Acodistr.hGetDimensions(), Bcodistr.hGetDimensions()]);
ourSrcInd = cell(1, length(dims));
ourDestInd = cell(1, length(dims));
for i = 1:length(dims)
    ourSrcInd{i} = Acodistr.hGlobalIndicesImpl(dims(i), labindex);
    ourDestInd{i} = Bcodistr.hGlobalIndicesImpl(dims(i), labindex);
end

% Prepare the substructs for sending and receiving bits of the local part.
indLen = max([ndims(ALP), ndims(BLP), dims]);
aidx = substruct('()', repmat({':'}, 1, indLen));
bidx = substruct('()', repmat({':'}, 1, indLen));

% Use the standard all-to-all communication pattern where we send to our right
% and receive from our left.
for offset = 0:(numlabs-1)
    sendToLab = mod( labindex + offset - 1, numlabs ) + 1;
    recvFromLab  = mod( labindex - offset - 1, numlabs ) + 1;
    
    % Identify the portion of ALP that sendToLab needs to get.  
    % We do this by getting intersection of the global indices that we have
    % from A with the global indices that sendToLab will store in B.  Since
    % the intersection is returned as a logical vector of same length as
    % our global indices into A, we can use the intersection to index
    % directly into ALP.
    for i = 1:length(dims)
        aidx.subs{dims(i)} = Bcodistr.hIsGlobalIndexOnLab(dims(i), ...
                                                          ourSrcInd{i}, ...
                                                          sendToLab);
    end
    toSend = subsref(ALP, aidx);

    % Identify the portion of BLP we can get from recvFromLab.
    for i = 1:length(dims)
        bidx.subs{dims(i)} = Acodistr.hIsGlobalIndexOnLab(dims(i), ...
                                                          ourDestInd{i}, ...
                                                          recvFromLab);
    end

    % Data exchange.
    data = labSendReceive(sendToLab, recvFromLab, toSend);
    % If data is empty, there is nothing for us to do.  Guard against it
    % because subsasgn doesn't allow a null assignment with more than one
    % non-colon index.
    if ~isempty(data)
        subsasgn(BLP, bidx, data);
    end
end 

end % End of redistributeInto.

