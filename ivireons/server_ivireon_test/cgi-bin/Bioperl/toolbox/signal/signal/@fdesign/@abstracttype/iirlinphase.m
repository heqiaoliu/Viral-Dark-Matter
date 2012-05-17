function varargout = iirlinphase(this,varargin)
%IIRLINPHASE   

%   Author(s): R. Losada
%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/04/21 16:30:12 $

try
    [varargout{1:nargout}] = privdesigngateway(this, 'iirlinphase', varargin{:});
catch e
    error(e.identifier,cleanerrormsg(e.message));
end



% [EOF]
