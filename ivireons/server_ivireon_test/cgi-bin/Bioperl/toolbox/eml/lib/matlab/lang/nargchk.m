function msg = nargchk(low,high,n,opt)
%Embedded MATLAB Library Function

%   Limitations:  Struct output does not include stack information.

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin >= 3, 'Not enough input arguments.');
eml_assert(eml_is_const(low) && eml_is_const(high) && eml_is_const(n) && ...
    (nargin < 4 || eml_is_const(opt)), 'Inputs must be constants');
eml_assert(nargin < 4 || (strcmp(opt,'string') || strcmp(opt,'struct')), ...
    'The fourth input must be either ''struct'' or ''string''.');
eml_assert(isscalar(low) && isscalar(high) && isscalar(n), ...
    'First three inputs must be scalars.');
eml_assert(isa(low,'numeric') && isa(high,'numeric') && isa(n,'numeric'), ...
    'First three inputs must be numeric.');
eml_assert(low == floor(low) && high == floor(high) && n == floor(n), ...
    'Scalar integer value required, but value is not integral.');
if n < low
    if nargin < 4 || strcmp(opt,'string')
        msg = 'Not enough input arguments.';
    else
        msg.message = 'Not enough input arguments.';
        msg.identifier = 'MATLAB:nargchk:notEnoughInputs';
    end
elseif n > high
    if nargin < 4 || strcmp(opt,'string')
        msg = 'Too many input arguments.';
    else
        msg.message = 'Too many input arguments.';
        msg.identifier = 'MATLAB:nargchk:tooManyInputs';
    end
else
    msg = [];
end