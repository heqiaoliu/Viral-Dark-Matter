function pil_block_replace(srcBlk, dstBlk, isvisible)
% PIL_BLOCK_REPLACE - Replace a destination block with a source block.
%                     The original destination block is saved by replacing
%                     the source block in the source model.
%   
% pil_block_replace(srcBlk, dstBlk)
%
% srcBlk - The source block
% dstBlk - The destination block
% isvisible - open the model and hilite the replaced block

%   Copyright 2005-2009 The MathWorks, Inc.
  
% check num args
error(nargchk(2, 3, nargin, 'struct'));

% new argument: backwards compatibility 
if nargin < 3
    isvisible = true;
end

% open systems
srcModel = strtok(srcBlk, '/');
dstModel = strtok(dstBlk, '/');
load_system(srcModel);
load_system(dstModel);

% check srcBlk exists
try
    % Note: would have used load_system but it sometimes
    % opens the subsystem!
    find_system(srcBlk, 'SearchDepth', 0);
catch exc
    if strcmp(exc.identifier, 'Simulink:Commands:FindSystemInvalidPVPair')
        rtw.pil.ProductInfo.error('pil', 'NoSourceBlock', srcBlk);
    else
        rethrow(exc)
    end
end

% check dstBlk already exists in the model
try
    % Note: would have used load_system but it sometimes
    % opens the subsystem!
    find_system(dstBlk, 'SearchDepth', 0);
catch exc
    if strcmp(exc.identifier, 'Simulink:Commands:FindSystemInvalidPVPair')
        rtw.pil.ProductInfo.error('pil', 'NoDestinationBlock', dstBlk);
    else
        rethrow exc
    end
end

% swap src and dst block

% get size of dstBlk for:
% i) resizing the srcBlk
% ii) positioning the savedDstBlk
dst_pos = get_param(dstBlk, 'Position');
dst_width = dst_pos(3) - dst_pos(1);
dst_height = dst_pos(4) - dst_pos(2);
savedDstBlk_x = 10;
savedDstBlk_y = 10;
savedDstBlk_pos = [savedDstBlk_x, savedDstBlk_y, ...
                   savedDstBlk_x + dst_width, savedDstBlk_y + dst_height];
% use the original name for the savedDstBlk
dstName = get_param(dstBlk, 'Name');
% careful to escape any /'s in Name
savedDstBlk = [get_param(srcModel, 'Name') '/' strrep(dstName, '/', '//') '_PIL_BLOCK_REPLACE'];

% Preserve the orientation of the block
dst_orientation = get_param(dstBlk, 'Orientation');

% add a temporary block
savedDstBlk_h = add_block(dstBlk, savedDstBlk, ...
    'Position', savedDstBlk_pos);
% delete the original block
delete_block(dstBlk);
% add the src block
add_block(srcBlk, dstBlk,...
    'Position', dst_pos,...
    'Orientation', dst_orientation);
% delete the src block
delete_block(srcBlk);
% rename tmp
set_param(savedDstBlk_h, 'Name', dstName);

% bring the new block to the front. Use the find color scheme to avoid
% confusion that an error has occurred with the default color scheme
if isvisible
    hilite_system(dstBlk, 'find');
end

nl = sprintf('\n');
disp([nl 'Successfully swapped the following blocks: ' nl nl ...
      srcBlk nl dstBlk nl nl]);
