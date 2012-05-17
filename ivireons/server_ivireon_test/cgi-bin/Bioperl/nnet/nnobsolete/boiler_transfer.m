% TRANSFER_BOILER Boilerplate code for transfer functions.
%
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.

% Copyright 2005-2010 The MathWorks, Inc.

if nargin < 1,nnerr.throw('Not enough arguments.'); end
if (ischar(in1))
  switch(in1)
    case 'info', out1 = INFO;
    case 'paramcheck', out1 = param_check(in2);
    % NNET 6.0
    case 'name', out1 = INFO.title;
    case 'output', out1 = INFO.outputRange;
    case 'active', out1 = INFO.activeInputRange;
    case 'fpnames', out1 = INFO.parameterNames;
    case 'fpdefaults', out1 = INFO.parameterDefaults;
    case 'fullderiv', out1 = isa(derivative(zeros(3,4),zeros(3,4),param_defaults),'cell');
    case 'dn', if (nargin < 4), in4 = []; end, out1 = derivative(in2,in3,in4);
    case 'check', out1 = param_check(in2);
    otherwise, nnerr.throw(['Unrecognized code: ''' in1 ''''])
  end
  return
end
if (nargin < 2), in2 = []; end
out1 = apply_transfer(in1,in2);
