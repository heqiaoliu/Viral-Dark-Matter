function y = eml_all_or_any(op,x,dim)
%Embedded MATLAB Library Function

%   Suitable for general types provided that EQ(X,0), NEQ(X,0), and ISNAN
%   are defined.

%   Copyright 2002-2010 The MathWorks, Inc.
%#eml

eml_assert(nargin > 1, 'Not enough input arguments.');
eml_assert(ischar(op) && strcmp(op,'all') || strcmp(op,'any'), ...
    'First input must be ''all'' or ''any''.');
eml_must_inline;
allp = eml_const(strcmp(op,'all'));
if nargin < 3
    if eml_is_const(size(x)) && isequal(x,[])
        % Special case: all([]) --> true.
        % Special case: any([]) --> false.
        y = allp;
        return
    end
    eml_lib_assert(eml_is_const(size(x)) || ~isequal(x,[]), ...
        'EmbeddedMATLAB:eml_all_or_any:specialEmpty', ...
        ['ALL or ANY with one variable-size matrix input of [] is ', ...
        'not supported.']);
    dim = eml_const_nonsingleton_dim(x);
    eml_lib_assert(eml_is_const(size(x,dim)) || ...
        isscalar(x) || ...
        size(x,dim) ~= 1, ...
        'EmbeddedMATLAB:eml_all_or_any:autoDimIncompatibility', ...
        ['The working dimension was selected automatically, is ', ...
        'variable-size, and has length 1 at run-time. This is not ', ...
        'supported. Manually select the working dimension by ', ...
        'supplying the DIM argument.']);
else
    eml_prefer_const(dim);
    eml_assert(eml_is_const(dim),'Dimension argument must be a constant.');
    eml_assert_valid_dim(dim);
end
codingForHdl = strcmp(eml.target(), 'hdl');
if eml_const(eml_is_const(size(x)) && isscalar(x))
    % Quick code for scalar case.
    eml_must_inline;
    if allp || codingForHdl % NAN check is disabled for hdl.
        y = x(1) ~= 0;
    else
        y = ~(x(1) == 0 || isnan(x(1)));
    end
    return
end
if dim > eml_ndims(x)
    outsize = size(x);
else
    outsize = size(x);
    outsize(dim) = 1;
end
if allp
    y = eml_expand(true,outsize);
else
    y = eml_expand(false,outsize);
end
if eml_is_const(isempty(x)) && isempty(x)
elseif codingForHdl
    eml_assert(isvector(x),'Matrix input not supported for HDL target.');
    if isscalar(y) % Operating along the length of a vector.
        % Exiting in the middle of for loop will cause unstructured cgir
        % not supported by hdl; check all elements and do not short ckt.
        if allp
            for k = 1:eml_numel(x)
                y = y & (x(k) ~= 0); % intentional & rather than && here.
            end
        else
            for k = 1:eml_numel(x)
                y = y | (x(k) ~= 0); % intentional | rather than || here.
            end
        end
    else % Operating on each element of a vector.
        y = (x ~= 0);
    end
elseif eml_is_const(size(x)) && (size(x,dim) == eml_numel(x))
    if allp
        for k = 1:eml_numel(x)
            if x(k) == 0
                y = false;
                break
            end
        end
    else
        for k = 1:eml_numel(x)
            if ~(x(k) == 0 || isnan(x(k)))
                y = true;
                break
            end
        end
    end
else
    vlen = size(x,dim);
    vstride = eml_matrix_vstride(x,dim);
    vspread = eml_index_times(eml_index_minus(vlen,1),vstride);
    npages = eml_matrix_npages(x,dim);
    i2 = zeros(eml_index_class);
    iy = zeros(eml_index_class);
    for i = 1:npages
        i1 = i2;
        i2 = eml_index_plus(i2,vspread);
        for j = 1:vstride
            i1 = eml_index_plus(i1,1);
            i2 = eml_index_plus(i2,1);
            iy = eml_index_plus(iy,1);
            for ix = i1:vstride:i2
                if allp
                    if x(ix) == 0
                        y(iy) = false;
                        break
                    end
                else
                    if ~(x(ix) == 0 || isnan(x(ix)))
                        y(iy) = true;
                        break
                    end
                end
            end
        end
    end
end
