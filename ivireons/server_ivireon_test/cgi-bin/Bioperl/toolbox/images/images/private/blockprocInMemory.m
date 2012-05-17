function b = blockprocInMemory(a,block_size,fun,border_size,...
    pad_partial_blocks,trim_border,pad_method)
%blockprocInMemory Distinct block processing for image.
%
% This is the speparate implementation of BLOCKPROC for in-memory
% operations.  It is optimized for performance.
%
% Constraits:
% - MxNxP data only

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/04/15 15:18:14 $

% validate image size
asize = size(a);
if (numel(asize) < 2) || (numel(asize) > 3)
    eid = sprintf('Images:%s:invalidImageSize',mfilename);
    error(eid,'%s%s','Invalid image size.  BLOCKPROC expects the input image to be ',...
        'M-by-N or M-by-N-by-P.');
end

% compute size of required padding along image edges for partial blocks
source_height = asize(1);
source_width = asize(2);
row_padding = rem(source_height,block_size(1));
if pad_partial_blocks && row_padding > 0
    row_padding = block_size(1) - row_padding;
else
    row_padding = 0;
end
col_padding = rem(source_width,block_size(2));
if pad_partial_blocks && col_padding > 0
    col_padding = block_size(2) - col_padding;
else
    col_padding = 0;
end

% Pad the input array.  We handle each case separately for performance
% reasons (to avoid needless calls to padarray).
has_border = ~isequal(border_size,[0 0]);
if ~has_border && ~pad_partial_blocks
    % no-op
    aa = a;
elseif has_border && ~pad_partial_blocks
    % pad both together
    aa = padarray(a,border_size,pad_method,'both');
elseif ~has_border
    % pad_partial_blocks only
    aa = padarray(a,[row_padding col_padding],pad_method,'post');
else
    % both types of padding required
    aa = padarray(a,border_size,pad_method,'pre');
    post_padding = [row_padding col_padding] + border_size;
    aa = padarray(aa,post_padding,pad_method,'post');
end

% number of blocks we'll process
mblocks = ceil(source_height / block_size(1));
nblocks = ceil(source_width  / block_size(2));

% allocate/setup block struct
block_struct.border = border_size;
block_struct.blockSize = block_size;
block_struct.data = [];
block_struct.imageSize = asize;
block_struct.location = [1 1];

% get first block and process it
block_struct = getBlock(aa,asize,block_struct,1,1,border_size,block_size,...
    pad_partial_blocks);
[ul_output fun_nargout] = blockprocFunDispatcher(fun,block_struct,...
    trim_border);
previously_processed = 1;

% verify user FUN returned something valid
valid_output = isempty(ul_output) || isnumeric(ul_output) || ...
    islogical(ul_output);
if ~valid_output
    eid = sprintf('Images:%s:invalidOutputClass',mfilename);
    error(eid,'%s%s%s%s','Invalid output class.  The user function, ',...
        'FUN, returned an invalid result.  The class of the result was ',...
        class(ul_output), '.');
end

% probe the corners to compute final output size
ur_processed = false;
ll_processed = false;
if nblocks > 1
    block_struct = getBlock(aa,asize,block_struct,1,nblocks,border_size,...
        block_size,pad_partial_blocks);
    ur_output = blockprocFunDispatcher(fun,block_struct,trim_border);
    ur_processed = true;
    previously_processed = previously_processed + 1;
end
if mblocks > 1
    block_struct = getBlock(aa,asize,block_struct,mblocks,1,border_size,...
        block_size,pad_partial_blocks);
    ll_output = blockprocFunDispatcher(fun,block_struct,trim_border);
    ll_processed = true;
    previously_processed = previously_processed + 1;
end

% compute final output size
ul_output_size = [size(ul_output,1) size(ul_output,2)];
if ll_processed
    final_rows = ul_output_size(1) * (mblocks - 1) + size(ll_output,1);
else
    final_rows = ul_output_size(1);
end
if ur_processed
    final_cols = ul_output_size(2) * (nblocks - 1) + size(ur_output,2);
else
    final_cols = ul_output_size(2);
end
final_bands = size(ul_output,3);
final_size = [final_rows final_cols final_bands];

% allocate output matrix
if islogical(ul_output)
    b = false(final_size);
else
    b = zeros(final_size,class(ul_output));
end

% write 3 corner blocks
b(1:ul_output_size(1),1:ul_output_size(2),:) = ul_output;
if ll_processed
    last_row_start = final_rows - size(ll_output,1) + 1;
    last_row_width = size(ll_output,2);
    b(last_row_start:end,1:last_row_width,:) = ll_output;
end
if ur_processed
    last_col_start = final_cols - size(ur_output,2) + 1;
    last_col_height = size(ur_output,1);
    b(1:last_col_height,last_col_start:end,:) = ur_output;
end

% setup remaining index lists for unprocessed blocks.  make sure to process
% blocks we know to be of the same size in sequence to avoid reallocation
% in the block struct.
[r1 c1] = meshgrid(1,2:nblocks-1);             % top row
[r2 c2] = meshgrid(2:mblocks-1,1:nblocks-1);   % interior rows
[r3 c3] = meshgrid(mblocks,2:nblocks-1);       % bottom row
[r4 c4] = meshgrid(2:mblocks-1,nblocks);       % right column
r5 = mblocks;                                  % bottom right corner
c5 = nblocks;

