function outMsgStrs = getMessagesFromCatalog(inProdKey, inCompKey, inMsgKeys)
% DASTUDIO.GETMESSAGEFROMCATALOG(inProdKey, inCompKey, msgIDs) translates to a 
% cell array (msgID's) of actual strings from a cell array of ids in the same catalog.
% This saves repeated parsing of the product and catalog portions of the ids

%   Copyright 2008-2009 The MathWorks, Inc.

% Note: This is function exists for performance.  It does not do error checking. 
% It is up to the user to ensure that proper arguments are passed in and
% that no messages requested have additional arguments.
catalog = CatalogID([inProdKey ':' inCompKey]);
outMsgStrs = cell(size(inMsgKeys));

for i=1:length(inMsgKeys)
    try
        outMsgStrs{i} = catalog.message(inMsgKeys{i});
    catch e %#ok
           % No error checking in getMessagesFromCatalog, see above comments.
        outMsgStrs{i} = '';
    end
end
