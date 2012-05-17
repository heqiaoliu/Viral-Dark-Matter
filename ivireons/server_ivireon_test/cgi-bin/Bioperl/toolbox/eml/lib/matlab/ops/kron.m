function K = kron(A,B)
%Embedded MATLAB Library Function

%   Limitations:
%   1) Does not support sparse matrices.

%   Previous versions by Paul Fackler, North Carolina State,
%   and Jordan Rosenthal, Georgia Tech.
%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Input argument ''A'' is undefined.');
eml_assert(nargin > 1, 'Input argument ''B'' is undefined.');
eml_assert(isa(A,'numeric') || ischar(A) || islogical(A), ...
    ['Function ''kron'' is not defined for values of class ''' class(A) '''.']);
eml_assert(isa(B,'numeric') || ischar(B) || islogical(B), ...
    ['Function ''kron'' is not defined for values of class ''' class(B) '''.']);
eml_lib_assert(ndims(A) == 2 && ndims(B) == 2, ...
    'MATLAB:kron:TwoDInput', ...
    'Inputs must be 2-D.');
ma = cast(size(A,1),eml_index_class);
na = cast(size(A,2),eml_index_class);
mb = cast(size(B,1),eml_index_class);
nb = cast(size(B,2),eml_index_class);
mk = eml_index_times(ma,mb);
nk = eml_index_times(na,nb);
K = eml.nullcopy(eml_expand(eml_scalar_eg(A,B),[mk,nk]));
kidx = zeros(eml_index_class);
for j1 = 1:na
    for j2 = 1:nb
        for i1 = 1:ma
            for i2 = 1:mb
                kidx = eml_index_plus(kidx,1);
                K(kidx) = A(i1,j1)*B(i2,j2);
            end
        end
    end
end        
