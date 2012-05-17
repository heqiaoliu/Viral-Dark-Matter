function varargout = window(this, varargin)
%WINDOW   FIR filter design using the window method.
%   WINDOW(D) FIR filter design using the window method.

%   Author(s): J. Schickler
%   Copyright 1999-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/04/21 16:30:20 $

try
    [varargout{1:nargout}] = privdesigngateway(this, 'window', varargin{:});
catch e
    error(e.identifier,cleanerrormsg(e.message));
end

% [EOF]
