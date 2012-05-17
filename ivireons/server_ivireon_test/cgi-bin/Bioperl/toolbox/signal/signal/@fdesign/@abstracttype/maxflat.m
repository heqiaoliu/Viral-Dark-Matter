function varargout = maxflat(this, varargin)
%MAXFLAT   FIR filter design using the maxflat method
%   MAXFLAT(D) FIR filter design using the maxflat method.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/05/31 23:26:33 $

try
    [varargout{1:nargout}] = privdesigngateway(this, 'maxflat', varargin{:});
catch ME
    throwAsCaller(ME);
end

% [EOF]
