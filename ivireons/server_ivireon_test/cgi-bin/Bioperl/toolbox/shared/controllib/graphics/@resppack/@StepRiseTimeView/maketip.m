function str = maketip(this,tip,info)
%MAKETIP  Build data tips for SettleTimeView Characteristics.
%
%   INFO is a structure built dynamically by the data tip interface
%   and passed to MAKETIP to facilitate construction of the tip text.

%   Author(s): John Glass
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:19:38 $
r = info.Carrier;
AxGrid = info.View.AxesGrid;

str = {sprintf('Response: %s',r.Name)};
[iotxt,ShowFlag] = rcinfo(r,info.Row,info.Col); 
if any(AxGrid.Size(1:2)>1) || ShowFlag 
    % Show if MIMO or non trivial 
    str{end+1,1} = iotxt; 
end

Time = info.View.Points(info.Row,info.Col).XData;
TLow = info.Data.TLow(info.Row,info.Col);
THigh = info.Data.THigh(info.Row,info.Col);
RT = Time - TLow;  % rise time estimate
if isinf(TLow)
   % Unstable
   str{end+1,1} = sprintf('Rise Time: N/A');
elseif isnan(TLow)
   % Has not reached low threshold yet
   str{end+1,1} = sprintf('Rise Time > %0.3g (%s)', Time, AxGrid.XUnits);
elseif isnan(THigh)
   % Has not reached high threshold yet
   str{end+1,1} = sprintf('Rise Time > %0.3g (%s)', RT, AxGrid.XUnits);
else
   % Fully risen
   str{end+1,1} = sprintf('Rise Time (%s): %0.3g',AxGrid.XUnits, RT);
end
