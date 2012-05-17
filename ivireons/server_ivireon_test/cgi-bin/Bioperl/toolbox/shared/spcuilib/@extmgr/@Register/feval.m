function varargout = feval(this, methodName, varargin)
%FEVAL    Evaluate a static method on the registered extension.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/02/02 13:10:00 $

% Build the static method function call from the extension's class name and
% the specified method name.
fcn = [this.Class '.' methodName];

if nargout
    [varargout{1:nargout}] = feval(fcn, varargin{:});
else
    feval(fcn, varargin{:});
end

% [EOF]
