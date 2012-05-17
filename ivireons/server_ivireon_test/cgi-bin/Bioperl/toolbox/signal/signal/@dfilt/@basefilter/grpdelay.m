function varargout = grpdelay(Hb,varargin)
%GRPDELAY Group delay of a discrete-time filter.

%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2009/08/11 15:48:04 $

if nargout,
    [Gd, w] = base_resp(Hb, 'computegrpdelay', varargin{:});
    varargout = {Gd, w};
else,
    [Hb, opts] = freqzparse(Hb, varargin{:});
    fvtool(Hb, 'grpdelay', opts);    
end

% [EOF]
