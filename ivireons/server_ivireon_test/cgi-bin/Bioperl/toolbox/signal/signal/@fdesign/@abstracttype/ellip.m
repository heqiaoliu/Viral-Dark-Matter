function varargout = ellip(this, varargin)
%ELLIP   Elliptic or Cauer digital filter design.
%   H = ELLIP(D) Design an Elliptic digital filter using the specifications
%   in the object D.
%
%   H = ELLIP(D, MATCH) Design a filter and match one band exactly.  MATCH
%   can be either 'passband' 'stopband' or 'both' (default).  This flag is
%   only used when designing minimum order Elliptic filters.

%   Author(s): J. Schickler
%   Copyright 1999-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/04/21 16:30:07 $

try
    [varargout{1:nargout}] = privdesigngateway(this, 'ellip', varargin{:});
catch e
    error(e.identifier,cleanerrormsg(e.message));
end

% [EOF]
