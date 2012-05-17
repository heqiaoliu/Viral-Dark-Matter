function [b,ndx,pos] = unique(a,varargin)
%Embedded MATLAB Library Function

%   Limitations:
%   1. When 'rows' is not specified:
%       The first input must be a row vector. If the vector is
%       variable-size, its first dimension must have a fixed length of 1.
%       The input [] is not supported. Use a 1-by-0 input (e.g.,
%       zeros(1,0)) to represent the empty set.  Empty outputs are always
%       row vectors, 1-by-0, never 0-by-0.
%   2. When 'rows' is specified:
%       Outputs NDX and POS are always column vectors, 0-by-1 if empty,
%       never 0-by-0, even if the output B is 0-by-0.
%   3. Complex inputs must be 'single' or 'double'.

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(nargin <= 3, 'Too many input arguments.');
eml_assert(isa(a,'numeric') || islogical(a) || ischar(a), ...
    'First input must be numeric, logical, or char.');
eml_assert(isa(a,'float') || isreal(a), ...
    'Complex inputs must be ''single'' or ''double''.');
[byrow,lastp] = parse_flags(varargin{:});
if byrow
    if nargout == 3
        [b,ndx,pos] = unique_rows(a,lastp);
    elseif nargout == 2
        [b,ndx] = unique_rows(a,lastp);
    else
        b = unique_rows(a,lastp);
    end
else
    if nargout == 3
        [b,ndx,pos] = unique_vector(a,lastp);
    elseif nargout == 2
        [b,ndx] = unique_vector(a,lastp);
    else
        b = unique_vector(a,lastp);
    end
end

%--------------------------------------------------------------------------

function [byrow,lastp] = parse_flags(varargin)
byrow = false;
lastp = true;
for k = eml.unroll(1:nargin)
    eml_assert(eml_is_const(varargin{k}) && ischar(varargin{k}), ...
        'Options must be constants character strings.');
    if strcmp(eml_tolower(varargin{k}),'first')
        lastp = false;
    elseif strcmp(eml_tolower(varargin{k}),'last')
    elseif strcmp(eml_tolower(varargin{k}),'rows')
        byrow = true;
    else
        eml_assert(false,'Unrecognized option.');
    end
end
eml_assert(nargin < 2 || ...
    ~strcmp(eml_tolower(varargin{1}),eml_tolower(varargin{2})), ...
    'You may not specify more than one value for the same option.');

%--------------------------------------------------------------------------

function [b,ndx,pos] = unique_vector(a,lastp)
% Handle empty: no elements.
eml_allow_enum_inputs;
if eml_is_const(size(a,1)) && size(a,1) == 1
    eml.varsize('b','ndx',[],[0,1]);
    maxnb = size(a,2);
else
    eml_assert(false, ... % 'EmbeddedMATLAB:unique:mustBeVector', ...
        ['Unless ''rows'' is specified, the first input must be a row ', ...
        'vector. If the vector is variable-size, the first dimension ', ...
        'must have a fixed length of 1. The input [] is not supported. ', ...
        'Use a 1-by-0 input (e.g., zeros(1,0)) to represent the empty set.'])
end
na = cast(eml_numel(a),eml_index_class);
ndx = eml.nullcopy(zeros(size(a)));
pos = eml.nullcopy(zeros(size(a)));
idx = eml_sort_idx(a,'a');
b = eml.nullcopy(eml_expand(eml_scalar_eg(a),size(a)));
for k = 1:na
    b(k) = a(idx(k));
end
[nMInf,nFinite,nInf,nNaN] = count_nonfinites(b,na);
nb = zeros(eml_index_class);
% Process -Inf entries.
if nMInf > 0
    nb = ones(eml_index_class);
    b(nb) = b(1);
    for j = 1:nMInf
        pos(idx(j)) = 1;
    end
    if lastp
        idx(nb) = idx(nMInf);
    else
        idx(nb) = idx(1);
    end
