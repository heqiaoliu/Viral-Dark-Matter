function B = rot90(A,k)
%Embedded MATLAB Library Function

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
eml_lib_assert(ndims(A) == 2, 'MATLAB:rot90:SizeA', 'A must be a 2-D matrix.');
m = cast(size(A,1),eml_index_class);
n = cast(size(A,2),eml_index_class);
ega = eml_scalar_eg(A);
if nargin == 1
    k1 = int8(1);
else
    eml_assert(~eml.isenum(k), 'Enumerations not supported for k input.');
    eml_prefer_const(k);
    eml_assert(isreal(k) && isscalar(k), 'k must be a scalar.');
    eml_assert(eml_is_const(k) || eml_option('VariableSizing'), ...
        'k must be a constant.');
    if isinteger(k)
        k1 = mod(k,cast(4,class(k)));
    else
        k1 = int8(mod(double(k),4));
    end
end
if k1 == 1
    % B = flipud(A.');
    B = eml.nullcopy(eml_expand(ega,[n,m]));
    for i = 1:n
        for j = 1:m
            B(i,j) = A(j,eml_index_plus(eml_index_minus(n,i),1));
        end
    end
elseif k1 == 2
    % B = flipud(fliplr(A));
    B = eml.nullcopy(eml_expand(ega,[m,n]));
    for j = 1:n
        for i = 1:m
            B(i,j) = A(eml_index_plus(eml_index_minus(m,i),1), ...
                eml_index_plus(eml_index_minus(n,j),1));
        end
    end
elseif k1 == 3
    % B = flipud(A).';
    B = eml.nullcopy(eml_expand(ega,[n,m]));
    for i = 1:n
        for j = 1:m
            B(i,j) = A(eml_index_plus(eml_index_minus(m,j),1),i);
        end
    end
else
    B = A;
end

