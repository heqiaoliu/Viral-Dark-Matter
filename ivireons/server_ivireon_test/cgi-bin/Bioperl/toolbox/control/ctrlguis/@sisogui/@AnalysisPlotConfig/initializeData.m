function initializeData(this)

%   Author(s): C. Buhr
%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $  $Date: 2008/09/15 20:36:42 $

this.createRespData;

PlotType =  {'none'; 'none'; 'none'; 'none'; 'none'; 'none'};

Viewer = this.SISODB.AnalysisView;

if ~isempty(Viewer)
    Contents = Viewer.getContents;
    ComboBoxes = this.Handles.TablePanel.getPlotCombos;
    for ct = 1:length(Contents)
        PlotType{ct} = Contents(ct).PlotType;
        VisModels = Contents(ct).VisibleModels;
        for ct2 = 1:length(VisModels)
            this.RespData{VisModels(ct2),ct} = true;
        end
    end
end


this.PlotType = PlotType;
