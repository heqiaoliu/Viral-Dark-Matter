function str = maketip(this,tip,info)
%MAKETIP  Build data tips for eventCharView Characteristics.
%
%   INFO is a structure built dynamically by the data tip interface
%   and passed to MAKETIP to facilitate construction of the tip text.

%   Author(s):  
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/27 22:57:39 $

r = info.Carrier;
AxGrid = info.View.AxesGrid;

str = {sprintf('Time series:%s',r.Name)};
[iotxt,ShowFlag] = rcinfo(r,info.Row,info.Col); 
if any(AxGrid.Size(1:2)>1) | ShowFlag 
    % Show if MIMO or non trivial 
    str{end+1,1} = sprintf('Column %d',info.Row); 
end
%% Workaround to avoid creating a separate view class for median
if isa(info.Data,'tsguis.histMedianData')
    str{end+1,1} = sprintf('Median: %0.2g',info.Data.MeanValue(info.Row,info.Col)); 
else    
    str{end+1,1} = sprintf('Mean: %0.2g',info.Data.MeanValue(info.Row,info.Col));
end
TipText = str;