function y = eml_scalar_eg(varargin)
%Embedded MATLAB Private Function

%    Returns a scalar with the numerictype and fimath of the first input
%    argument that is a fixed point type.  The value will be complex if any
%    of the input arguments is complex, real otherwise.  The value of y is 
%    eml_cast(false,numerictype(x),fimath(x)), where x is the first fixed
%    point input argument.

%   Copyright 2005-2008 The MathWorks, Inc.
%#eml

eml_must_inline;
eml_assert(nargin>=1, 'Not enough input arguments.')
x = findfirstfi(varargin{:});
isr = allreal(varargin{:});
if isr
    y0 = eml_cast(eml_const(false), numerictype(x), fimath(x));
else
    y0 = complex(eml_cast(eml_const(false), numerictype(x), fimath(x)));
end
if eml_const(eml_fimathislocal(x))
    y = y0; 
else
    y = eml_fimathislocal(y0,false);
end

%--------------------------------------------------------------------------

function t = findfirstfi(varargin)
% Returns the first fixedpoint input.
if nargin == 1 || isfi(varargin{1})
    t = varargin{1};
else
    t = findfirstfi(varargin{2:end});
end

%--------------------------------------------------------------------------

function p = allreal(varargin)
% Return true if all arguments are real, false, otherwise.
p = isreal(varargin{1});
if nargin > 1 && p
    p = allreal(varargin{2:end});
end

%--------------------------------------------------------------------------
