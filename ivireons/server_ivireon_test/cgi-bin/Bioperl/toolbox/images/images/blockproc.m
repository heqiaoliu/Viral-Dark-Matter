function result_image = blockproc(Input,block_size,fun,varargin)
%BLOCKPROC Distinct block processing for image.
%   B = BLOCKPROC(A,[M N],FUN) processes the image A by applying the
%   function FUN to each distinct M-by-N block of A and concatenating the
%   results into the output matrix B.  FUN is a function handle to a
%   function that accepts a "block struct" as input and returns a matrix,
%   vector, or scalar Y:
%
%       Y = FUN(BLOCK_STRUCT)
%
%   For each block of data in the input image, A, BLOCKPROC will pass the
%   block in a "block struct" to the user function, FUN, to produce Y, the
%   corresponding block in the output image.  If Y is empty, then no output
%   is generated and BLOCKPROC returns empty after processing all blocks.
%
%   A "block struct" is a MATLAB structure that contains the block data as
%   well as other information about the block.  Fields in the block struct
%   are:
%
%       BLOCK_STRUCT.border : a 2-element vector, [V H], that specifies the
%                             size of the vertical and horizontal padding
%                             around the block of data (see 'BorderSize'
%                             argument below).
%
%       BLOCK_STRUCT.blockSize : a 2-element vector, [rows cols],
%                                specifying the size of the block data. If
%                                a border has been specified, the size does
%                                not include the border pixels.
%
%       BLOCK_STRUCT.data : M-by-N or M-by-N-by-P matrix of block data plus
%                           any included border pixels.
%
%       BLOCK_STRUCT.imageSize : a 2-element vector, [rows cols],
%                                specifying the full size of the input
%                                image.
%
%       BLOCK_STRUCT.location : a 2-element vector, [row col], that
%                               specifies the position of the first pixel
%                               (minimum-row, minimum-column) of the block
%                               data in the input image.  If a border has
%                               been specified, the location refers to the
%                               first pixel of the discrete block data, not
%                               the added border pixels.
%
%   B = BLOCKPROC(SRC_FILENAME,[M N],FUN) processes the image specified by
%   SRC_FILENAME, reading and processing one block at a time.  This syntax
%   is useful for processing very large images since only one block of the
%   image is read into memory at a time.  If the output matrix B is too
%   large to fit into memory, then you should additionally use the
%   'Destination' parameter/value pair to write the output to a file.  See
%   below for information on supported file types and parameters.
%
%   B = BLOCKPROC(ADAPTER,[M N],FUN) processes the source image specified
%   by ADAPTER, an ImageAdapter object.  ImageAdapters are user-defined
%   classes that provide BLOCKPROC with a common API for reading and
%   writing to a particular image file format.  See the documentation for
%   ImageAdapter for more details.
%
%   BLOCKPROC(...,PARAM1,VAL1,PARAM2,VAL2,...) processes the input image,
%   specifying parameters and corresponding values that control various
%   aspects of the block behavior.  Parameter name case does not matter.
%
%   Parameters include:
%
%   'Destination'       The destination for the output of BLOCKPROC.  When
%                       specified, BLOCKPROC will not return the processed
%                       image as an output argument, but instead write the
%                       output to the 'Destination'.  Valid 'Destination'
%                       parameters are:
%
%                          TIFF filename: a string filename ending with
%                             '.tif'.  This file will be overwritten if it
%                             exists.
%
%                          ImageAdapter object: an instance of an
%                             ImageAdapter class.  ImageAdapters provide an
%                             interface for reading and writing to
%                             arbitrary image file formats.  See the
%                             documentation for ImageAdapter for more
%                             information.
%
%                       The 'Destination' parameter is useful when you
%                       expect your output to be too large to practically
%                       fit into memory.  It provides a workflow for
%                       file-to-file image processing for arbitrarily large
%                       images.
%
%   'BorderSize'        A 2-element vector, [V H], specifying the amount of
%                       border pixels to add to each block.  V rows are
%                       added above and below each block, H columns are
%                       added left and right of each block.  The size of
%                       each resulting block will be:
%                           [M + 2*V, N + 2*H]
%                       The default is [0 0], meaning no border.
%
%                       By default, the border is automatically removed
%                       from the result of FUN.  See the 'TrimBorder'
%                       parameter for more information.
%
%                       Blocks with borders that extend beyond the edges of
%                       the image are padded with zeros.
%
%   'TrimBorder'        A logical scalar.  When set to true, BLOCKPROC
%                       trims off border pixels from the output of the user
%                       function, FUN.  V rows are removed from the top and
%                       bottom of the output of FUN, and H columns are
%                       removed from the left and right edges, where V and
%                       H are defined by the 'BorderSize' parameter.  The
%                       default is true, meaning borders are automatically
%                       removed from the output of FUN.
%
%   'PadMethod'         The PadMethod determines how BLOCKPROC will pad the
%                       image boundary when necessary.  Options are:
%                     
%                         X             Pads the image with a scalar (X)
%                                       pad value.  By default X == 0.
%                         'replicate'   Repeats border elements of A.
%                         'symmetric'   Pads array with mirror reflections
%                                       of itself.
% 
%   'PadPartialBlocks'  A logical scalar.  When set to true, BLOCKPROC will
%                       pad partial blocks to make them full-sized (M-by-N)
%                       blocks.  Partial blocks arise when the image size
%                       is not exactly divisible by the block size.  If
%                       they exist, partial blocks will lie along the right
%                       and bottom edge of the image.  The default is
%                       false, meaning the partial blocks are not padded,
%                       but processed as-is.
%
%                       BLOCKPROC uses zeros to pad partial blocks when
%                       necessary.
%
%   File Format Support
%   -------------------
%   Input and output files for BLOCKPROC (as specified by SRC_FILENAME
%   and/or the 'Destination' parameter) must be of the following file types
%   and must be named with one of the listed file extensions:
%
%       Read / Write File Formats
%       -------------------------
%       TIFF: *.tif, *.tiff
%       JPEG2000: *.jp2, *.j2c, *.j2k
%
%       Read-Only File Formats
%       ----------------------
%       JPEG2000: *.jpf, *.jpx
%
%   See the reference page for BLOCKPROC for additional file format
%   specific limitations.
%
%   Block Sizes
%   -----------
%   When using BLOCKPROC to either read or write image files, file access
%   can be an important factor in performance.  In general, selecting
%   larger block sizes will reduce the number of times BLOCKPROC will have
%   to access the disk, at the cost of using more memory to process each
%   block.  Knowledge of the file format layout on disk can also be useful
%   in selecting block sizes that minimize the number of times the disk is
%   accessed.
%
%   Examples
%   --------
%   This simple example uses the IMRESIZE function to generate an image
%   thumbnail.
%
%       fun = @(block_struct) imresize(block_struct.data,0.15);
%       I = imread('pears.png');
%       I2 = blockproc(I,[100 100],fun);
%       figure;
%       imshow(I);
%       figure;
%       imshow(I2);
%
%   This example uses BLOCKPROC to set the pixels in each 32-by-32 block
%   to the standard deviation of the elements in that block.
%
%       fun = @(block_struct) std2(block_struct.data) * ones(size(block_struct.data));
%       I2 = blockproc('moon.tif',[32 32],fun);
%       figure;
%       imshow('moon.tif');
%       figure;
%       imshow(I2,[]);
%
%   This example uses BLOCKPROC to switch the red and green bands of an RGB
%   image and writes the results to a new TIFF file.
%
%       I = imread('peppers.png');
%       fun = @(block_struct) block_struct.data(:,:,[2 1 3]);
%       blockproc(I,[200 200],fun,'Destination','grb_peppers.tif');
%       figure;
%       imshow('peppers.png');
%       figure;
%       imshow('grb_peppers.tif');
%
%   This example uses BLOCKPROC to convert a Tiff image into a new JPEG2000
%   image. 
%
%       fun = @(block_struct) block_struct.data;
%       blockproc('largeImage.tif',[1024 1024],fun,'Destination','New.jp2');
%
%   See also COLFILT, FUNCTION_HANDLE, IMAGEADAPTER, NLFILTER.

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/04/15 15:18:04 $

