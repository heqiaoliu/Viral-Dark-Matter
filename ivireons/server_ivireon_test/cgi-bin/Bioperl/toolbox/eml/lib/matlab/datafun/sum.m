function y = sum(x,in2,in3)
%Embedded MATLAB Library Function

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0,'Not enough input arguments.');
eml_assert(isa(x,'numeric') || ischar(x) || islogical(x), ...
    ['Function ''sum'' is not defined for values of class ''' class(x) '''.']);
if nargin == 1 && eml_is_const(size(x)) && isequal(x,[])
    y = cast(eml_scalar_eg(x),output_class(x));
    return
end
% Determine the dimension over which to perform the operation.
if nargin == 1 || (nargin == 2 && ischar(in2))
    eml_lib_assert(eml_is_const(size(x)) || ~isequal(x,[]), ...
        'EmbeddedMATLAB:sum:specialEmpty', ...
        'SUM with one variable-size matrix input of [] is not supported.');
    dim = eml_const_nonsingleton_dim(x);
    eml_lib_assert(eml_is_const(size(x,dim)) || ...
        isscalar(x) || ...
        size(x,dim) ~= 1, ...
        'EmbeddedMATLAB:sum:autoDimIncompatibility', ...
        ['The working dimension was selected automatically, is ', ...
        'variable-length, and has length 1 at run-time. This is not ', ...
        'supported. Manually select the working dimension by ', ...
        'supplying the DIM argument.']);
    % Determine the output class.
    if nargin == 1
        outcls = output_class(x);
    else
        outcls = output_class(x,in2);
    end
else
    eml_prefer_const(in2);
    eml_assert(eml_is_const(in2),'Dimension argument must be a constant.');
    eml_assert_valid_dim(in2);
    dim = cast(in2,eml_index_class);
    % Determine the output class.
    if nargin == 3
        outcls = output_class(x,in3);
    else
        outcls = output_class(x);
    end
end
if eml_is_const(size(x,dim)) && size(x,dim) == 1 % Covers dim > ndims(x) case.
    y = cast(x,outcls);
    return
end
sz = size(x);
sz(dim) = 1;
y = eml.nullcopy(eml_expand(eml_scalar_eg(cast(x,outcls)),sz));
if isempty(x)
    y(:) = 0;
elseif eml_is_const(isscalar(y)) && isscalar(y)
    vlen = cast(eml_numel(x),eml_index_class);
    y = cast(x(1),outcls);
    for k = 2:vlen;
        y = y + cast(x(k),outcls);
    end
else
    vlen = cast(size(x,dim),eml_index_class);
    vstride = eml_matrix_vstride(x,dim);
    npages = eml_matrix_npages(x,dim);
    ix = zeros(eml_index_class);
    iy = zeros(eml_index_class);
    for i = 1:npages
        ixstart = ix;
        for j = 1:vstride
            ixstart = eml_index_plus(ixstart,1);
            ix = ixstart;
            s = cast(x(ix),outcls);
            for k = 2:vlen
                ix = eml_index_plus(ix,vstride);
                s = s + cast(x(ix),outcls);
            end
            iy = eml_index_plus(iy,1);
            y(iy) = s;
        end
    end
end

%--------------------------------------------------------------------------

function outcls = output_class(x,cls)
if nargin == 2
    if ischar(cls) && strcmp(cls,'native')
        eml_assert(~ischar(x), ...
            'Native accumulation on char array is not supported.');
        eml_assert(isreal(x) || ~isinteger(x), ...
            'Complex integer summation is not supported.');
        outcls = class(x);
    elseif ischar(cls) && strcmp(cls,'double')
        outcls = cls;
    else
        eml_assert(false, ...
            'Trailing string input must be ''double'' or ''native''.');
    end
else
    if isa(x,'single') 
        outcls = 'single';
    else
        outcls = 'double';
    end
end

%--------------------------------------------------------------------------
