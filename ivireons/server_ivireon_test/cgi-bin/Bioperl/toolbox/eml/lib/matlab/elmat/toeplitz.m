function t = toeplitz(c,r)
%Embedded MATLAB Library Function

%   Copyright 2005-2010 The MathWorks, Inc.
%#eml

eml_assert(nargin >= 1, 'Not enough input arguments.');
if nargin < 2
    if isreal(c)
        t = toep(c,c);
    else
        % Complex: set up for Hermitian Toeplitz.
        c1 = c(1); r = c; c = conj(c); c(1) = c1; 
        t = toep(c,r);
    end
else
    if ~(isempty(r) || isempty(c)) && r(1) ~= c(1)
        eml_warning('MATLAB:toeplitz:DiagonalConflict',['First element of ' ...
            'input column does not match first element of input row. ' ...
            '\n         Column wins diagonal conflict.'])
    end
    t = toep(c,r);
end

%--------------------------------------------------------------------------

function t = toep(c,r)
m = cast(eml_numel(c),eml_index_class);
n = cast(eml_numel(r),eml_index_class);
t = eml.nullcopy(eml_expand(eml_scalar_eg(c,r),[m,n]));
% The index computations are tweaked here to avoid -1 indexing in the 
% generated C code.  For example, it appears that ij+1 is computed multiple
% times, but indexing with ij+1 in MATLAB corresponds to indexing with ij in C.
ij = zeros(eml_index_class);
for j = 0:eml_index_minus(n,1)
    k = j;
    for i = 0:eml_index_minus(m,1)
        if i < j
            t(eml_index_plus(ij,1)) = r(eml_index_plus(k,1));
            k = eml_index_minus(k,1);
        else
            t(eml_index_plus(ij,1)) = c(eml_index_plus(k,1));
            k = eml_index_plus(k,1);
        end
        ij = eml_index_plus(ij,1);
    end
end

%--------------------------------------------------------------------------
