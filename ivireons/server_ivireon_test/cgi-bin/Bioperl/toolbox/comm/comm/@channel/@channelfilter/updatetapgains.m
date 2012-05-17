function updatetapgains(h, z);
% Compute channel filter tap gains and update associated properties.
%
% Inputs: 
%    h - Channel filter object
%    z - Evolution of path gains (optional)

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:19:29 $

if nargin==1
    % if g not specified, use current tap gains of channel filter.
    g = h.TapGains.Values.';
else
    g = h.AlphaMatrix.' * z;
    h.TapGains.Values = g(:, end).';
end

TGH = h.TapGainsHistory;
if TGH.Enable
    update(TGH, g.');
end

SIRH = h.SmoothIRHistory;
if SIRH.Enable
    gS = h.AlphaMatrixSmooth.' * z;
    update(SIRH, gS.');
end
