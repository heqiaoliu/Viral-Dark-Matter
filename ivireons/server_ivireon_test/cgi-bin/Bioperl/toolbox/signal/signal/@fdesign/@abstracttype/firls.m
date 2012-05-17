function varargout = firls(this, varargin)
%FIRLS   Design a least-squares filter.   

%   Author(s): J. Schickler
%   Copyright 1999-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/04/21 16:30:09 $

try
    [varargout{1:nargout}] = privdesigngateway(this, 'firls', varargin{:});
catch e
    error(e.identifier,cleanerrormsg(e.message));
end

% [EOF]
