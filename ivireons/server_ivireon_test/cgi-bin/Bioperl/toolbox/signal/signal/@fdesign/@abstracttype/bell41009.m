function varargout = bell41009(this,varargin)
%BELL41009   

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/10/16 06:41:16 $

try
    [varargout{1:nargout}] = privdesigngateway(this, 'bell41009', varargin{:});
catch e
    error(e.identifier,cleanerrormsg(e.message));
end

% [EOF]
