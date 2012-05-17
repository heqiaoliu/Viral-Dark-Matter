function eml_assert_valid_size_arg(varargin)
%Embedded MATLAB Private Function

%   Checks arg properties:
%
%   1. numeric
%   2. scalar or row vector
%   3. real
%   4. integer valued
%
%   and asserts if any are not satisfied.

%   Copyright 2005-2009 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
if nargin == 0
    return
end
eml_prefer_const(varargin);
VARSIZE = isVariableSizing(varargin{:});
if ~VARSIZE
    eml_transient;
end
for k = eml.unroll(1:nargin)
    eml_assert(~eml.isenum(varargin{k}), ...
        'Enumeration types are not supported for size arguments.');
    eml_assert(eml_is_const(varargin{k}) || VARSIZE, ...
        'Size argument must be constant.');
    eml_assert(isa(varargin{k},'numeric'), 'Size argument must be numeric.');
    eml_assert(isreal(varargin{k}), 'Size argument cannot be complex.');
end
if nargin == 1 && isvector(varargin{1})
    if VARSIZE
        eml_lib_assert(size(varargin{1},1) == 1 && isintegral(varargin{1}), ...
            'MATLAB:NonIntegerInput', ...
            'Size vector must be a row vector with finite integer elements.');
    else
        eml_assert(size(varargin{1},1) == 1 && isintegral(varargin{1}), ...
            'Size vector must be a row vector with finite integer elements.');
    end
else
    for k = eml.unroll(1:nargin)
        eml_assert(isscalar(varargin{k}), 'Size argument must be scalar.');
        if VARSIZE
            eml_lib_assert(isintegral(varargin{k}), ...
                'MATLAB:NonIntegerInput', ...
                'Size argument must be integer.');
        else
            eml_assert(isintegral(varargin{k}), ...
                'Size argument must be integer.');
        end
    end
end
if VARSIZE
    eml_lib_assert(numel_for_size(varargin{:}) <= intmax(eml_index_class), ...
        'MATLAB:pmaxsize', ...
        'Maximum variable size allowed by the program is exceeded.');
else
    eml_assert(numel_for_size(varargin{:}) <= intmax(eml_index_class), ...
        'Maximum variable size allowed by the program is exceeded.');
end

%--------------------------------------------------------------------------

function p = isintegral(arg)
if ~isinteger(arg)
    for k = 1:eml_numel(arg)
        if arg(k) ~= eml_floor(arg(k)) || isinf(arg(k))
            p = false;
            return
        end
    end
end
p = true;

%--------------------------------------------------------------------------

function n = numel_for_size(varargin)
% n = prod(max(0,sz)), where sz is the size vector corresponding to the
% input, either a single vector or a set of scalar inputs.
n = 1;
if nargin == 1
    for k = 1:eml_numel(varargin{1})
        if varargin{1}(k) <= 0
            n = 0;
        else
            n = n * double(varargin{1}(k));
        end
    end
else
    for k = eml.unroll(1:nargin)
        if varargin{k} <= 0
            n = 0;
        else
            n = n * double(varargin{k});
        end
    end
end

%--------------------------------------------------------------------------

function vs = isVariableSizing(varargin)
eml_allow_enum_inputs;
eml_prefer_const(varargin);
if eml_option('VariableSizing')
    vs = false;
    for k = 1:nargin
        vs = vs || ~eml_is_const(varargin{k});
    end
else
    vs = false;
end

%--------------------------------------------------------------------------
