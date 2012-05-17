function B = morphop(varargin)
%MORPHOP Dilate or erode image.
%   B = MORPHOP(OP_TYPE,A,SE,...) computes the erosion or dilation of A,
%   depending on whether OP_TYPE is 'erode' or 'dilate'.  SE is a
%   STREL array or an NHOOD array.  MORPHOP is intended to be called only
%   by IMDILATE or IMERODE.  Any additional arguments passed into
%   IMDILATE or IMERODE should be passed into MORPHOP following SE.  See
%   the help entries for IMDILATE and IMERODE for more details about the
%   allowable syntaxes.

%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 1.9.4.8 $  $Date: 2009/07/06 20:34:48 $

[A,se,pre_pad,...
 pre_pack,post_crop,post_unpack,op_type,is_packed,...
 unpacked_M,mex_method] = ParseInputs(varargin{:});

num_strels = length(se);

if is_packed
    % In a prepacked binary image, the fill bits at the bottom of the packed
    % array should be handled just like pad values.  The fill bits should be
    % 0 for dilation and 1 for erosion.
    
    fill_value = strcmp(op_type, 'erode');
    A = setPackedFillBits(A, unpacked_M, fill_value);
end

if pre_pad
    % Find the array offsets and heights for each structuring element
    % in the sequence.
    offsets = cell(1,num_strels);
    for k = 1:num_strels
        offsets{k} = getneighbors(se(k));
    end
    
    % Now compute how padding is needed based on the strel offsets.
    [pad_ul, pad_lr] = PadSize(offsets,op_type);
    P = length(pad_ul);
    Q = ndims(A);
    if P < Q
        pad_ul = [pad_ul zeros(1,Q-P)];
        pad_lr = [pad_lr zeros(1,Q-P)];
    end
    
    if is_packed
        % Input is packed binary.  Adjust padding appropriately.
        pad_ul(1) = ceil(pad_ul(1) / 32);
        pad_lr(1) = ceil(pad_lr(1) / 32);
    end
    
    pad_val = getPadValue(A, op_type);

    A = padarray(A,pad_ul,pad_val,'pre');
    A = padarray(A,pad_lr,pad_val,'post');
end

if pre_pack
    unpacked_M = size(A,1);
    A = bwpack(A);
end


%
% Apply the sequence of dilations/erosions.
%
B = A;
for k = 1:num_strels
    B = morphmex(mex_method, B, double(getnhood(se(k))), getheight(se(k)), unpacked_M);
end

%
% Image postprocessing steps.
%
if post_unpack
    B = bwunpack(B,unpacked_M);
end

if post_crop
    % Extract the "middle" of the result; it should be the same size as
    % the input image.
    idx = cell(1,ndims(B));
    for k = 1:ndims(B)
        P = size(B,k) - pad_ul(k) - pad_lr(k);
        first = pad_ul(k) + 1;
        last = first + P - 1;
        idx{k} = first:last;
    end
    B = B(idx{:});
end
%--------------------------------------------------------------------------

%==========================================================================
function pad_value = getPadValue(A, op_type)
% Returns the appropriate pad value, depending on whether we are performing
% erosion or dilation, and whether or not A is logical (binary).

if strcmp(op_type, 'dilate')
   pad_value = -Inf;
else
   pad_value = Inf;
end

if islogical(A)
   % Use 0s and 1s instead of plus/minus Inf.
   pad_value = max(min(pad_value, 1), 0);
end
%--------------------------------------------------------------------------

%==========================================================================
function B = setPackedFillBits(A, M, value)
% Set any fill bits in the last row of the packed array A to the specified
% value.  M is the number of rows in the original unpacked array.

B = A;
num_pad_bits = getNumPadBits(M);
if num_pad_bits == 0
   return;
end

% Make a mask value with 0s in the fill-bit positions and 1s elsewhere.
first_mask_bit = 1;
last_mask_bit = 32 - num_pad_bits;
mask_value = getUint32MaskValue(first_mask_bit:last_mask_bit);

last_row = B(end,:);

if value
   modified_last_row = bitor(last_row, bitcmp(mask_value));
else
   modified_last_row = bitand(last_row, mask_value);
end

B(end, :) = modified_last_row;
%--------------------------------------------------------------------------

%==========================================================================
function n = getNumPadBits(M)
% Given the number of rows in a binary image, returns the number of pad
% bits in the last row of the packed form.

n = 32 * ceil(M / 32) - M;
%--------------------------------------------------------------------------

