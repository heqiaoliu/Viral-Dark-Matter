function createVisibilityListeners(this)
%createVisibilityListeners  Creates listeners to visible ltiviewer plots 

%  Author(s): John Glass, Craig Buhr
%  Revised:
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.2 $ $Date: 2005/12/22 17:41:02 $

Viewer = this.SISODB.AnalysisView;

if strcmp(Viewer.Figure.Visible,'on')

    nVisiblePlots = length(find(~strcmpi('none',this.PlotTypes)));

    PlotVisbilityListeners=handle([]);
    for ct = 1:nVisiblePlots
        PlotVisbilityListeners(ct) = ...
            handle.listener(Viewer.Views(ct).Responses,...
            Viewer.Views(ct).Responses(1).findprop('Visible'),...
            'PropertyPostSet',{@LocalResponseVisabilityChanged this});
        PlotTypeListeners(ct) = ...
            handle.listener(Viewer, ...
            Viewer.findprop('Views'),...
            'PropertyPostSet',{@LocalPlotTypeChanged this});

    end

    this.PlotVisbilityListeners = PlotVisbilityListeners;
end


%% -----Local Functions ---------------------------------------------------
function LocalResponseVisabilityChanged(hsrc,eventdata,this)
% update the dialog
this.updateData;
this.refreshPanel;





