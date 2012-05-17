function ndx = sub2ind(siz,varargin)
%Embedded MATLAB Library Function

%   Limitations:
%   1. PROD(SIZ) > INTMAX is not supported.

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin >= 2, 'Not enough input arguments.');
eml_assert(isa(siz,'numeric'),'Size argument must be numeric.');
eml_assert(eml_is_const(size(siz)),'First input must be fixed-size.');
eml_prefer_const(siz);
ndx = eml_sub2ind(cast(siz,eml_index_class),varargin{:});

%--------------------------------------------------------------------------

function ndx = eml_sub2ind(siz,varargin)
% SUB2IND algorithm assuming isa(siz,eml_index_class).
nsiz = eml_numel(siz);
% Input checking
eml_lib_assert(nsiz >= 2, ...
    'MATLAB:sub2ind:InvalidSize', ...
    'Size vector must have at least 2 elements.');
nsubs = nargin - 1;
m = min(nsubs,nsiz);
for k = eml.unroll(1:nsubs)
    % eml_prefer_const(varargin{k});
    if k > 1
        eml_lib_assert(isequal(size(varargin{1}),size(varargin{k})), ...
            'MATLAB:sub2ind:SubscriptVectorSize', ...
            'The subscripts vectors must all be of the same size.');
    end
    if k < m
        hi = siz(k);
    elseif k > m
        hi = ones(eml_index_class);
    else
        hi = prodsub(siz,m,nsiz);
    end
    eml_lib_assert(allinrange(varargin{k},1,hi), ...
        'MATLAB:sub2ind:IndexOutOfRange', ...
        'Out of range subscript.');
end
% Compute linear indices
psiz = siz(1);
idx = cast(varargin{1},eml_index_class);
for k = eml.unroll(2:m)
    idx = eml_index_plus(idx, ...
        eml_index_times(psiz, ...
        eml_index_minus(varargin{k},1)));
    if k < m
        psiz = eml_index_times(psiz,siz(k));
    end
end
ndx = cast(idx,class(eml_scalar_eg(varargin{:})));

%--------------------------------------------------------------------------

function p = allinrange(x,lo,hi)
% p = ~any(x(:)<lo | x(:)>hi) without temporaries.
for k = 1:eml_numel(x)
    if ~(x(k) >= lo && x(k) <= hi)
        p = false;
        return
    end
end
p = true;

%--------------------------------------------------------------------------

function y = prodsub(x,lo,hi)
% y = prod(x(lo:hi)) for isa(x,eml_index_class).
y = ones(eml_index_class);
for k = lo:hi
    y = eml_index_times(y,x(k));
end

%--------------------------------------------------------------------------
