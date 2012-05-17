function str = maketip(this,tip,info)
%MAKETIP  Build data tips for @nyquistview curves.
%
%   INFO is a structure built dynamically by the data tip interface
%   and passed to MAKETIP to facilitate construction of the tip text.

%   Author(s): John Glass
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:22:41 $

r = info.Carrier;
h = r.Parent;
AxGrid = h.AxesGrid;

% Create tip text
str{1,1} = sprintf('Response: %s',r.Name);
[iotxt,ShowFlag] = rcinfo(r,info.Row,info.Col);
if any(AxGrid.Size(1:2)>1) || ShowFlag
   % Show if MIMO or non trivial
   str{end+1,1} = iotxt;
end

FreqUnits = h.FrequencyUnits;
F = unitconv(LocalInterpFreq(info,tip),info.Data.FreqUnits,FreqUnits);
str = [str ; ...
      {sprintf('Real: %0.3g',tip.Position(1));...
      sprintf('Imag: %0.3g',tip.Position(2));...
      sprintf('Frequency (%s): %0.3g',FreqUnits,info.Sign*F)}];

%%%%%%%%%%%%%%%%%%%%% Local Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

function F = LocalInterpFreq(info,tip)
% Interpolates frequency value in parametric plots
Freqs = info.Data.Frequency;
dch = tip.DataCursorHandle; 
tau = dch.InterpolationFactor; 
idx = dch.DataIndex;

if isequal(tip.Interpolate,'off') || isequal(tau,0)
    F = Freqs(idx);
elseif tau > 0
    F = Freqs(idx) + tau * (Freqs(idx+1)-Freqs(idx));
else
    % case tau < 0
    F = Freqs(idx) + tau * (Freqs(idx)-Freqs(idx-1));        
end