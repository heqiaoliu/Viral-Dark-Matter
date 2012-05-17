function a = ipermute(b,order)
%Embedded MATLAB Library Function

%   Copyright 1984-2008 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
eml_assert(nargin == 2, 'Not enough input arguments.');
eml_assert(~eml.isenum(order), 'Enumerations not supported for ORDER input.');
eml_prefer_const(order);
eml_assert(eml_is_const(order) || eml_option('VariableSizing'), ...
    'ORDER must be constant.');
if ~isreal(order) || ~isvector(order)
    a = ipermute(b,real(order(:)));
    return
end
eml_lib_assert(eml_numel(order) >= ndims(b), ...
    'EmbeddedMATLAB:ipermute:orderNeedsNElements', ...
    'ORDER must have at least N elements for an N-D array.');
eml_lib_assert(eml_is_permutation(real(order)), ...
    'EmbeddedMATLAB:ipermute:invalidPermutation', ...
    'ORDER must be a permutation of 1:n, where n >= ndims(B).');
a = permute(b,invperm(real(order)));

%--------------------------------------------------------------------------

function q = invperm(p)
% Function to invert permutation
% p(p) = 1:eml_numel(p);
q = zeros(1,eml_numel(p),eml_index_class);
for k = 1:eml_numel(p)
    q(p(k)) = k;
end

%--------------------------------------------------------------------------
