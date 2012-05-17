function varargout = cheby2(this, varargin)
%CHEBY2   Chebyshev Type II digital filter design.
%   H = CHEBY2(D) Design a Chebyshev Type II digital filter using the
%   specifications in the object D.
%
%   H = CHEBY2(D, MATCH) Design a filter and match one band exactly.  MATCH
%   can be either 'passband' or 'stopband' (default).  This flag is only
%   used when designing minimum order Chebyshev filters.

%   Author(s): J. Schickler
%   Copyright 1999-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/04/21 16:30:05 $

try
    [varargout{1:nargout}] = privdesigngateway(this, 'cheby2', varargin{:});
catch e
    error(e.identifier,cleanerrormsg(e.message));
end

% [EOF]
