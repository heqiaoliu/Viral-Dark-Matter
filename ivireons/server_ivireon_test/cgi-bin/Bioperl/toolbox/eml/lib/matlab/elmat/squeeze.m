function b = squeeze(a)
%Embedded MATLAB Library Function

%   Copyright 2006-2009 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
eml_assert(nargin == 1, 'Not enough input arguments.');
ONE = ones(eml_index_class);
if ndims(a) <= 2
    % This is simply b = a in the fixed-size case, but in the variable-size
    % case it helps to make it clear that only the first two dimensions can
    % have bounds affected here.
    sqsz = eml.nullcopy(zeros(1,eml_ndims(a),eml_index_class));
    sqsz(1) = size(a,1);
    sqsz(2) = size(a,2);
    for k = eml.unroll(cast(3,eml_index_class):eml_ndims(a))
        sqsz(k) = ONE;
    end
    b = eml.nullcopy(eml_expand(eml_scalar_eg(a),sqsz));
    for k = ONE:eml_numel(a)
        b(k) = a(k);
    end
    return
end
% For technical reasons it turns out to be necessary to have the same size
% computation both inline (for variably sized inputs) and as a subfunction
% (for statically sized inputs).
if eml_is_const(size(a))
    sqsz = squeeze_size(a);
else
    sqsz = ones(1,eml_ndims(a),eml_index_class);
    upperdims = eml_index_plus(eml_ndims(a),ONE);
    for k = eml.unroll(ONE:eml_ndims(a))
        if eml_is_const(size(a,k)) && size(a,k) == 1
            upperdims = eml_index_minus(upperdims,ONE);
        end
    end
    j = ONE;
    for k = eml.unroll(ONE:eml_ndims(a))
        if size(a,k) ~= 1
            sqsz(j) = size(a,k);
            j = eml_index_plus(j,1);
        end
    end
    for k = eml.unroll(upperdims:eml_ndims(a))
        sqsz(k) = ONE;
    end
end
b = eml.nullcopy(eml_expand(eml_scalar_eg(a),sqsz));
for k = ONE:eml_numel(a)
    b(k) = a(k);
end

%--------------------------------------------------------------------------

function sqsz = squeeze_size(a)
eml_allow_enum_inputs;
ONE = ones(eml_index_class);
sqsz = ones(1,eml_ndims(a),eml_index_class);
j = ONE;
for k = 1:eml_ndims(a)
    if size(a,k) ~= 1
        sqsz(j) = size(a,k);
        j = eml_index_plus(j,1);
    end
end

%--------------------------------------------------------------------------
