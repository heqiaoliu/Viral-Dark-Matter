function varargout = phasez(Hb,varargin)
%PHASEZ Phase response of a discrete-time filter.

%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.3 $  $Date: 2009/08/11 15:48:06 $

if nargout,
    
    % Strings are faster than Function Handles
    [Ph, w] = base_resp(Hb, 'computephasez', varargin{:});
    varargout = {Ph, w};
else,    
    [Hb, opts] = freqzparse(Hb, varargin{:});
    fvtool(Hb, 'phase', opts);
end

% [EOF]
