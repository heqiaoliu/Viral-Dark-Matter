function y = issorted(x,rflag)
%Embedded MATLAB Library Function

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
eml_assert(nargin > 0,'Not enough input arguments.');
y = true;
if isempty(x)
    return
end
if nargin == 1
    eml_assert(eml_is_const(isvector(x)), ...
        ['If ''rows'' is not specified, the input must be a vector ', ...
        'with at most one variable-length dimension, the first ', ...
        'dimension or the second. All other dimensions must have a ', ...
        'fixed length of 1.']);
    eml_assert(isvector(x), ...
        'Input must be a vector or ''rows'' must be specified.');
    nm1 = eml_index_minus(eml_numel(x),1);
    for k = 1:nm1
        if ~eml_sort_le(x,'a',k,eml_index_plus(k,1))
            y = false;
            return
        end
    end
else
    eml_assert(strcmp(rflag,'rows'),'Unknown flag');
    col = ones(eml_index_class):size(x,2);
    nm1 = eml_index_minus(size(x,1),1);
    for k = 1:nm1
        if ~eml_sort_le(x,col,k,eml_index_plus(k,1))
            y = false;
            return
        end
    end
end