%==========================================================================
function mask = getUint32MaskValue(bit_locations)
% Given a vector of bit_locations, return a scalar uint32 value with those
% bits set to 1.  A bit location of 1 corresponds to the least-significant
% bit.

mask = uint32(0);
for k = 1:numel(bit_locations)
   mask = bitset(mask, bit_locations(k));
end
%--------------------------------------------------------------------------

%==========================================================================
function [A,se,pre_pad,pre_pack, ...
          post_crop,post_unpack,op_type,input_is_packed, ...
          unpacked_M,mex_method] = ParseInputs(A,se,op_type,func_name,varargin)

iptchecknargin(2,5,nargin-2,func_name);

% Get the required inputs and check them for validity.
se = strelcheck(se,func_name,'SE',2);
A = CheckInputImage(A, func_name);

% Process optional arguments.
[padopt,packopt,unpacked_M] = ProcessOptionalArgs(func_name, varargin{:});
if strcmp(packopt,'ispacked')
    CheckUnpackedM(unpacked_M, size(A,1));
end

%
% Figure out the appropriate image preprocessing steps, image 
% postprocessing steps, and MEX-file method to invoke.
%
% First, find out the values of all the necessary predicates.
% 
se = getsequence(se);
num_strels = length(se);
strel_is_all_flat = all(isflat(se));
input_numdims = ndims(A);
strel_is_single = num_strels == 1;
class_A = class(A);
input_is_uint32 = strcmp(class_A,'uint32');
input_is_packed = strcmp(packopt,'ispacked');
input_is_logical = islogical(A);
input_is_2d = ndims(A) == 2;
output_is_full = strcmp(padopt,'full');

strel_is_all_2d = true;
for k = 1:length(se)
    if (ndims(getnhood(se(k))) > 2)
        strel_is_all_2d = false;
        break;
    end
end

%
% Check for error conditions related to packing
%
if input_is_packed && strcmp(op_type, 'erode') && (unpacked_M < 1)
    eid = sprintf('Images:%s:missingPackedM', func_name);  
    error(eid, 'M must be provided for packed erosion.');
end
if input_is_packed && ~strel_is_all_2d
    eid = sprintf('Images:%s:packedStrelNot2D', func_name);
    error(eid, ...
        'Cannot perform packed erosion or dilation unless structuring element is 2-D.');
end
if input_is_packed && ~input_is_uint32
    eid = sprintf('Images:%s:invalidPackedInputType', func_name);
    error(eid, ...
        'Input image must be uint32 for packed erosion or dilation.');
end
if input_is_packed && ~strel_is_all_flat
    eid = sprintf('Images:%s:nonflatStrelPacked', func_name);
    error(eid, ...
        'Structuring element must be flat for packed erosion or dilation.');
end
if input_is_packed && (input_numdims > 2)
    eid = sprintf('Images:%s:packedImageNot2D', func_name);
    error(eid, ...
        'Cannot perform packed erosion or dilation unless input image is 2-D.');
end
if input_is_packed && output_is_full
    eid = sprintf('Images:%s:packedFull', func_name);
    error(eid, ...
        'Cannot perform packed erosion or dilation with the ''full'' option.');
end

%
% Next, use predicate values to determine the necessary
% preprocessing and postprocessing steps.
%

% If the user has asked for full-size output, or if there are multiple
% and/or decomposed strels that are not rectangular, then pre-pad the input image.
pre_pad = output_is_full || (~strel_is_single && ~NhoodShapesOrthogonal(se));

% If the input image is logical, then the strel must be flat.
if input_is_logical && ~strel_is_all_flat
    msgId = sprintf('Images:%s:binaryWithNonflatStrel', func_name);
    error(msgId, ...
        'Function %s cannot perform dilate a binary image with a nonflat structuring element.', ...
        func_name);
end

% If the input image is logical and not packed, and if there are multiple
% all-flat strels, the prepack the input image.
pre_pack = ~strel_is_single & input_is_logical & input_is_2d & ...
    strel_is_all_flat & strel_is_all_2d;

% If we had to pre-pad the input but the user didn't specify the 'full'
% option, then crop the image before returning it.
post_crop = pre_pad & ~output_is_full;

% If this function pre-packed the image, unpack it before returning it.
post_unpack = pre_pack;

%
% Finally, determine the appropriate MEX-file method to invoke.
%
if pre_pack || strcmp(packopt,'ispacked')
    mex_method = sprintf('%s_binary_packed',op_type);
    
elseif input_is_logical 
    if input_is_2d && strel_is_single && strel_is_all_2d
        if isequal(getnhood(se), ones(3))
            mex_method = sprintf('%s_binary_ones33',op_type);
        else
            mex_method = sprintf('%s_binary_twod',op_type);
        end
    else
        mex_method = sprintf('%s_binary',op_type);
    end
