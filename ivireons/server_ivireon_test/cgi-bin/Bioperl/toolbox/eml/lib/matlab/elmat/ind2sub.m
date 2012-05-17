function varargout = ind2sub(siz,ndx)
%Embedded MATLAB Library Function

%   Limitations:
%   1. PROD(SIZ) > INTMAX is not supported.
%   2. Errors if any input index is less than 1 or greater than PROD(SIZ)
%   (when nargout > 1).

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin == 2, 'Not enough input arguments.');
eml_assert(eml_is_const(size(siz)),'First input must be fixed-size.');
eml_prefer_const(siz,ndx);
eml_assert(isa(siz,'numeric'),'Size argument must be numeric.');
nsiz = eml_numel(siz);
m = eml_const(min(nargout,nsiz));
if m < 2
    eml_assert(nargout <= 1, 'Too many output arguments.');
    varargout{1} = ndx;
    return
end
cpsiz = cumprodsize(siz,m-1);
maxndx = eml_index_times(cpsiz(m-1),eml_index_prod(siz,m,nsiz));
eml_lib_assert(allinrange(ndx,1,maxndx), ...
    'MATLAB:ind2sub:IndexOutOfRange', ...
    'Out of range subscript.');
v1 = eml_index_minus(ndx,1);
for k = eml.unroll(m:-1:2)
    vk = eml_index_rdivide(v1,cpsiz(k-1));
    varargout{k} = cast(eml_index_plus(vk,1),class(ndx));
    v1 = eml_index_minus(v1,eml_index_times(vk,cpsiz(k-1)));
end
varargout{1} = cast(eml_index_plus(v1,1),class(ndx));
% Set trivial output arguments.
for k = eml.unroll(m+1:nargout)
    varargout{k} = ones(size(ndx),class(ndx));
end

%--------------------------------------------------------------------------

function y = cumprodsize(siz,nd)
% y = cast(cumprod(siz(1:nd)),eml_index_class) in non-saturating integer
% arithmetic.
y = cast(siz(1:nd),eml_index_class);
for k = 2:nd
    y(k) = eml_index_times(y(k),y(k-1));
end

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
