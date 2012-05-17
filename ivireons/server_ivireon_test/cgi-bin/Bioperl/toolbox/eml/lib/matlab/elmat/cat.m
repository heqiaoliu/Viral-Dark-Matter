function y = cat(dim,varargin)
%Embedded MATLAB Library Function

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
eml_assert(nargin > 0, 'Not enough input arguments.');
eml_prefer_const(dim);
eml_assert_valid_dim(dim);
if nargin == 1
    y = [];
elseif nargin == 2
    y = varargin{1};
else
    ONE = ones(eml_index_class);
    ZERO = zeros(eml_index_class);
     eml_assert(eml_is_const(dim), ...
        'Dimension argument must be a constant.');
    ysize = catsize(dim,varargin{:});
    y = eml.nullcopy(eml_expand(cattype(varargin{:}),ysize));
    for k = eml.unroll(1:nargin-1)
        if ~eml_is_const(size(varargin{k}))
            assert(~isempty(varargin{k}), ... 
                'EmbeddedMATLAB:cat:UnsupportedVariableSizeEmpty', ...
                'CAT arguments cannot be variable-size empty arrays.');    
        end
        eml_lib_assert(isconsistent(dim,y,varargin{k}), ...
            'MATLAB:catenate:dimensionMismatch', ...
            'CAT arguments dimensions are not consistent.');
    end
    if dim >= eml_ndims(y)
        % Data is not interleaved.
        iy = ZERO;
        for k = eml.unroll(1:nargin-1)
            for j = ONE:eml_numel(varargin{k})
                iy = eml_index_plus(iy,ONE);
                y(iy) = varargin{k}(j);
            end
        end
    else
        vstride = eml_matrix_vstride(false(size(y)),dim);
        npages = eml_matrix_npages(false(size(y)),dim);
        iy = ZERO;
        npagesm1 = eml_index_minus(npages,ONE);
        for i = ZERO:npagesm1
            istart = iy;
            for j = ONE:vstride
                istart = eml_index_plus(istart,ONE);
                iy = istart;
                for k = eml.unroll(1:nargin-1)
                    if ~is_static_empty(varargin{k})
                        partlen = cast(size(varargin{k},dim),eml_index_class);
                        pagelen = eml_index_times(vstride,partlen);
                        ix = eml_index_plus(j,eml_index_times(i,pagelen));
                        for l = ONE:partlen
                            y(iy) = varargin{k}(ix);
                            ix = eml_index_plus(ix,vstride);
                            iy = eml_index_plus(iy,vstride);
                        end
                    end
                end
            end
            iy = eml_index_minus(iy,vstride);
        end
    end
end

%--------------------------------------------------------------------------

function sz = catsize(dim,varargin)
% Compute the size SZ of the concatenation of matrices VARARGIN{:} along
% dimension DIM.  Consistency is not guaranteed and not checked here
% because SZ must be constant-folded first.
eml_allow_enum_inputs;
ne = first_ordinary_arg(varargin{:});
sz = ones(1,maxndims(dim,varargin{:}));
sz1 = size(varargin{ne});
isexc = is_exception_case(dim,varargin{:});
for j = 1:eml_numel(sz1)
    sz(j) = sz1(j);
end
for k = eml.unroll(1:nargin-1)
    if k ~= ne && (isexc || ~is_static_empty(varargin{k}))
        sz(dim) = sz(dim) + size(varargin{k},dim);
    end
end

%--------------------------------------------------------------------------

function p = is_exception_case(dim,varargin)
% Returns true if this is the exception case.
eml_allow_enum_inputs;
p = false;
if dim < 3
    return
end
for k = eml.unroll(1:nargin-1)
    if size(varargin{k},1) ~= 0 || size(varargin{k},2) ~= 0 || ...
            nonexception_util(size(varargin{k}),dim)
        return
    end
end
p = true;

function p = nonexception_util(sz,dim)
% Return TRUE if a certain condition for being an exception case is
% satisfied.  Returns FALSE otherwise.
eml_allow_enum_inputs;
for j = 3:eml_numel(sz)
    if j ~= dim && sz(j) ~= 1
        p = true;
        return
    end
end
p = false;

%--------------------------------------------------------------------------

function ne = first_ordinary_arg(varargin)
% Find the index NE of the first argument such that
% ~ISEQUAL(VARARGIN{NE},[]).  If there is no such argument, the return
% value is 1.
eml_allow_enum_inputs;
ne = 1;
for k = eml.unroll(1:nargin)
    if ~is_static_empty(varargin{k})
        ne = k;
        return
    end
end

%--------------------------------------------------------------------------

function nd = maxndims(ndmin,varargin)
% ND = max{NDMIN,ndims(VARARGIN{1}),...,ndims(VARARGIN{end})}
eml_allow_enum_inputs;
nd = ndmin;
for k = eml.unroll(1:nargin-1)
    if eml_ndims(varargin{k}) > nd
        nd = eml_ndims(varargin{k});
    end
