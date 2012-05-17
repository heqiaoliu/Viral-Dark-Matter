function construct(h, varargin);
%CONSTRUCT  Construct channel filter object.
%
%   Inputs:
%     Ts     - Input signal sample period (s).
%     tau    - Path delay vector (s).
%     tapidx - Tap gain indices (integers).
%   If tapidx is specified, auto-computation will be turned off.

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/14 15:58:06 $

error(nargchk(1, 4, nargin,'struct'));

numParam = length(varargin);

h.initprivatedata;

% Set properties if specified.
p = {'InputSamplePeriod'
     'PathDelays'
     'TapIndices'};
set(h, p(1:numParam), varargin);

% Autocompute tap indices if not specified.
h.AutoComputeTapIndices = ~(numParam>=3);

h.TapGains = channel.sigresponse;
h.TapGainsHistory = channel.slidebuffer;
h.SmoothIRHistory = channel.slidebuffer;
    
initialize(h);

h.Constructed = true;
