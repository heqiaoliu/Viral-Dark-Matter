function varargout = butter(this, varargin)
%BUTTER   Butterworth IIR digital filter design.
%   H = BUTTER(D) Design a Butterworth IIR digital filter using the
%   specifications in the object D.
%
%   H = BUTTER(D, MATCH) Design a filter and match one band exactly.  MATCH
%   can be either 'passband' or 'stopband' (default).  This flag is only
%   used when designing minimum order Butterworth filters.

%   Author(s): J. Schickler
%   Copyright 1999-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/04/21 16:30:03 $

try
    [varargout{1:nargout}] = privdesigngateway(this, 'butter', varargin{:});
catch e
    error(e.identifier,cleanerrormsg(e.message));
end

% [EOF]
