function y = reshape(x,varargin)
%Embedded MATLAB Library Function

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
eml_must_inline;
eml_assert(nargin > 1, 'Not enough input arguments.');
nx = cast(eml_numel(x),eml_index_class);
% For technical reasons it turns out to be necessary to have the same size
% computation both inline (for variably sized inputs) and as a subfunction
% (for statically sized inputs).
if eml_is_const(size(x))
    sz = reshape_varargin_to_size(x,varargin{:});
else
    % Convert varargin to size vector, taking account of a possible
    % "unknown" dimension size.
    if nargin == 2
        % Varargin input is a one size vector.  No unknown dimensions.
        eml_assert_valid_size_arg(varargin{1});
        eml_lib_assert(eml_numel(varargin{1}) > 1, ...
            'MATLAB:getReshapeDims:sizeVector', ...
            'Size vector must have at least two elements.');
        sz = cast(varargin{1},eml_index_class);
    else
        % Varargin input is a set of valid size scalars with at most on
        % unknown dimension size.
        eml_lib_assert(varargin_nempty(varargin{:}) <= 1, ...
            'MATLAB:getReshapeDims:unknownDim', ...
            'Size can only have one unknown dimension.');
        sz = zeros(1,nargin-1,eml_index_class);
        emptyidx = zeros(eml_index_class);
        for k = eml.unroll(ones(eml_index_class):nargin-1)
            if eml_is_const(isempty(varargin{k})) && isempty(varargin{k})
                sz(k) = 1;
                emptyidx = k;
            else
                eml_assert(isscalar(varargin{k}), ...
                    'Size arguments must be integer scalars.');
                eml_assert_valid_size_arg(varargin{k});
                sz(k) = varargin{k};
            end
        end
        prodsz = eml_index_prod(sz);
        if emptyidx ~= 0
            if prodsz > 0
                calclen = eml_index_rdivide(nx,prodsz);
                assert(calclen <= nx); %<HINT>
                sz(emptyidx) = calclen;
            else
                sz(emptyidx) = 0;
            end
        end
    end
end
if ~eml_is_const(sz)
    maxdimlen = max(nx,max(size(x)));
    for k = eml.unroll(ones(eml_index_class):eml_numel(sz))
        assert(sz(k) <= maxdimlen, ...
            'EmbeddedMATLAB:reshape:emptyReshapeLimit', ...
            ['To RESHAPE the number of elements must not change, and ', ...
            'if the input is empty, the maximum dimension length ', ...
            'cannot be increased unless the output size is fixed.']);
    end
end
y = eml.nullcopy(eml_expand(eml_scalar_eg(x),sz));
eml_lib_assert(eml_numel(y) == nx, ...
    'MATLAB:getReshapeDims:notSameNumel', ...
    'To RESHAPE the number of elements must not change.');
for k = ones(eml_index_class):nx
    y(k) = x(k);
end

%--------------------------------------------------------------------------

function n = varargin_nempty(varargin)
% Count the number of unknown dimensions.
eml_allow_enum_inputs;
n = zeros(eml_index_class);
for k = eml.unroll(ones(eml_index_class):nargin)
    if isempty(varargin{k})
        n = eml_index_plus(n,1);
    end
end

%--------------------------------------------------------------------------

function sz = reshape_varargin_to_size(x,varargin)
% Convert varargin to size vector, taking account of a possible
% "unknown" dimension size.
eml_allow_enum_inputs;
nx = cast(eml_numel(x),eml_index_class);
if nargin == 2
    % Varargin input is a one size vector.  No unknown dimensions.
    eml_assert_valid_size_arg(varargin{1});
    eml_lib_assert(eml_numel(varargin{1}) > 1, ...
        'MATLAB:getReshapeDims:sizeVector', ...
        'Size vector must have at least two elements.');
    sz = cast(varargin{1},eml_index_class);
else
    % Varargin input is a set of valid size scalars with at most on
    % unknown dimension size.
    eml_lib_assert(varargin_nempty(varargin{:}) <= 1, ...
        'MATLAB:getReshapeDims:unknownDim', ...
        'Size can only have one unknown dimension.');
    sz = zeros(1,nargin-1,eml_index_class);
    emptyidx = zeros(eml_index_class);
    for k = eml.unroll(ones(eml_index_class):nargin-1)
        if eml_is_const(isempty(varargin{k})) && isempty(varargin{k})
            sz(k) = 1;
            emptyidx = k;
        else
            eml_assert(isscalar(varargin{k}), ...
                'Size arguments must be integer scalars.');
            eml_assert_valid_size_arg(varargin{k});
            sz(k) = varargin{k};
        end
    end
    prodsz = eml_index_prod(sz);
    if emptyidx ~= 0
        if prodsz > 0
            calclen = eml_index_rdivide(nx,prodsz);
            assert(calclen <= nx); %<HINT>
            sz(emptyidx) = calclen;
        else
            sz(emptyidx) = 0;
        end
    end
end

%--------------------------------------------------------------------------
