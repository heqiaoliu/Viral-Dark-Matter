function varargout = impz(Hb, N, varargin)
%IMPZ Impulse response of digital filter

%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.4 $  $Date: 2009/08/11 15:48:05 $

error(nargchk(1,3,nargin,'struct'))

if nargout,
    if nargin < 2, N = max(impzlength(Hb)); end
   
    [y,t]     = base_resp(Hb, 'computeimpz', N, varargin{:});
    varargout = {y,t};
else
    if nargin > 1, varargin = {N, varargin{:}}; end

    [Hb, opts] = timezparse(Hb, varargin{:});    
    fvtool(Hb, 'impulse',opts);
end

% [EOF]
