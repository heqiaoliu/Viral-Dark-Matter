function varargout = eval(tryVal,catchVal)
%EVAL for Java strings.
%
%   See also EVAL.

%   Copyright 1984-2007 The MathWorks, Inc. 
%   $Revision: 1.4.4.3 $ $Date: 2007/11/13 00:10:08 $

tryVal = fromOpaque(tryVal);

% This code mimics eval, but is implemented in M-code, and hence needs to use
% evalin('caller', ...) to get the same effect.

if nargin==2
    % The catch-argument to evalin is evaluated in the current workspace, hence the need for the
    % embedded evalin in the third argument below.
    [varargout{1:nargout}] = evalin('caller', tryVal, 'evalin(''caller'', fromOpaque(catchVal));');
else
    [varargout{1:nargout}] = evalin('caller', tryVal);
end

function z = fromOpaque(x)
z=x;

if isjava(z)
  z = char(z);
end

if isa(z,'opaque')
 error('MATLAB:eval:CannotConvertClass', ...
       'Conversion to char from %s is not possible.', class(x));
end
