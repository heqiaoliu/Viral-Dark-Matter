function reset(h, z)
%RESET  Reset channel filter object.
%   RESET(H) resets the state of a channel filter object.
%   RESET(H, Z) sets the initial tap gain values based on the path gain
%   vector Z.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:19:26 $

% Number of channel filter taps
nTaps = length(h.TapIndices);

% If path gain vector specified, set channel filter tap gains.
if nargin==2
    h.TapGains.Values = (h.AlphaMatrix.' * z).';
end

% Reset channel filter state.
h.State = complex(zeros(1, nTaps));

% Reset tap gain history.
reset(h.TapGainsHistory);
reset(h.SmoothIRHistory);
