function varargout = freqz(Hb,varargin)
%FREQZ  Discrete-time filter frequency response.
%
%   See also DFILT, SIGNAL/FREQZ.

%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.4 $  $Date: 2009/08/11 15:48:03 $

if nargout,
    [h,w] = base_resp(Hb, 'computefreqz', varargin{:});
    varargout = {h, w};
else,
    [Hb, opts] = freqzparse(Hb, varargin{:});
    fvtool(Hb, 'freq', opts);
end

% [EOF]
