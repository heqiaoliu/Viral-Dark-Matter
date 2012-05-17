function str = maketip(this,tip,info)
%MAKETIP  Build data tips for SettleTimeView Characteristics.
%
%   INFO is a structure built dynamically by the data tip interface
%   and passed to MAKETIP to facilitate construction of the tip text.

%   Author(s):  
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/12/15 20:57:24 $
r = info.Carrier;
AxGrid = info.View.AxesGrid;
str = {sprintf('Mean: %s',r.Name)};
[iotxt,ShowFlag] = rcinfo(r,info.Row,info.Col); 
if any(AxGrid.Size(1:2)>1) | ShowFlag 
    % Show if MIMO or non trivial 
    str{end+1,1} = sprintf('Column %d',info.Row); 
end
str{end+1,1} = sprintf('%0.2g',info.Data.MeanValue(info.Row));
TipText = str;