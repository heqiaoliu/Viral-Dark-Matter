function InterpMethod = utSelectInterp(u)
% Infers appropriate interpolation rule from data.

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:24 $
dthresh = 0.75;    % threshold for discontinuity detection

% Estimate if continuous-time signal is smooth or jumpy
% After normalizing amplitude, declare the input smooth if the max.
% variation per sample does not exceeds DTHRESH% of amplitude range
range = max(u)-min(u);
du = abs(diff(u,[],1));
if ~isempty(du) && all(max(du)<=dthresh*range),
   InterpMethod = 'foh';
else
   InterpMethod = 'zoh';
end
