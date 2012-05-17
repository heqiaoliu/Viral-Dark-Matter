function varargout = ansis142(this,varargin)
%ANSIS142   

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/10/16 06:41:15 $

try
    [varargout{1:nargout}] = privdesigngateway(this, 'ansis142', varargin{:});
catch e
    error(e.identifier,cleanerrormsg(e.message));
end

% [EOF]
