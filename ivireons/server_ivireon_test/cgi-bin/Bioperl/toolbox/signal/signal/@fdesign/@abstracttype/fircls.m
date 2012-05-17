function varargout = fircls(this, varargin)
%FIRCLS   FIR filter design using the constrained least squares method
%   FIRCLS(D) FIR filter design using the constrained least squares method.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:35:50 $

try
    [varargout{1:nargout}] = privdesigngateway(this, 'fircls', varargin{:});
catch ME
    throwAsCaller(ME);
end

% [EOF]

