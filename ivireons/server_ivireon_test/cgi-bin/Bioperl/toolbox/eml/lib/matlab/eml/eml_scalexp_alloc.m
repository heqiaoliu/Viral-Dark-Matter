function z = eml_scalexp_alloc(egscalar,varargin)
%Embedded MATLAB Private Function

%   Allocate (eml.nullcopy) an array of the type of egscalar and size
%   determined by scalar expansion rules applied to the varargin inputs.

%   Copyright 2005-2009 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
for k = eml.unroll(1:nargin-1)
    if  ~(eml_is_const(isscalar(varargin{k})) && isscalar(varargin{k}))
        % Found the first non-scalar input.
        z = eml.nullcopy(eml_expand(egscalar,size(varargin{k})));
        for j = eml.unroll(k+1:nargin-1)
            eml_lib_assert( ...
                (eml_is_const(isscalar(varargin{j})) && ...
                isscalar(varargin{j})) || ...
                isequal(size(varargin{j}),size(z)), ...
                'MATLAB:dimagree', ...
                'Matrix dimensions must agree.');
        end
        return
    end
end
% All inputs are scalar.
z = eml.nullcopy(egscalar);
