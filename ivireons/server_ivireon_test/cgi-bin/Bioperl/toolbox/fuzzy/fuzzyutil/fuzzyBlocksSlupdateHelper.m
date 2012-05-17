function fuzzyBlocksSlupdateHelper(h)
% Helper function for SLUPDATE.
% Not intended to be called directly from the command line.

%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.1.10.2 $ $Date: 2010/02/08 22:34:13 $

replaceInfo = getReplaceInfo();

context     = getContext(h);
% work our way up from whatever context we get to the model
while strcmpi(get_param(context,'Type'), 'block')
    context = get_param(context,'Parent');
end

for idx=1:size(replaceInfo)
    args = replaceInfo(idx).BlockDesc;
    blocks = find_system(context, 'LookUnderMasks','all', args{:});
    
    % if any are found, call the ReplaceFcn
    for blkIdx=1:numel(blocks),
        feval(replaceInfo(idx).ReplaceFcn, blocks{blkIdx}, h);
    end
    
end

end

% This function sets up replacement information for the obsolete blocks in
% Robust Control Toolbox
function ReplaceInfo = getReplaceInfo

ReplaceInfo = struct(...
    'BlockDesc',{{'MaskType','FIS','LinkStatus','none'}},...
    'ReplaceFcn','ReplaceFISBlock');

end

%ReplaceBlock Prompt for update
function ReplaceFISBlock(block, h)
% (1) For FIS in any version (length of MaskValues is 1), force an update
% (2) For FIS with viewer before R12 (length of MaskValues is 0), do nothing
% because the FIS block under the mask will be updated in case (1)
% (3) For FIS with viewer aftere R12 (length of MaskValues is 2), do nothing 
if askToReplace(h, block)
    MaskValues = get_param(block,'MaskValues');
    if length(MaskValues)==1
        FISname = get_param(block,'MaskValueString');
        newLibBlock = sprintf('fuzblock/Fuzzy Logic \nController');
        load_system('fuzblock')
        funcSet = uReplaceBlock(h, block, newLibBlock, 'fis', FISname);
        appendTransaction(h, block, h.ReplaceBlockReasonStr, {funcSet});
    end
end

end % ReplaceBlock



