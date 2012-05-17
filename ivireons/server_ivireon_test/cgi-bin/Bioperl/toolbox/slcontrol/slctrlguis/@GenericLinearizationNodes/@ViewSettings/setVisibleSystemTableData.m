function setVisibleSystemTableData(this, row, col)
%setVisibleSystemTableData  Method to update the visible systems in a view table

%  Author(s): John Glass
%  Copyright 1986-2005 The MathWorks, Inc.

NUMBER_OF_PLOTS = 6;

% Make the column and rows to be in MATLAB units instead of Java
col = col+1;
row = row+1;

% Do not update the viewer if the first column is updated since this is
% the label column
if col > 1
    % Get the LTIViewer
    ltiviewer = this.LTIViewer;
    
    % Get the new data 
    VisibleResultTableModel = this.Handles.VisibleResultTableModel;
    newdata = VisibleResultTableModel.data(row,col);
    % Store the new data to be saved
    this.VisibleResultTableData = VisibleResultTableModel.data;
    
    if isa(ltiviewer,'viewgui.ltiviewer')
        AnalysisResultPointers = this.AnalysisResultPointers;
        % Find the index into the ltisource for the system to set the
        % visibility.  If one does not exist create one.
        if isa(AnalysisResultPointers{row,2},'resppack.ltisource')
            
            % Disable the visibility listeners
            for ct = 1:length(this.PlotVisbilityListeners)
                if isa(this.PlotVisbilityListeners(ct),'handle.listener')
                    this.PlotVisbilityListeners(ct).enable = 'off';
                end
            end
            
            % Find the system to disable
            ind = find(AnalysisResultPointers{row,2} == ltiviewer.Systems);
            % Compute the plot cell index
            ActiveColumns=this.VisibleTableColumns(1:end,2);
            cellind = sum([ActiveColumns{1:col-1}]);
            PlotCells = ltiviewer.PlotCells{cellind};
            for ct = 1:length(PlotCells)
                PlotCells(ct).Responses(ind).Visible = bool2onoff(newdata);
            end
            
            % Enable the visibility listeners
            for ct = 1:length(this.PlotVisbilityListeners)
                if isa(this.PlotVisbilityListeners(ct),'handle.listener')
                    this.PlotVisbilityListeners(ct).enable = 'on';
                end
            end
        else
            Result = AnalysisResultPointers{row,1};
            ltiviewer.importsys(sprintf('%s',Result.Label),Result.LinearizedModel);            
            this.AnalysisResultPointers{row,2} = ltiviewer.Systems(end);
            
            % Turn on the visility for all plots for this result
            this.ViewListener.Enabled = 'off';
            
            % Disable the table data changed callback
            hdl = this.Handles.MATLABVisibleResultTableModel;
            hdl(2).Enabled = 'off';

            % Update the table data
            for ct = 2:NUMBER_OF_PLOTS+1
                VisibleResultTableModel.data(row,ct) = java.lang.Boolean(true);
            end
            
            % Fire the table update event
            evt = javax.swing.event.TableModelEvent(VisibleResultTableModel);
            javaMethodEDT('fireTableChanged',VisibleResultTableModel,evt);
            
            % Update the listeners for the visible systems
            createVisibilityListeners(this)
            % Renable the table data changed callback
            hdl(2).Enabled = 'on';
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions
function onoffval = bool2onoff(boolval)
if boolval;
    onoffval = 'on';
else
    onoffval = 'off';
end
    
        
