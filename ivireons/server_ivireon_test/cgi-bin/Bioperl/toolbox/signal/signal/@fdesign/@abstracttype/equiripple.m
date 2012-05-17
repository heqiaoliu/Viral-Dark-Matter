function varargout = equiripple(this, varargin)
%EQUIRIPPLE   Design an equiripple filter.
%   EQUIRIPPLE(D) designs an equiripple filter using the specifications in
%   the object D.

%   Author(s): J. Schickler
%   Copyright 1999-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/04/21 16:30:08 $

try
    [varargout{1:nargout}] = privdesigngateway(this, 'equiripple', varargin{:});
catch e
    error(e.identifier,cleanerrormsg(e.message));
end

% [EOF]
