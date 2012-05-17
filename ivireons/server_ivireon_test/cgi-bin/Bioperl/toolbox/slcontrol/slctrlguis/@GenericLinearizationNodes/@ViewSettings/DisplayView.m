function DisplayView(this)
%DisplayView  Method to display the current view if it has been deleted 
%             of if it is at the bottom of the stack of windows.

%  Author(s): John Glass
%   Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.6.20 $ $Date: 2009/07/09 20:57:20 $

if isa(this.LTIViewer,'viewgui.ltiviewer')
    figure(double(this.LTIViewer.Figure));
else
    % Get the plot configurations
    plotconfigs = this.PlotConfigurations(:,2);
    ind_config = find(~strcmp(plotconfigs,'None'));
    plottype = plotconfigs(ind_config);
    
    % Check to see that a plot is being created
    if isempty(plottype)
        errordlg('Please select a plot type.','Simulink Control Design');
        return
    end
    
    % Create a flag that the ltiview has not yet been created
    ltiviewer = NaN;
                      
    % Get the visible results table data
    vis_td = this.Handles.VisibleResultTableModel.data;
    
    % Get the Linearization Results Nodes
    ResultsNodes = LocalFindAnalysisResultsChildren(this.up.up.getChildren);
    
    % Add the analysis results to the view
    % ct corresponsed to the current index into the analysis result vector
    if isempty(vis_td)
        % Create the ltiviewer
        [Viewer,ltiviewer] = ltiview(plottype);
        this.LTIViewer = ltiviewer;
        % Store the current set of viewers
        this.ViewHandles = ltiviewer.Views;
    else
        for ct = 1:size(vis_td,1)
            % Compute the sum of the row of plot visibility checkboxes
            cellrow = cell(vis_td(ct,2:7));
            if (sum([cellrow{:}]) > 0)
                sys = ResultsNodes(ct).LinearizedModel;
                % Convert to gridded model if the model is uncertain
                if ~isa(sys,'ss')
                    Name = sys.Name;
                    sys = usample(sys,20);
                    sys.Name = Name;
                end
                if ~isa(ltiviewer,'viewgui.ltiviewer')
                    % Create the ltiviewer
                    if strcmp(plottype,'initial')
                        [Viewer,ltiviewer] = ltiview(plottype,sys,zeros(size(sys.a,1),1));
                    else
                        [Viewer,ltiviewer] = ltiview(plottype);
                    end
                    this.LTIViewer = ltiviewer;
                    % Store the current set of viewers
                    this.ViewHandles = ltiviewer.Views;

                    % Add the view listener
                    this.ViewListener = handle.listener(ltiviewer,ltiviewer.findprop('Views'),...
                        'PropertyPostSet',{@LocalViewsChanged, this});
                end
                
                ltiviewer.importsys(sprintf('%s',ResultsNodes(ct).Label),sys);
                % Store a pointer to the ltisource for tracking later
                this.AnalysisResultPointers{ct,2} = this.LTIViewer.Systems(end);
            end
        end
        % Turn off the invisible systems plots
        updateVisibility(this)
    end
    
    % Update the titles
    for ct = 1:length(plottype)
        table_row = ind_config(ct);
        ltiviewer.Views(ct).AxesGrid.Title = this.PlotConfigurations{table_row,3};
    end
    
    % Create the plot visibility listeners.  Create a listener upon need
    this.PlotVisbilityListeners = handle(zeros(6,1));
    createVisibilityListeners(this)
    
    % Create the system delete listener
    createSystemDeleteListener(this)
    
    % Add listener to the AxesGrids of the views for title changes                 
    createTitleListener(this) 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalViewsChanged
function LocalViewsChanged(es,ed,this)

% Get the current view configurations in the ltiviewer
ViewConfigs = ed.NewValue;
   
% Disable the listeners
this.ViewListener.Enabled = 'off';
this.TitleListener.Enabled = 'off';

% Disable the table data changed callback
hdl = this.Handles.MATLABPlotSetupTableModel;
hdl(2).Enabled = 'off';

% Get the handle to the table model
PlotSetupTableModel = this.Handles.PlotSetupTableModel;

% Loop over them and set their new values
for ct = 1:length(ViewConfigs)
    table_ind = ct;
    if ~strcmp(class(ViewConfigs(ct)),'handle')
        plottype = ViewConfigs(ct).tag;
        util = com.mathworks.toolbox.slcontrol.util.LTIPlotUtils;
        PlotSetupTableModel.data(table_ind,2) = util.getComboLabelfromPlotType(plottype);
        this.PlotConfigurations{table_ind,2}  = plottype;
        % Set the plot title
        PlotSetupTableModel.data(table_ind,3) = java.lang.String(ViewConfigs(ct).AxesGrid.Title);
    else
        % Turn off configurations that may have been turned off by the
        % Plot Configurations Dialog.
        this.PlotConfigurations{table_ind,2} = 'None';
        PlotSetupTableModel.data(table_ind,2) = java.lang.String(xlate('None'));
        % Set the plot title to be empty
        PlotSetupTableModel.data(table_ind,3) = java.lang.String('');
    end
end

% Update the visibility columns
updateVisibleSystemsColumns(this,1:length(ViewConfigs))

% Fire the table update event
evt = javax.swing.event.TableModelEvent(PlotSetupTableModel);
javaMethodEDT('fireTableChanged',PlotSetupTableModel,evt);

% Renable the listener
this.ViewListener.Enabled = 'on';
this.TitleListener.Enabled = 'on';

% Add listener to the AxesGrids of the views for title changes
createTitleListener(this)
% Update the listeners for the visible systems
createVisibilityListeners(this)

% Renable the table data changed callback
hdl(2).Enabled = 'on';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalFindAnalysisResultsChildren
function Children = LocalFindAnalysisResultsChildren(Children)

% Loop over all the elements to remove the not of the class
% GenericLinearizationNodes.LinearAnalysisResultNode
for ct = length(Children):-1:1
    if ~isa(Children(ct),'GenericLinearizationNodes.LinearAnalysisResultNode')
        Children(ct) = [];    
    end
end