end

%--------------------------------------------------------------------------

function p = isconsistent(dim,y,x)
eml_allow_enum_inputs;
% Check whether Y and X have the same size vectors except in
% dimension DIM.  It is assumed that ndims(y) >= ndims(x).
if is_static_empty(x)
    p = true;
    return
end
for j = 1:eml_ndims(x)
    if j ~= dim && size(y,j) ~= size(x,j)
        p = false;
        return
    end
end
for j = eml_ndims(x)+1:eml_ndims(y)
    if j ~= dim && size(y,j) ~= 1
        p = false;
        return
    end
end
p = true;

%--------------------------------------------------------------------------
% Type inference functions.
%--------------------------------------------------------------------------

function x = get_scalar_enum(varargin)
% Return the first element of the first non-empty enumeration argument.
eml_allow_enum_inputs;
for k = eml.unroll(1:nargin)
    if ~isempty(varargin{k})
        x = varargin{k}(1);
        return
    end
end
eml_lib_assert(false, 'EmbeddedMATLAB:cat:UnsupportedEmptyEnumArray', ...
    'This function does not support the creation of an empty enumeration array.');

%--------------------------------------------------------------------------

function cls = dominant_enum_class(varargin)
% Return the class of the first enumeration argument.  Returns an empty
% string '' if there are no enumeration arguments.
eml_allow_enum_inputs;
for k = eml.unroll(1:nargin)
    if eml.isenum(varargin{k})
        cls = class(varargin{k});
        return
    end
end
cls = '';

%--------------------------------------------------------------------------

function cls = dominant_integer_class(varargin)
% Return the class of the first integer argument.  Returns an empty
% string '' if there are no integer arguments.
eml_allow_enum_inputs;
for k = eml.unroll(1:nargin)
    if isinteger(varargin{k})
        cls = class(varargin{k});
        return
    end
end
cls = '';

%--------------------------------------------------------------------------

function p = all_real(varargin)
% Return true if all inputs are real, false otherwise.
for k = eml.unroll(1:nargin)
    if ~isreal(varargin{k})
        p = false;
        return
    end
end
p = true;

%--------------------------------------------------------------------------

function [any_char,any_logical,all_logical,any_enum,all_enum,any_integer,dicls] = ...
    cattype_helper(varargin)
% Return information about the inputs. Output dicls is the dominant integer
% class, if any.
eml_allow_enum_inputs;
any_char = false;
any_enum = false;
all_enum = true;
any_logical = false;
all_logical = true;
any_integer = false;
decls = dominant_enum_class(varargin{:});
dicls = dominant_integer_class(varargin{:});
intwarn = false;
for k = eml.unroll(1:nargin)
    if ischar(varargin{k})
        any_char = true;
        all_enum = false;
        all_logical = false;
    elseif eml.isenum(varargin{k})
        eml_assert(isa(varargin{k},decls), ...
            ['If any input is an enumeration, all inputs ', ...
            'must be enumerations of the same type.']);
        any_enum = true;
        all_logical = false;
    elseif islogical(varargin{k})
        any_logical = true;
        all_enum = false;
    elseif isinteger(varargin{k})
        if ~intwarn && ~isa(varargin{k},dicls)
            eml_warning('MATLAB:concatenation:integerInteraction', ...
                ['Concatenation with dominant (left-most) ,' ...
                'integer class may overflow other operands on ', ...
                'conversion to return class.']);
            intwarn = true;
        end
        any_integer = true;
        all_enum = false;
        all_logical = false;
    elseif is_static_empty(varargin{k})
        % Skip it.
    else
        all_enum = false;
        all_logical = false;
    end
end

%--------------------------------------------------------------------------

function y = cattype(varargin)
eml_allow_enum_inputs;
[any_char,any_logical,all_logical,any_enum,all_enum,any_integer,dicls] = ...
    cattype_helper(varargin{:});
if eml_const(any_char)
    eml_assert(~any_logical,'Conversion to char from logical is not possible.')
    eml_assert(~any_enum,'Conversion to char from an enumeration type is not supported.');
    y = 'a';
elseif eml_const(any_logical && all_logical)
    y = false;
elseif eml_const(any_enum)
    eml_assert(all_enum, ...
        ['Implicit conversion to an enumeration class is not ', ...
        'supported. All inputs must be enumerations of the same type.']);
    y = get_scalar_enum(varargin{:});
elseif eml_const(any_integer)
    if eml_const(all_real(varargin{:}))
        y = cast(0,dicls);
    else
        y = complex(cast(0,dicls));
    end
else
    y = eml_scalar_eg(varargin{:});
end

%--------------------------------------------------------------------------

function y = is_static_empty(m)
y = eml_is_const(size(m)) && isequal(m,[]);

%--------------------------------------------------------------------------
