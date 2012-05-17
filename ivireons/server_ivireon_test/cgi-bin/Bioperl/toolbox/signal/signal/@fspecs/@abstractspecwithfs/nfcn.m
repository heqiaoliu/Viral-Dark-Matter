function varargout = nfcn(this, fcn, varargin)
%NFCN   Evaluate a function with normalized frequency set to true.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/04/04 17:00:13 $

normalized = get(this, 'NormalizedFrequency');
normalizefreq(this, true);

[varargout{1:nargout}] = feval(fcn, this, varargin{:});

normalizefreq(this, normalized);

% [EOF]