% set default input arguments are parse actual inputs
input_args.Input = [];
input_args.BlockSize = [0 0];
input_args.Function = [];
input_args.BorderSize = [0 0];
input_args.Destination = [];
input_args.PadMethod = 0;
input_args.PadPartialBlocks = false;
input_args.TrimBorder = true;
input_args = parse_inputs(input_args,Input,block_size,fun,varargin{:});

% get input and output...
a = input_args.Input;
b = input_args.Destination;
if ~isempty(b)
    destination_specified = true;
    if isa(b,'char')
        dest_file_name = input_args.Destination;
    else
        dest_file_name = [];
    end
else
    destination_specified = false;
    dest_file_name = [];
end

% other params...
block_size = floor(input_args.BlockSize);
border_size = floor(input_args.BorderSize);
fun = input_args.Function;
pad_method = input_args.PadMethod;
pad_partial_blocks = input_args.PadPartialBlocks;

% never attempt to trim a [0 0] border...
if isequal(border_size,[0 0])
    trim_border = false;
else
    trim_border = input_args.TrimBorder;
end

% handle in-memory case with optimized private function
if (isnumeric(a) || islogical(a)) && ~destination_specified
    result_image = blockprocInMemory(a,block_size,fun,border_size,...
        pad_partial_blocks,trim_border,pad_method);
    return
