function varargout = multistage(this, varargin)
%MULTISTAGE   Design a multistage FIR filter using the equiripple method.
%   MULTISTAGE(D) designs a multistage equiripple filter using the specifications
%   in the object D.

%   Author(s): R. Losada
%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/04/21 16:30:19 $

try
    [varargout{1:nargout}] = privdesigngateway(this, 'multistage', varargin{:});
catch e
    error(e.identifier,cleanerrormsg(e.message));
end

% [EOF]
