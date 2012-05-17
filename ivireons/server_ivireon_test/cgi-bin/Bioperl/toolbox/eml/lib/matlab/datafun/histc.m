function [N,BIN] = histc(X,edges,dim)
%Embedded MATLAB Library Function

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
eml_assert(nargin>1, 'Not enough input arguments.');
eml_assert(isreal(X), 'All inputs must be real.');
eml_assert(isa(X,'numeric') || ischar(X), ...
    'First input must be non-sparse numeric array.');
eml_assert(isa(edges,'numeric') || ischar(edges), ...
    'Second input must be numeric.');
% Check dims argument (if given) for validity.
if nargin < 3
    dim = eml_const_nonsingleton_dim(X);
    eml_lib_assert(eml_is_const(size(X,dim)) || ...
        isscalar(X) || ...
        size(X,dim) ~= 1, ...
        'EmbeddedMATLAB:histc:autoDimIncompatibility', ...
        ['The working dimension was selected automatically, is ', ...
        'variable-length, and has length 1 at run-time. This is not ', ...
        'supported. Manually select the working dimension by ', ...
        'supplying the DIM argument.']);
else
    eml_assert(~eml.isenum(edges), 'Second input does not allow enumerations');
    eml_assert(eml_is_const(dim), 'Dimension argument must be a constant.');
    eml_assert_valid_dim(dim);
end
% Allocate output matrices.
nbins = eml_numel(edges);
% getresultsize: calculate size of result.
if eml_is_const(isvector(X)) && isvector(X) && ...
        dim == 1 && eml_is_const(size(X,2)) && size(X,2) == 1
    outsize = size(X);
    outsize(1) = nbins;
    outsize(2) = 1;
elseif eml_is_const(isvector(X)) && isvector(X) && ...
        dim == 2 && eml_is_const(size(X,1)) && size(X,1) == 1
    outsize = size(X);
    outsize(1) = 1;
    outsize(2) = nbins;
elseif dim > eml_ndims(X)
    outsize = [size(X),ones(1,dim-eml_ndims(X))];
outsize(dim) = nbins;
else
    outsize = size(X);
    outsize(dim) = nbins;
end
N = zeros(outsize);
BIN = zeros(size(X));
ZERO = zeros(eml_index_class);
ONE = ones(eml_index_class);
% Check edges input.
if nbins > 1
    for m = 2:nbins
        if edges(m) < edges(m-1)
            eml_error('MATLAB:histc:InvalidInput3', ...
                'Edges vector must be monotonically non-decreasing.');
            % error is ignored in RTW; continue with good behavior.
            N(:) = eml_guarded_nan;
            BIN(:) = eml_guarded_nan;
            return
        end
    end
end
% stride length
stride = eml_matrix_vstride(X,dim);
% size of X along active dimension
mx = size(X,dim);
% Pick direction for speed.
if stride == ONE
    n1 = stride;
    n2 = eml_matrix_npages(X,dim); % eml_rdivide(eml_numel(X),mx);
    xoffset = ZERO;
    yoffset = ZERO;
else
    n1 = eml_matrix_npages(X,dim); % eml_rdivide(eml_rdivide(eml_numel(X),mx),stride);
    n2 = stride;
    xoffset = eml_index_minus(eml_index_times(stride,mx),1); % stride*mx-1
    yoffset = eml_index_minus(eml_index_times(stride,nbins),1); % stride*nbins-1
end
xind = ONE;
yind = ONE;
ystep = eml_index_minus(eml_index_times(stride,nbins),yoffset); % stride*nbins-yoffset
xpage = eml_index_minus(eml_index_plus(xoffset,1),stride); % xoffset-stride+1
ypage = eml_index_minus(eml_index_plus(yoffset,1),stride); % yoffset-stride+1
% main loop
for i = 1:n1 % page loop
    for j = 1:n2
        for k = 1:mx
            bin = findbin(X(xind),edges);
            if bin > 0
                % binind = yind + stride*(bin-1);
                binind = eml_index_plus(yind, ...
                    eml_index_times(stride, ...
                    eml_index_minus(bin,ONE)));
                N(binind) = N(binind) + 1;
            end
            BIN(xind) = bin;
            xind = eml_index_plus(xind,stride);
        end
        xind = eml_index_minus(xind,xoffset);
        yind = eml_index_plus(yind,ystep);
    end
    % go to next page of input and output arrays
    xind = eml_index_plus(xind,xpage);
    yind = eml_index_plus(yind,ypage);
end

%--------------------------------------------------------------------------

function k = findbin(x,bin_edges)
% Return index of bin the x.  x is in bin k if  bin_edges(k) <= x <
% bin_edges(k+1). Special case: x is in the last bin if x == bin_edges(nbins).
eml_allow_enum_inputs;
if eml.isenum(x)
    k = findbin(int32(x),bin_edges);
    return
end
k = zeros(eml_index_class);
if ~isempty(bin_edges) && ~isnan(x)
    % Use a binary search
    if x >= bin_edges(1) && x < bin_edges(end)
        k = eml_bsearch(bin_edges,x);
    end
    % Check for special case
    if x == bin_edges(end)
        k = cast(eml_numel(bin_edges),eml_index_class);
    end
end

%--------------------------------------------------------------------------