end

% some simple additional pad method parsing (since we will pad by hand in
% this codepath)
pad_value = 0;
if isscalar(pad_method)
    pad_value = pad_method;
    pad_method = 'constant';
end

% check for incompatible parameters
if destination_specified && nargout > 0
    eid = sprintf('Images:%s:tooManyOutputArguments',mfilename);
    error(eid,'%s%s%s','Too many output arguments.  When the ',...
        '''Destination'' parameter is specified, BLOCKPROC does not ',...
        'return any output.');
end

% create image adapter and onCleanup routine for non-adapter source images
if ~isa(a,'ImageAdapter')
    a = createInputAdapter(a);
    cleanup_a = onCleanup(@() a.close());
end
% create dispatcher for source adapter
a_dispatcher = internal.images.AdapterDispatcher(a,'r');

% compute size of required padding along image edges
asize = a.ImageSize;
source_height = asize(1);
source_width = asize(2);
row_padding = rem(source_height,block_size(1));
if row_padding > 0
    row_padding = block_size(1) - row_padding;
end
col_padding = rem(source_width,block_size(2));
if col_padding > 0
    col_padding = block_size(2) - col_padding;
end

% number of blocks we'll process
mblocks = (source_height + row_padding) / block_size(1);
nblocks = (source_width  + col_padding) / block_size(2);

% allocate/setup block struct
block_struct.border = border_size;
block_struct.blockSize = block_size;
block_struct.data = [];
block_struct.imageSize = asize;
block_struct.location = [1 1];

% get first block and process it
block_struct = getBlock(a_dispatcher,asize,block_struct,1,1,block_size,...
    border_size,pad_method,pad_value,row_padding,col_padding,pad_partial_blocks);
[output_block fun_nargout] = blockprocFunDispatcher(fun,block_struct,trim_border);

% verify user FUN returned something valid
valid_output = isempty(output_block) || isnumeric(output_block) || ...
    islogical(output_block);
if ~valid_output
    eid = sprintf('Images:%s:invalidOutputClass',mfilename);
    error(eid,'%s%s%s%s','Invalid output class.  The user function, ',...
        'FUN, returned an invalid result.  The class of the result was ',...
        class(output_block), '.');
end

% if we are writing to a file, verify we have data to write
if destination_specified && isempty(output_block)
    eid = sprintf('Images:%s:emptyFile',mfilename);
    error(eid,'%s%s%s','Cannot write empty file.  The user function, ',...
        'FUN, cannot return empty when the ''Destination'' parameter ',...
        'has been specified.');
end

% get output block size
output_size  = [size(output_block,1) size(output_block,2)];
output_bands = size(output_block,3);

% create output image adapter if necessary and onCleanup routine
if destination_specified && isa(b,'ImageAdapter')
    % b is an ImageAdapter, we just wrap it with the dispatcher
    rows_probed = false;
    cols_probed = false;
    b_dispatcher = internal.images.AdapterDispatcher(b,'r+');
    
    % copy the first block into the upper-left of the output matrix
    putBlock(b_dispatcher,b.ImageSize,output_size,1,1,output_block);
else
    % we need to create the output adapter
    % This also writes first upper-left block and probed blocks
    [b,rows_probed,cols_probed] = createOutputAdapter(a,...
        asize,block_struct,b,fun,block_size,trim_border,mblocks,nblocks,...
        row_padding,col_padding,pad_method,pad_value,pad_partial_blocks,...
        output_size,output_bands,output_block,border_size);
    % cleanup b if necessary
    cleanup_b = onCleanup(@() b.close());
end
bsize = b.ImageSize;

% get row/column indices of all unprocessed blocks
% start with interior blocks (unprobed rows/cols)
[r,c] = meshgrid(2:mblocks,2:nblocks);
rr = r(:);
cc = c(:);

previously_processed = 1;

% add unprocessed blocks from first row
if cols_probed
    end_col = nblocks - 1;
    previously_processed = previously_processed + 1;
else
    end_col = nblocks;
end
[r,c] = meshgrid(1,2:end_col);
rr = [rr;r(:)];
cc = [cc;c(:)];

% add unprocessed blocks from first column
if rows_probed
    end_row = mblocks - 1;
    previously_processed = previously_processed + 1;
else
    end_row = mblocks;
end
[r,c] = meshgrid(2:end_row,1);
rr = [rr;r(:)];
cc = [cc;c(:)];

% get number of remaining blocks
num_blocks = length(rr);

% for each remaining block
wait_bar = [];
% update for the first 100 blocks and then at each 1% after that
update_increments = unique([1:100 round((0.01:0.01:1) .* num_blocks)]);
update_counter = 1;

% inner loop
start_tic = tic;
for k = 1:num_blocks
    
    row = rr(k);
    col = cc(k);
    
    % read the block
    block_struct = getBlock(a,asize,block_struct,row,col,block_size,...
        border_size,pad_method,pad_value,row_padding,col_padding,pad_partial_blocks);
    
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
    
    % write the block
    putBlock(b,bsize,output_size,row,col,output_block);
    
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
            
            % clear onCleanup objects to close file handles
            clear cleanup_a cleanup_b;
            
            % delete the output file if necessary
            if destination_specified && isequal(exist(dest_file_name,'file'),2)
                delete(dest_file_name);
            end
            
            % reset output adapter to be empty (if nargout > 0)
            b = internal.images.MatrixAdapter([]);
            break
            
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

if ~destination_specified
    % return entire matrix when 'Destination' is not specified
    result_size = b.ImageSize;
    result_image = b.readRegion([1 1],result_size(1:2));
end

end % blockproc



%------------------------------------------------------------------------
function [b_adpt rows_probed cols_probed] = createOutputAdapter(a,...
    asize,block_struct,b,fun,block_size,trim_border,mblocks,nblocks,...
    row_padding,col_padding,pad_method,pad_value,pad_partial_blocks,output_size,...
    output_bands,output_block,border_size)

output_class = class(output_block);

% return information about what blocks were processed
rows_probed = false;
cols_probed = false;

% compute the size of output image
num_full_block_rows = mblocks;
num_full_block_cols = nblocks;
num_extra_rows = 0;
num_extra_cols = 0;
if ~pad_partial_blocks
    % we're not padding, so compute the extra rows/cols along edges
    if row_padding > 0
        num_full_block_rows = num_full_block_rows - 1;
        num_extra_rows = block_size(1) - row_padding;
    end
    if col_padding > 0
        num_full_block_cols = num_full_block_cols - 1;
        num_extra_cols = block_size(2) - col_padding;
    end
end

% first compute the full-sized blocks' output size
output_rows = output_size(1) * num_full_block_rows;
output_cols = output_size(2) * num_full_block_cols;

if ~pad_partial_blocks
    % we probe the 2 extremities for excess edge output size
    if num_extra_rows > 0
        block_struct = getBlock(a,asize,block_struct,mblocks,1,...
            block_size,border_size,pad_method,pad_value,row_padding,col_padding,pad_partial_blocks);
        last_row_output = blockprocFunDispatcher(fun,block_struct,trim_border);
        output_rows = output_rows + size(last_row_output,1);
        rows_probed = true;
    end
    if num_extra_cols > 0
        block_struct = getBlock(a,asize,block_struct,1,nblocks,...
            block_size,border_size,pad_method,pad_value,row_padding,col_padding,pad_partial_blocks);
        last_col_output = blockprocFunDispatcher(fun,block_struct,trim_border);
        output_cols = output_cols + size(last_col_output,2);
        cols_probed = true;
    end
end

% compute final image size
if output_bands > 1
    final_size = [output_rows output_cols output_bands];
else
    final_size = [output_rows output_cols];
end

% create ImageAdapter for output
outputClass = str2func(output_class);
if isempty(b)
    % for matrix output
    b = repmat(outputClass(0),final_size);
    b_adpt = internal.images.MatrixAdapter(b);
elseif ischar(b)
    [~, ~, ext] = fileparts(b);
    is_jpeg2000 = strcmpi(ext,'.jp2') || strcmpi(ext,'.j2c') || ...
                  strcmpi(ext,'.j2k');
    % for file output
    if is_jpeg2000
        b_adpt = internal.images.Jp2Adapter(b,'w',final_size,outputClass(0));
    else
        b_adpt = internal.images.TiffAdapter(b,'w',final_size,outputClass(0));
    end
end
b_adpt_size = b_adpt.ImageSize;

% create the dispatcher
b_disp = internal.images.AdapterDispatcher(b_adpt,'r+');

% Put the first output block, this is always probed
% For JPEG2000, the first block write must a top-left block
putBlock(b_disp,b_adpt_size,output_size,1,1,output_block);

% if we had to probe for final image size, write out our probe results
if rows_probed
    putBlock(b_disp,b_adpt_size,output_size,mblocks,1,last_row_output);
end
if cols_probed
    putBlock(b_disp,b_adpt_size,output_size,1,nblocks,last_col_output);
end

end % createOutputAdapter


%-------------------------------------------------------------------
function block_struct = getBlock(source,source_size,block_struct,...
    row,col,block_size,border_size,pad_method,pad_value,row_padding,...
    col_padding,pad_partial_blocks)
% This function receives the block_struct as input to avoid reallocating every iteration
% We force the caller to specify the first argument because we want to pass
% in an adapter dispatcher in some cases, but directly pass in the image
% adapter object while inside the inner loop.

% compute starting row/col in source image of block of data
source_height = source_size(1);
source_width = source_size(2);
source_min_row = 1 + block_size(1) * (row - 1);
source_min_col = 1 + block_size(2) * (col - 1);
source_max_row = source_min_row + block_size(1) - 1;
source_max_col = source_min_col + block_size(2) - 1;
if ~pad_partial_blocks
    source_max_row = min(source_max_row,source_height);
    source_max_col = min(source_max_col,source_width);
end

% set block struct location (before border pixels are considered)
block_struct.location = [source_min_row source_min_col];

% add border pixels around the block of data
source_min_row = source_min_row - border_size(1);
source_max_row = source_max_row + border_size(1);
source_min_col = source_min_col - border_size(2);
source_max_col = source_max_col + border_size(2);

% setup indices for target block
total_rows = source_max_row - source_min_row + 1;
total_cols = source_max_col - source_min_col + 1;

% for interior blocks
if (source_min_row >= 1) && (source_max_row <= source_height) && ...
        (source_min_col >= 1) && (source_max_col <= source_width)
    
    % no padding necessary, just read data and return
    block_struct.data = source.readRegion([source_min_row source_min_col],...
        [total_rows total_cols]);
    
elseif strcmpi(pad_method,'constant')
    
    % setup target indices variables
    target_min_row = 1;
    target_max_row = total_rows;
    target_min_col = 1;
    target_max_col = total_cols;
    
    % check each edge of the requested block for edge
    if source_min_row < 1
        delta = 1 - source_min_row;
        source_min_row = source_min_row + delta;
        target_min_row = target_min_row + delta;
    end
    if source_max_row > source_height
        delta = source_max_row - source_height;
        source_max_row = source_max_row - delta;
        target_max_row = target_max_row - delta;
    end
    if source_min_col < 1
        delta = 1 - source_min_col;
        source_min_col = source_min_col + delta;
        target_min_col = target_min_col + delta;
    end
    if source_max_col > source_width
        delta = source_max_col - source_width;
        source_max_col = source_max_col - delta;
        target_max_col = target_max_col - delta;
    end
    
    % read source data
    source_data = source.readRegion(...
        [source_min_row                      source_min_col],...
        [source_max_row - source_min_row + 1 source_max_col - source_min_col + 1]);
    
    % allocate target block (this implicitly also handles constant value
    % padding around the edges of the partial blocks and boundary
    % blocks)
    inputClass = str2func(class(source_data));
    pad_value = inputClass(pad_value);
    block_struct.data = repmat(pad_value,[total_rows total_cols size(source_data,3)]);
    
    % copy valid data into target block
    target_rows = target_min_row:target_max_row;
    target_cols = target_min_col:target_max_col;
    block_struct.data(target_rows,target_cols,:) = source_data;
    
else

    % in this code path, have are guarenteed to require *some* padding,
    % either pad_partial_blocks, a border, or both.
    
    % Compute padding indices for entire input image
    has_border = ~isequal(border_size,[0 0]);
    if ~has_border
        % pad_partial_blocks only
        aIdx = getPaddingIndices(source_size(1:2),...
            [row_padding col_padding],pad_method,'post');
        row_idx = aIdx{1};
        col_idx = aIdx{2};
        
    else
        % has a border...
        if  ~pad_partial_blocks
            % pad border only, around entire image
            aIdx = getPaddingIndices(source_size(1:2),...
                border_size,pad_method,'both');
            row_idx = aIdx{1};
            col_idx = aIdx{2};
            
            
        else
            % both types of padding required
            aIdx_pre = getPaddingIndices(source_size(1:2),...
                border_size,pad_method,'pre');
            post_padding = [row_padding col_padding] + border_size;
            aIdx_post = getPaddingIndices(source_size(1:2),...
                post_padding,pad_method,'post');
            
            % concatenate the post padding onto the pre-padding results
            row_idx = [aIdx_pre{1} aIdx_post{1}(end-post_padding(1)+1:end)];
            col_idx = [aIdx_pre{2} aIdx_post{2}(end-post_padding(2)+1:end)];
            
        end
    end
    
    % offset the indices of our desired block to account for the
    % pre-padding in our padded index arrays
    source_min_row = source_min_row + border_size(1);
    source_max_row = source_max_row + border_size(1);
    source_min_col = source_min_col + border_size(2);
    source_max_col = source_max_col + border_size(2);
    
    % extract just the indices of our desired block
    block_row_ind = row_idx(source_min_row:source_max_row);
    block_col_ind = col_idx(source_min_col:source_max_col);
    
    % compute the absolute row/col limits containing all the necessary
    % data from our source image
    block_row_min = min(block_row_ind);
    block_row_max = max(block_row_ind);
    block_col_min = min(block_col_ind);
    block_col_max = max(block_col_ind);
    
    % read the block from the adapter object containing all necessary data
    source_data = source.readRegion(...
        [block_row_min                      block_col_min],...
        [block_row_max - block_row_min + 1  block_col_max - block_col_min + 1]);
    
    % offset our block_row/col_inds to align with the data read from the
    % adapter
    block_row_ind = block_row_ind - block_row_min + 1;
    block_col_ind = block_col_ind - block_col_min + 1;
    
    % finally index into our block of source data with the correctly
    % padding index lists
    block_struct.data = source_data(block_row_ind,block_col_ind,:);
    
end

data_size = [size(block_struct.data,1) size(block_struct.data,2)];
block_struct.blockSize = data_size - 2 * block_struct.border;

end % getBlock


%--------------------------------------------------------
function putBlock(dest,dest_size,block_size,row,col,data)

% just bail on empty data
if isempty(data)
    return
end

% get size of our destination
dest_height = dest_size(1);
dest_width  = dest_size(2);

% compute destination location for target block
target_start_row = 1 + (row - 1) * block_size(1);
target_start_col = 1 + (col - 1) * block_size(2);

% we clip the output location based on the size of the destination data
max_row = target_start_row + block_size(1) - 1;
max_col = target_start_col + block_size(2) - 1;
excess = [0 0];
if max_row > dest_height
    excess(1) = max_row - dest_height;
end
if max_col > dest_width
    excess(2) = max_col - dest_width;
end

% account for blocks that are too large and go beyond the destination edge
block_size(1:2) = block_size(1:2) - excess;
% account for edge blocks that are not padded and are not full block sized
block_size(1:2) = min(block_size(1:2),[size(data,1) size(data,2)]);

% write valid block data to destination
start_loc = [target_start_row target_start_col];
dest.writeRegion(start_loc,...
    data(1:block_size(1),1:block_size(2),:));

end % putBlock


%----------------------------------------------
function adpt = createInputAdapter(data_source)
% data_source has been previously validated during input parsing.  It is
% either a string filename with a valid TIFF or JPEG2000 extension, or else
% it's a numeric or logical matrix.

if ischar(data_source)
    
    % data_source is a file.  We verified in the parse_inputs function that
    % it is a TIFF or Jpeg2000 file with a valid extension.
    [~, ~, ext] = fileparts(data_source);
    is_tiff = strcmpi(ext,'.tif') || strcmpi(ext,'.tiff');
    is_jp2 = strcmpi(ext,'.jp2') || strcmpi(ext,'.jpf') || ...
             strcmpi(ext,'.jpx') || strcmpi(ext,'.j2c') || ...
             strcmpi(ext,'.j2k');
    if is_tiff
        adpt = internal.images.TiffAdapter(data_source,'r');
    elseif is_jp2
        adpt = internal.images.Jp2Adapter(data_source,'r');
    else
        % unknown format, try imread adapter
        adpt = internal.images.ImreadAdapter(data_source);
    end
    
else
    % otherwise it's numeric or logical, verified during input parsing.
    % This code path is hit when the input is in memory and a 'Destination'
    % is specified or when the input is a file/adapter.
    adpt = internal.images.MatrixAdapter(data_source);
end

end % createInputAdapter


%-------------------------------------------------------------------------
function input_args = parse_inputs(input_args,Input,block_size,fun,varargin)
% Parse blockproc syntax

% validate Input
%---------------
valid_matrix = isnumeric(Input) || islogical(Input);
valid_file = ischar(Input) && isequal(exist(Input,'file'),2);
valid_adapter = isa(Input,'ImageAdapter');
if valid_file
    [~, ~, ext] = fileparts(Input);
    is_readWrite = strcmpi(ext,'.tif') || strcmpi(ext,'.tiff') || ...
                   strcmpi(ext,'.j2k') || strcmpi(ext,'.j2c') || ...
                   strcmpi(ext,'.jp2');
    is_readOnly = strcmpi(ext,'.jpf') || strcmpi(ext,'.jpx');
    if is_readWrite || is_readOnly
        valid_file = true;
    else
        valid_file = false;
    end
end
if ~(valid_matrix || valid_file || valid_adapter)
    eid = sprintf('Images:%s:invalidInputImage',mfilename);
    error(eid,'%s%s%s%s','Invalid input image.  The input image to ',...
        'BLOCKPROC should be either a numeric matrix, a string ',...
        'filename, or an ImageAdapter object.  See the documentation for BLOCKPROC for a ',...
        'list of readable file formats and their extensions.  See the documentation for ImageAdapter for information on making ImageAdapter objects.');
end

% validate block_size
%--------------------
floored_block_size = floor(block_size);
correct_size = isequal(size(floored_block_size),[1 2]);
non_negative = all(floored_block_size > 0);
non_inf = ~any(isinf(floored_block_size));
if ~(isnumeric(floored_block_size) && correct_size && non_negative && non_inf)
    eid = sprintf('Images:%s:invalidBlockSize',mfilename);
    error(eid,'%s%s','Invalid block size.  BLOCKPROC expects the ',...
        'BlockSize parameter to be a 1 by 2 positive numeric vector.');
end

% warn for non integer block_sizes
if ~all(block_size == floor(block_size))
    warning('Images:blockproc:fractionalBlockSize','%s%s',...
        'BLOCKPROC did not expect a fractional ''BlockSize'' ',...
        'parameter.  It will be truncated before use.');
end

% validate fun
%-------------
if ~isa(fun,'function_handle')
    eid = sprintf('Images:%s:invalidFunction',mfilename);
    error(eid,'%s%s','Invalid block function.  BLOCKPROC expects ',...
        'the user function, FUN, to be a valid function handle.');
end

% set our 3 fixed arguments and parse PV pairs
input_args.Input = Input;
input_args.BlockSize = floored_block_size;
input_args.Function = fun;

num_varargin = numel(varargin);
if (rem(num_varargin, 2) ~= 0)
    error('Images:blockproc:paramMissingValue', ...
        'Named parameters must have a corresponding value.')
end

% Create a structure with default values, and map actual param-value pair
% names to convenient names for internal use.
ParamName   = {'BorderSize','Destination','PadMethod',...
    'PadPartialBlocks','TrimBorder'};
ValidateFcn = {@checkBorderSize, @checkDestination, @checkPadMethod,...
    @checkPadPartialBlocks, @checkTrimBorder};

% Loop over the P-V pairs.
for p = 1:2:num_varargin
    
    % Get the parameter name.
    user_param = varargin{p};
    if (~ischar(user_param))
        error('Images:blockproc:badParamName', ...
            'Parameter names be character arrays.')
    end
    
    % Look for the parameter amongst the possible values.
    idx = strmatch(lower(user_param), lower(ParamName));
    
    if isempty(idx)
        error('Images:blockproc:unknownParamName', ...
            'Unknown parameter "%s".', user_param);
    elseif numel(idx) > 1
        error('Images:blockproc:ambiguousParamName', ...
            'Ambiguous parameter "%s".', user_param);
    end
    
    % Validate the value.
    validateFcn = ValidateFcn{idx};
    param_value = varargin{p+1};
    validateFcn(param_value);
    input_args.(ParamName{idx}) = param_value;
end

end % parse_inputs

%--------------------------------
function checkDestination(output)
valid_file = ischar(output);
valid_adapter = isa(output,'ImageAdapter');

if valid_file
    [~, ~, ext] = fileparts(output);
    is_readWrite = strcmpi(ext,'.tif') || strcmpi(ext,'.tiff') || ...
                   strcmpi(ext,'.j2k') || strcmpi(ext,'.j2c') || ...
                   strcmpi(ext,'.jp2');
    if ~is_readWrite
        valid_file = false;
    end
end

if ~(valid_file || valid_adapter)
    eid = sprintf('Images:%s:invalidDestination',mfilename);
    error(eid,'%s%s%s%s','Invalid destination.  The destination for ',...
        'BLOCKPROC, if specified, must be a string filename ',...
        'or an ImageAdapter object.  See the documentation for BLOCKPROC ',...
        'for a list of writable file formats.  See the documentation for ImageAdapter for information on how these classes are used with BLOCKPROC.');
end
end

%------------------------------------
function checkBorderSize(border_size)
correct_size = isequal(size(border_size),[1 2]);
non_negative = all(border_size >= 0);
non_inf = ~any(isinf(border_size));
if ~(isnumeric(border_size) && correct_size && non_negative && non_inf)
    eid = sprintf('Images:%s:invalidBorderSize',mfilename);
    error(eid,'%s%s','Invalid border size.  BLOCKPROC expects the ',...
        'BorderSize parameter to be a 1 by 2 positive numeric vector.');
end

% warn for non integer block_sizes
if ~all(border_size == floor(border_size))
    warning('Images:blockproc:fractionalBorderSize','%s%s',...
        'BLOCKPROC did not expect a fractional ''BorderSize'' ',...
        'parameter.  It will be truncated before use.');
end

end

%-------------------------------------------------
function checkPadMethod(pad_method)

valid_scalar = false;
valid_method = false;
if isscalar(pad_method) && (isnumeric(pad_method) || islogical(pad_method))
    valid_scalar = true;
elseif ischar(pad_method) && ...
        (strcmpi(pad_method,'replicate') || strcmpi(pad_method,'symmetric'))
    valid_method = true;
end
    
if ~valid_scalar && ~valid_method
    eid = sprintf('Images:%s:invalidPadMethodParam',mfilename);
    error(eid,'%s%s%s','Invalid ''PadMethod'' parameter.  BLOCKPROC ',...
        'expects the PadMethod parameter to be ''replicate'', ',...
        '''symmetric'', or a scalar value.');
end
end

%-------------------------------------------------
function checkPadPartialBlocks(pad_partial_blocks)
if ~(islogical(pad_partial_blocks) || isnumeric(pad_partial_blocks))
    eid = sprintf('Images:%s:invalidPadPartialBlocksParam',mfilename);
    error(eid,'%s%s','Invalid ''PadPartialBlocks'' parameter.  BLOCKPROC ',...
        'expects the PadPartialBlocks parameter to be either true or false.');
end
end

%------------------------------------
function checkTrimBorder(trim_border)
if ~(islogical(trim_border) || isnumeric(trim_border))
    eid = sprintf('Images:%s:invalidTrimBorderParam',mfilename);
    error(eid,'%s%s','Invalid "TrimBorder" parameter.  BLOCKPROC ',...
        'expects the TrimBorder parameter to a logical scalar.');
end
end