end
% Process finite entries.
khi = eml_index_plus(nMInf,nFinite);
k = eml_index_plus(nMInf,1);
while k <= khi
    x = b(k);
    k0 = k;
    % Seek forward for a different entry.
    while true
        k = eml_index_plus(k,1);
        if k > khi || ~eml_safe_eq(b(k),x)
            break
        end
    end
    % Record x.
    nb = eml_index_plus(nb,1);
    b(nb) = x;
    for j = k0:eml_index_minus(k,1)
        pos(idx(j)) = nb;
    end
    if lastp
        idx(nb) = idx(eml_index_minus(k,1));
    else
        idx(nb) = idx(k0);
    end
end
% Process Inf entries.
if nInf > 0
    nb = eml_index_plus(nb,1);
    b(nb) = b(eml_index_plus(khi,1));
    for j = 1:nInf
        pos(idx(eml_index_plus(khi,j))) = nb;
    end
    if lastp
        idx(nb) = idx(eml_index_plus(khi,nInf));
    else
        idx(nb) = idx(eml_index_plus(khi,1));
    end
end
% Process NaN entries.
k = eml_index_plus(khi,nInf);
for j = 1:nNaN
    nb = eml_index_plus(nb,1);
    b(nb) = b(eml_index_plus(k,j));
    pos(idx(eml_index_plus(k,j))) = nb;
    idx(nb) = idx(eml_index_plus(k,j));
end
% Trim output vectors.
assert(nb <= maxnb); %<HINT>
b = b(1:nb);
ndx = ndx(1:nb);
for k = 1:nb
    ndx(k) = idx(k);
end

%--------------------------------------------------------------------------

function [nMInf,nFinite,nPInf,nNaN] = count_nonfinites(b,nb)
eml_allow_enum_inputs;
k = ones(eml_index_class);
while k <= nb && isinf(b(k)) && b(k) < 0
    k = eml_index_plus(k,1);
end
nMInf = eml_index_minus(k,1);
k = nb;
while k >= 1 && isnan(b(k))
    k = eml_index_minus(k,1);
end
nNaN = eml_index_minus(nb,k);
while k >= 1 && isinf(b(k)) && b(k) > 0
    k = eml_index_minus(k,1);
end
nPInf = eml_index_minus(eml_index_minus(nb,k),nNaN);
nFinite = eml_index_minus(k,nMInf);

%--------------------------------------------------------------------------

function [b,ndx,pos] = unique_rows(a,lastp)
% Unique rows.
eml_allow_enum_inputs;
eml.varsize('b',[],[1,~eml_is_const(size(a,2))]);
eml.varsize('ndx',[],[1,0]);
eml_assert(ndims(a) == 2, 'Input must be 2-D.');
ndx = eml.nullcopy(zeros(size(a,1),1));
pos = eml.nullcopy(zeros(size(a,1),1));
if size(a,1) == 0
    b = a;
    return
end
[b,idx] = sortrows(a);
nb = zeros(eml_index_class);
khi = cast(size(a,1),eml_index_class);
k = ones(eml_index_class);
while k <= khi
    k0 = k;
    % Seek forward for a different row.
    while true
        k = eml_index_plus(k,1);
        if k > khi || rows_differ(b,k0,k)
            break
        end
    end
    % Record row k0.
    nb = eml_index_plus(nb,1);
    for j = ones(eml_index_class):size(b,2)
        b(nb,j) = b(k0,j);
    end
    for j = k0:eml_index_minus(k,1)
        pos(idx(j)) = nb;
    end
    if lastp
        idx(nb) = idx(eml_index_minus(k,1));
    else
        idx(nb) = idx(k0);
    end
end
% Trim output matrices.
assert(nb <= size(a,1)); %<HINT>
b = b(1:nb,:);
ndx = ndx(1:nb);
for k = 1:nb
    ndx(k) = idx(k);
end

%--------------------------------------------------------------------------

function p = rows_differ(b,k0,k)
% Returns ~isequal(b(k0,:),b(k,:)).
eml_allow_enum_inputs;
p = false;
for j = 1:size(b,2)
    if ~eml_safe_eq(b(k0,j),b(k,j))
        p = true;
        break
    end
end

%--------------------------------------------------------------------------
