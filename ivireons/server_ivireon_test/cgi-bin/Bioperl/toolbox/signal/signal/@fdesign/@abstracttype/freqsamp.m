function varargout = freqsamp(this,varargin)
%FREQSAMP   

%   Author(s): V. Pellissier
%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/04/21 16:30:10 $

try
    [varargout{1:nargout}] = privdesigngateway(this, 'freqsamp', varargin{:});
catch e
    error(e.identifier,cleanerrormsg(e.message));
end


% [EOF]
