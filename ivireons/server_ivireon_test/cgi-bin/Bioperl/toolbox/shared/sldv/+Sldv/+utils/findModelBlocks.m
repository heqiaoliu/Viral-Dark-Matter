%findModelBlocks Search for the Model blocks included in the model
%modelName. Do not return Model Blocks with ProtectecModel set to
%'on'
function mdlBlks = findModelBlocks(modelName)

%   Copyright 2009 The MathWorks, Inc.

    [~, mdlBlks] = find_mdlrefs(modelName, false);
    if ~isempty(mdlBlks)                
        I = strmatch('off',get_param(mdlBlks,'ProtectedModel'));
        mdlBlks = mdlBlks(I);
    end
end    

% LocalWords:  Protectec
