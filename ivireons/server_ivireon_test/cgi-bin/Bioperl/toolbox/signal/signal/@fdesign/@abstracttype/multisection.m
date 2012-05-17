function varargout = multisection(this, varargin)
%MULTISECTION   

%   Author(s): J. Schickler
%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/04/21 16:30:18 $

try
    [varargout{1:nargout}] = privdesigngateway(this, 'multisection', varargin{:});
catch e
    error(e.identifier,cleanerrormsg(e.message));
end

% [EOF]