rr = [r1(:); r2(:); r3(:); r4(:); r5(:)];
cc = [c1(:); c2(:); c3(:); c4(:); c5(:)];

% get number of remaining blocks
num_blocks = numel(rr);

% setup wait bar mechanics
wait_bar = [];
% only update the wait bar at each percentage increment
update_increments = unique([1:100 round((0.01:0.01:1) .* num_blocks)]);
update_counter = 1;

% inner loop starts
start_tic = tic;
for k = 1:num_blocks
    
    row = rr(k);
    col = cc(k);
    
    
    %%% INLINED: getBlock(aa,asize,block_struct,row,col,...) %%%
    % For performance we have inlined getBlock in the inner loop.  Changes
    % made here should also be made in the original sub-function.
    
    % compute row/col indices in (non-padded) source image of block of data
    source_min_row = 1 + block_size(1) * (row - 1);
    source_min_col = 1 + block_size(2) * (col - 1);
    source_max_row = source_min_row + block_size(1) - 1;
    source_max_col = source_min_col + block_size(2) - 1;
    if ~pad_partial_blocks
        source_max_row = min(source_max_row,source_height);
        source_max_col = min(source_max_col,source_width);
    end
    
    % set block location
    block_struct.location = [source_min_row source_min_col];
    
    % compute indicies in offset (border/padding-added) input, aa
    row_ind = source_min_row : source_max_row + 2 * border_size(1);
    col_ind = source_min_col : source_max_col + 2 * border_size(2);
    
    % set remaining block_struct fields
    % NOTE: resizes to the data field cause a re-allocation.  All
    % similarly sized blocks should be processed in sequence
    block_data = aa(row_ind,col_ind,:);
    block_struct.data = block_data;
    block_struct.blockSize = [size(block_data,1) size(block_data,2)];
    
    %%% INLINE ENDING: getBlock(aa,row,col,...) %%%
    
    
    %%% INLINED: blockprocFunDispatcher(fun,...) %%%
    % For performance we have inlined some code from blockprocFunDispatcher
    % in the inner loop.  Applicable changes made here should also be made
    % in the original sub-function.

    % process the block
    if fun_nargout > 0
        output_block = fun(block_struct);
    else
        fun(block_struct);
        output_block = [];
    end
    
    % trim output if necessary
    if trim_border
        % get border size from struct
        bdr = block_struct.border;
        % trim the border
        output_block = output_block(bdr(1)+1:end-bdr(1),bdr(2)+1:end-bdr(2),:);
    end
    
    %%% INLINE ENDING: blockprocFunDispatcher(fun,...) %%%
    
    
    % write to output
    row_idx = 1 + ul_output_size(1) * (row-1) : min(ul_output_size(1) * row,final_rows);
    col_idx = 1 + ul_output_size(2) * (col-1) : min(ul_output_size(2) * col,final_cols);
    b(row_idx,col_idx,:) = output_block;
    
    % do not run wait bar code every iteration
    if k >= update_increments(update_counter)
        
        update_counter = update_counter + 1;
        
        % keep a running total of how long we've taken
        elapsed_time = toc(start_tic);
        
        % display a wait bar if necessary
        if isempty(wait_bar)
            
            % decide if we need a wait bar or not
            remaining_time = elapsed_time / k * (num_blocks - k);
            if elapsed_time > 5 && remaining_time > 25
                total_blocks = num_blocks + previously_processed;
                if usejava('awt')
                    wait_bar = iptui.cancellableWaitbar('Block Processing:',...
                        'Processing %d blocks',total_blocks,previously_processed + k);
                else
                    wait_bar = iptui.textWaitUpdater('Block Processing %d blocks.',...
                        'Completed %d of %d blocks.',total_blocks);
                end
                cleanup_waitbar = onCleanup(@() destroy(wait_bar));
            end
            
        elseif wait_bar.isCancelled()
            % we had a waitbar, but the user hit the cancel button
            
            % return empty on cancels
            b = [];
            break;
            
        else
            % we have a waitbar and it has not been canceled
            wait_bar.update(previously_processed + k);
            
        end
    end
    
end % inner loop

% clean up wait bar if we made one
if ~isempty(wait_bar)
    clear cleanup_waitbar;
end


%-------------------------------------------------------------------------
function block_struct = getBlock(aa,asize,block_struct,row,col,...
    border_size,block_size,pad_partial_blocks)
% Gets a block struct containing the requested block.  This function is
% reproduced (inlined) in the inner loop of blockprocInMemory for
% performance reasons.  Changes to this function should be reflected there
% as well.

% compute row/col indices in (non-padded) source image of block of data
source_min_row = 1 + block_size(1) * (row - 1);
source_min_col = 1 + block_size(2) * (col - 1);
source_max_row = source_min_row + block_size(1) - 1;
source_max_col = source_min_col + block_size(2) - 1;
source_height = asize(1);
source_width  = asize(2);
if ~pad_partial_blocks
    source_max_row = min(source_max_row,source_height);
    source_max_col = min(source_max_col,source_width);
end

% set block location
block_struct.location = [source_min_row source_min_col];

% compute indicies in offset (border/padding-added) input, aa
row_ind = source_min_row : source_max_row + 2 * border_size(1);
col_ind = source_min_col : source_max_col + 2 * border_size(2);

% set remaining block_struct fields
block_data = aa(row_ind,col_ind,:);
block_struct.data = block_data;
block_struct.blockSize = [size(block_data,1) size(block_data,2)];

