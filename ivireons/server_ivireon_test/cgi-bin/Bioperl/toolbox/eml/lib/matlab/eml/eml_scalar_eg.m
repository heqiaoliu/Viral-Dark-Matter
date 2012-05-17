function x = eml_scalar_eg(varargin)
%Embedded MATLAB Private Function
%
%   Returns a scalar "example" of the additive combined type of the input
%   arguments.  Specifically, if a = varargin{1}, b = varargin{2}, and so
%   forth, the class of the return value x is
%
%   class(a),                                                 nargin == 1
%   class(cast(0,class(a))+cast(0,class(b))),                 nargin == 2
%   class(cast(0,class(a))+cast(0,class(b))+cast(0,class(c)), nargin == 3
%   etc.
%
%   The result x is complex if any of the arguments are complex.
%
%   When all inputs are float, integer, logical, or char, the output x
%   is guaranteed to satisfy x == 0.
%
%   Opaque, struct, and enumeration inputs are supported, but the first
%   input argument must be nonempty, and all inputs after the first
%   argument are ignored.
%
%   Some consequential behavior to note:
%
%       eml_scalar_eg(false) is logical.
%       eml_scalar_eg(false,false) is double.
%       eml_scalar_eg('a') is char.
%       eml_scalar_eg('a','a') is double.

%   Copyright 2005-2009 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
eml_assert(nargin > 0, 'Not enough input arguments.');
if any_enums(varargin{:})
    eml_assert(all_enums(varargin{:}), ...
        'If any argument is an enumeration, all arguments must be enumerations of the same type.');
    x = eml_get_enum_default(varargin{1});
elseif isstruct(varargin{1}) || isa(varargin{1},'eml.opaque')
    eml_lib_assert(~isempty(varargin{1}), 'EmbeddedMATLAB:UnsupportedEmptyArrayType', ...
        'Empty arrays of opaque and struct types are not supported.');
    x = varargin{1}(1);
else
    zero = zerosum(varargin{:});
    if allreal(varargin{:})
        x = zero;
    else
        x = complex(zero);
    end
end

%--------------------------------------------------------------------------

function p = any_enums(varargin)
% Return true if any arguments are enumerations.
eml_allow_enum_inputs;
for k = eml.unroll(1:nargin)
    if eml.isenum(varargin{k})
        p = true;
        return
    end
end
p = false;

%--------------------------------------------------------------------------

function p = all_enums(varargin)
% Return true if all arguments are enumerations.
eml_allow_enum_inputs;
p = eml.isenum(varargin{1});
if p
    for k = eml.unroll(2:nargin)
        if ~isa(varargin{k},class(varargin{1}))
            p = false;
            return
        end
    end
end

%--------------------------------------------------------------------------

function t = zerosum(varargin)
% Return zero of the right class to contain the sum of varargin{:}.
if nargin == 1
    t = cast(0,class(varargin{1}));
    return
end
t = cast(0,class(varargin{1})) + zerosum(varargin{2:end});

%--------------------------------------------------------------------------

function p = allreal(varargin)
% Return true if all arguments are real, false, otherwise.
p = isreal(varargin{1});
if nargin > 1 && p
    p = allreal(varargin{2:end});
end

%--------------------------------------------------------------------------
