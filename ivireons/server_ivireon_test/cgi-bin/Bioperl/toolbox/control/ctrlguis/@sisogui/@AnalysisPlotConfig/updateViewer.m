function updateViewer(this)
%UPDATEVIEWER  Updates SISO tool viewer  

%   Author(s): C. Buhr
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date: 2005/12/22 17:41:07 $


PlotTypeSel = this.Handles.TablePanel.getPlotCombos;
TableData = cell(this.Handles.TablePanel.getPlotContentTableModel.data);

Content = [];
idx = 1;
for ct = 1:length(PlotTypeSel)
    PlotSelectIdx = PlotTypeSel(ct).getSelectedIndex+1;
    this.PlotTypes{ct} = this.PlotTag{PlotSelectIdx};
    if ~strcmp(this.PlotTypes{ct},'none')
        % PlotTag is a different string than PlotType
        Content(idx).PlotType = this.PlotTag{PlotSelectIdx};
        Content(idx).VisibleModels = find(cell2mat(TableData(:,ct)));
        idx = idx+1;
    end
end

%% Only updated contents if either the sisotoolviewer exists or the
% contents exist
if ~isempty(Content) || ~isempty(this.SISODB.AnalysisView)

    if ~isempty(this.SISODB.AnalysisView)
        set([this.PlotVisbilityListeners(:);this.Listeners(:)],'enabled','off');
    end

    this.SISODB.setViewerContents(Content);

    set(this.Listeners,'enabled','on');

    this.createVisibilityListeners;
end