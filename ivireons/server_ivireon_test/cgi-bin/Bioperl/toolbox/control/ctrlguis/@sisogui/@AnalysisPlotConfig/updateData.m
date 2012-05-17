function updateData(this)
%updateDATA  Updates data for the SISO tool viewer 

%   Author(s): C. Buhr
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:49:08 $


if strcmpi(this.SISODB.AnalysisView.Figure.Visible,'on')

    Contents = this.SISODB.AnalysisView.getContents;


    idxVisiblePlots = find(~strcmpi('none',this.PlotTypes));

    if isequal(length(idxVisiblePlots), length(Contents))
        for ct = 1:length(Contents)
            VisModels = Contents(ct).VisibleModels;
            this.PlotTypes(idxVisiblePlots(ct)) = {Contents(ct).PlotType};
            this.RespData(:,idxVisiblePlots(ct)) = {false};
            for ct2 = 1:length(VisModels)
                this.RespData{VisModels(ct2),idxVisiblePlots(ct)} = true;
            end
        end
    else
        this.initializeData;
    end

    this.refreshPanel;
end


function LocalPlotTypeChanged(hsrc,eventdata,this)
% update the combo boxes

Contents = this.SISODB.AnalysisView.getContents;


ComboBoxes = this.Handles.TablePanel.getPlotCombos;
for ct = 1:length(Contents)
    PlotType{ct} = Contents(ct).PlotType;
end

this.PlotType = PlotType;

this.refreshPanel;