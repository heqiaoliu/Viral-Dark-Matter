function refreshPanel(this)
% Refreshes View Table Panel

%   Author(s): C. Buhr
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2008/05/31 23:16:01 $

this.initializeData;

% Get the handle to the table panel handle
TablePanel = this.Handles.TablePanel;

% Get the existing available loops and data
AvailableLoops = cell(TablePanel.getAvailableLoops);
AvailableLoopJava = matlab2java1d(slcontrol.Utilities,AvailableLoops,'java.lang.String');
DesignViewsTableDataJava = matlab2java(slcontrol.Utilities,this.DesignViewsTableData);

% Update the table
javaMethodEDT('setViewTableData',TablePanel,DesignViewsTableDataJava,AvailableLoopJava);
