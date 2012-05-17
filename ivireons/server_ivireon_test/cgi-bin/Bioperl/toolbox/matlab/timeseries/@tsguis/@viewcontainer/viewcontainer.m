function this = viewcontainer(label,childclass)

% Copyright 2004-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2008/08/20 23:00:34 $

import java.awt.dnd.*
import com.mathworks.toolbox.timeseries.*;

%% Constructor for viewcontainer node
this = tsguis.viewcontainer;

%{
%% Set the correct help file
helpfiles = ...
    {'Time Plots','plots_time';...
     'Spectral Plots','plots_spectral';...
     'XY Plots','plots_xy';...
     'Correlations','plots_correlation';...
     'Histograms','plots_histogram'};
ind = find(strcmp(label,helpfiles(:,1)));
this.HelpFile = helpfiles{ind(1),2};
%}
this.HelpFile = 'plots_manage';

%{
lang = get(0,'language');
if strncmpi(lang,'ja',2)
    this.HelpFile = fullfile(docroot, 'techdoc', 'time_series_csh', ...
                             'ja',helpfiles{ind(1),2});
else
    this.HelpFile = fullfile(docroot, 'techdoc', 'time_series_csh', ...
                             helpfiles{ind(1),2});
end
%}

%% Icon and label
set(this,'Label',label,'ChildClass',childclass)
set(this,'AllowsChildren',true,'Editable',true,'Icon',...
    fullfile(matlabroot,'toolbox','matlab','timeseries','folder.gif'));

%% Build tree node. Note in the CETM there is no need to do this because the
%% Explorer calls it when building the tree
this.getTreeNodeInterface;