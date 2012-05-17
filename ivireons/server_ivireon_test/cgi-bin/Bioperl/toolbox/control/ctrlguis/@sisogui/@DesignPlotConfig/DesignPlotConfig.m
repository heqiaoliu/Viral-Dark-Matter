function this = DesignPlotConfig(SISODB)

%   Author(s): C. Buhr
%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.4 $  $Date: 2007/02/06 19:50:29 $

this = sisogui.DesignPlotConfig;

this.SISODB = SISODB;
%this.SISODB.DesignPlotConfigDialog = this;
this.initializeData;
this.buildPanel;

%% Initialize the table changed callback
h = handle(this.Handles.TableModel, 'callbackproperties' ); 
hlistener = handle.listener(h,'TableChanged',{@LocalUpdateSISOTool this});

this.Listeners.TableChanged = hlistener;
%% Set the summary table data
this.setTunedLoopTableData

this.Listeners.ConfigChange = handle.listener(SISODB.LoopData,'ConfigChanged',{@LocalRefresh this});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateSISOTool(es, ed, this)
% set editor configuration
this.setCurrentConfiguration;


function LocalRefresh(es,ed,this)
% reset table info when configuration changes
this.Listeners.TableChanged.Enabled = 'off';
this.setTunedLoopTableData;
this.refreshPanel;
drawnow;
this.Listeners.TableChanged.Enabled = 'on';