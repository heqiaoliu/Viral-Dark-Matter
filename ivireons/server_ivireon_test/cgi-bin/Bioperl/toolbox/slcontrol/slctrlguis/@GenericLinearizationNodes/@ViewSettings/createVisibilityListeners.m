function createVisibilityListeners(this)

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2008/12/04 23:27:07 $

% Get the plot configurations
plotconfigs = this.PlotConfigurations(:,2);
ind_config = find(~strcmp(plotconfigs,'None'));
    
for ct = 1:length(ind_config)
    if ~isempty(this.LTIViewer.Views(ct).Responses)
        this.PlotVisbilityListeners(ind_config(ct)) = handle.listener(...
            this.LTIViewer.Views(ct).Responses,...
            this.LTIViewer.Views(ct).Responses(1).findprop('Visible'),...
            'PropertyPostSet',{@LocalResponseVisabilityChanged, this,...
            this.LTIViewer.Views(ct).Responses,ind_config(ct)});
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalResponseVisabilityChanged
function LocalResponseVisabilityChanged(es,ed,this,responses,table_ind)

VisibleResultTableModel = this.Handles.VisibleResultTableModel;
% Disable the table data changed callback
hdl = this.Handles.MATLABVisibleResultTableModel;
hdl(2).Enabled = 'off';

% Find the response index
resp_ind = find(ed.AffectedObject==responses);
% Get the ltisource that matches the index
source = this.LTIViewer.Systems(resp_ind);
% Get the corresponding pointers in the table
result_pointers = [this.AnalysisResultPointers{:,2}];
% Get the matching index to the table
resp_ind = find(source == result_pointers);

% Update the table data
VisibleResultTableModel.data(resp_ind,table_ind+1) = Boolean(onoff2bool(ed.NewValue));
% Fire the table update event
thr = com.mathworks.toolbox.control.spreadsheet.MLthread(...
            VisibleResultTableModel, 'fireTableCellUpdated',...
            {int32(resp_ind-1); int32(table_ind)},'int,int');
javax.swing.SwingUtilities.invokeLater(thr);

% Renable the table data changed callback
hdl(2).Enabled = 'on';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions
function boolval = onoff2bool(onoffval)
if strcmp(onoffval,'on');
    boolval = true;
else
    boolval = false;
end