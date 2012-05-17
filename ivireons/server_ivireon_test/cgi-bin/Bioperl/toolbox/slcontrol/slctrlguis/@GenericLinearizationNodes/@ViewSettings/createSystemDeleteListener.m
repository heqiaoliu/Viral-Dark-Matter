function createSystemDeleteListener(this)

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2006/01/26 01:58:30 $

%% Create the delete listener
this.DeleteViewListeners = handle.listener(this.LTIViewer,...
                                this.LTIViewer.findprop('Systems'),...
                                'PropertyPostSet',{@LocalSystemDeleted, this});
                                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalSystemDeleted - Determine if a system has been deleted by a user 
%%                      in the LTIViewer
function LocalSystemDeleted(es,ed,this)

NUMBER_OF_PLOTS = 6;

VisibleResultTableModel = this.Handles.VisibleResultTableModel;
%% Disable the table data changed callback
hdl = this.Handles.MATLABVisibleResultTableModel;
hdl(2).Enabled = 'off';

%% Get the table data
table_data = VisibleResultTableModel.data;

%% Loop over all the analysis results to see what systems have been deleted
for ct = 1:size(this.AnalysisResultPointers,1)
    if ~isempty(this.AnalysisResultPointers{ct,2})
        ind = find(this.AnalysisResultPointers{ct,2} == this.LTIViewer.Systems);
        if isempty(ind)
            this.AnalysisResultPointers{ct,2} = handle(0);
            for ct2 = 2:NUMBER_OF_PLOTS+1
                %% Update the table data
                table_data(ct,ct2) = java.lang.Boolean(false);
            end
        end
    end
end

VisibleResultTableModel.setData(table_data);

%% Renable the table data changed callback
drawnow;
hdl(2).Enabled = 'on';