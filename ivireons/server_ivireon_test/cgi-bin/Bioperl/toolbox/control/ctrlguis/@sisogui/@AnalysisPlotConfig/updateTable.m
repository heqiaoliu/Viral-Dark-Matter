function updateTable(this,loopdata)
% UPDATETABLE  update the displayed table using the supplied loopdata
% object
%
 
% Author(s): A. Stothert 12-Jan-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2006/03/26 01:11:09 $

%% Set the CETM to be blocked with a GlassPane
CETMFrame = slctrlexplorer;
CETMFrame.setBlocked(false,[])

%% Update the table with the new data
RespData = cell(this.Handles.TablePanel.getPlotContentTableModel.data);
RespData = [RespData;repmat({false},1,7),{loopdata.LoopView(end).Description}];
this.RespData = RespData;

%% Disable the table listener
listener = this.Handles.TableListener;
listener.Enabled = 'off';

%% Update the table.  Call drawnow since this is asynchronous.
this.Handles.TablePanel.UpdatePlotContentTable(RespData);
drawnow

%% Re-Enable the table listener
listener.Enabled = 'on';