elseif strel_is_all_flat
    
    if useIPP3x3(class_A,se,input_is_2d,strel_is_single,strel_is_all_2d)
        mex_method = sprintf('%s_gray_ipp33',op_type);
    else
        mex_method = sprintf('%s_gray_flat',op_type);
    end
    
else
    mex_method = sprintf('%s_gray_nonflat',op_type);
end
%--------------------------------------------------------------------------

%==========================================================================
function TF = useIPP3x3(class_A,se,is2DInput,strelIsSingle,strelIsAll2D)

TF = false;
if ~isempty(se) && strelIsSingle
    nhood = getnhood(se);
else
    return;
end
    
is3x3nhood = isequal(nhood,ones(3));
supportedType = ~isempty(strmatch(class_A,{'single','uint8','uint16'}));
TF = is3x3nhood && is2DInput && supportedType && strelIsAll2D && ippl(); 
%--------------------------------------------------------------------------

%==========================================================================
function [padopt,packopt,unpacked_M] = ProcessOptionalArgs(func_name, varargin)

% Default values
padopt = 'same';
packopt = 'notpacked';
unpacked_M = -1;
check_M = false;

allowed_strings = {'same','full','ispacked','notpacked'};

for k = 1:length(varargin)
    if ischar(varargin{k})
        string = iptcheckstrs(varargin{k}, allowed_strings, ...
                              func_name, 'OPTION', k+2);
        switch string
         case {'full','same'}
          padopt = string;
          
         case {'ispacked','notpacked'}
          packopt = string;
          
        end
        
    else
        unpacked_M = varargin{k};
        check_M = true;
        M_pos = k+2;
    end
end

if check_M
    iptcheckinput(unpacked_M, {'double'},...
                  {'real' 'nonsparse' 'scalar' 'integer' 'nonnegative'}, ...
                  func_name, 'M', M_pos);
end
%--------------------------------------------------------------------------

%==========================================================================
function B = CheckInputImage(A,op_function)

B = A;

iptcheckinput(A, {'numeric' 'logical'}, {'real' 'nonsparse'}, ...
              op_function, 'IM', 1);
%--------------------------------------------------------------------------

%==========================================================================
function CheckUnpackedM(unpacked_M, M)

if unpacked_M >= 0
    d = 32*M - unpacked_M;
    if (d < 0) || (d > 31)
        eid = 'Images:imerode:inconsistentUnpackedM';
        error(eid, ...
            'M is not consistent with the row dimension of the image.');
    end
end
%--------------------------------------------------------------------------

%==========================================================================
function [pad_ul, pad_lr] = PadSize(offsets,op_type)

if isempty(offsets)
    pad_ul = zeros(1,2);
    pad_lr = zeros(1,2);

else
    num_dims = size(offsets{1},2);
    for k = 2:length(offsets)
        num_dims = max(num_dims, size(offsets{k},2));
    end
    for k = 1:length(offsets)
        offsets{k} = [offsets{k} zeros(size(offsets{k},1),...
                                       num_dims - size(offsets{k},2))];
    end
    
    pad_ul = zeros(1,num_dims);
    pad_lr = zeros(1,num_dims);
    
    for k = 1:length(offsets)
        offsets_k = offsets{k};
        if ~isempty(offsets_k)
            pad_ul = pad_ul + max(0, -min(offsets_k,[],1));
            pad_lr = pad_lr + max(0, max(offsets_k,[],1));
        end
    end
    
    if strcmp(op_type,'erode')
        % Swap
        tmp = pad_ul;
        pad_ul = pad_lr;
        pad_lr = tmp;
    end
end
%--------------------------------------------------------------------------

%==========================================================================
function TF = NhoodShapesOrthogonal(se)

% Algorithm:
% * Create a matrix P where each row contains the size vector for the nhood of
%   one strel in the sequence se. (se is already a sequence so we don't need to
%   call getsequence(se) again here.)
%
% * Trailing singleton dimensions are added as needed for strels with fewer
%   dimensions.
%
% * Find all values of P~=1. If there's only one of these in each column,
%   the set of strels se is orthogonal.

num_strels = numel(se);

P = ones(num_strels,2);

for k = 1:num_strels
    nhood_size = size(getnhood(se(k)));
    P(k,1:numel(nhood_size)) = nhood_size; 
end

% Fill in trailing singleton dimensions as needed
P(P==0) = 1;

TF = any( sum(P~=1,1) == 1);





