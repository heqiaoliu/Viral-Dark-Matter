function createTitleListener(this) 

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.8 $ $Date: 2008/12/04 23:27:06 $

% Get the plot configurations
plotconfigs = this.PlotConfigurations(:,2);
ind_config = find(~strcmp(plotconfigs,'None'));

% Add listener to the AxesGrids of the views.  Do not add if there are no
% plots visible.
if ~isempty(ind_config)
    AxGrid = get(this.LTIViewer.Views(1:length(ind_config)),{'AxesGrid'});
    this.TitleListener = handle.listener([AxGrid{:}],AxGrid{1}.findprop('Title'),...
        'PropertyPostSet',{@LocalTitleChanged, this});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalTitleChanged
function LocalTitleChanged(es,ed,this)

% Disable the table data changed callback
PlotSetupTableModel = this.Handles.PlotSetupTableModel;
hdl = this.Handles.MATLABPlotSetupTableModel;
hdl(2).Enabled = 'off';

% Get the indices of the rows of the table that are active
plotconfigs = this.PlotConfigurations(:,2);
active_ind = find(~strcmp(plotconfigs,'None'));

% Get the handles to the axesgrids
AxGrid = get(this.ltiviewer.Views(1:length(active_ind)),{'AxesGrid'});
% Find the index to the axesgrid that has changed
ind = find(ed.AffectedObject==[AxGrid{:}]);
% Set the plot title
PlotSetupTableModel.data(active_ind(ind),3) = java.lang.String(ed.AffectedObject.Title);
% Fire the table update event
thr = com.mathworks.toolbox.control.spreadsheet.MLthread(...
            PlotSetupTableModel, 'fireTableCellUpdated',...
            {int32(active_ind(ind)-1); int32(2)},'int,int');
javax.swing.SwingUtilities.invokeLater(thr);

% Clear the thread
drawnow

% Renable the table data changed callback
hdl(2).Enabled = 'on';