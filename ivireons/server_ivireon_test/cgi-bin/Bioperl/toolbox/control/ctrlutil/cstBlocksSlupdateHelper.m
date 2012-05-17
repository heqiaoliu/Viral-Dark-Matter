function cstBlocksSlupdateHelper(h)
% Function cstBlocksSlupdateHelper is a helper function to be called as part of slupdate.
% it is not intended to be called directly from the command line.

%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2008/12/29 01:47:24 $

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

% This function sets up replacement information for all the obsolete blocks of
% Control System Toolbox
function ReplaceInfo = getReplaceInfo

    ReplaceInfo = { ...
        {'MaskType','LTI Block','LinkStatus','none'}, 'ReplaceLTIBlock', ...
        };

    ReplaceInfo = cell2struct(ReplaceInfo, { 'BlockDesc', 'ReplaceFcn'}, 2);

end

%ReplaceLTIBlock Prompt for update to LTI Block
function ReplaceLTIBlock(block, h)

if askToReplace(h, block)
    load_system('cstblocks')
    MaskStrs = get_param(block,'MaskValueString');
    funcSet = uReplaceBlock(h, block,'cstblocks/LTI System','MaskValueString',MaskStrs);
    appendTransaction(h, block, 'Update to the new library block or restore link.', {funcSet});
end

end % ReplaceLTIBlock


%[EOF] cstBlocksSlupdateHelper


