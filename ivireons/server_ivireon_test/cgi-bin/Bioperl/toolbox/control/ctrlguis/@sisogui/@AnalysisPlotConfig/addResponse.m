function idx = addResponse(this,Contents)

%   Author(s): C. Buhr
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/12/14 14:29:08 $


idx = [];
addplot = true;
% Check if plot already exists
% find plots of same type
idxPlotType = find(strcmp(Contents.PlotType,this.PlotTypes));
if ~isempty(idxPlotType)
    for ct = 1:length(idxPlotType)
        VisModels = find([this.RespData{:,idxPlotType(ct)}]);
        if isequal(VisModels(:),Contents.VisibleModels(:))
           addplot = false; 
           this.updateViewer;
           break
        end
    end
end

if addplot
    idx = find(strcmp('none',this.PlotTypes));

    if isempty(idx)
        ctrlMsgUtils.warning('Control:compDesignTask:MaxViews')
    else
        idx = idx(1);
        this.PlotTypes{idx} = Contents.PlotType;
        this.RespData(Contents.VisibleModels,idx)= {true};
        this.refreshPanel;
        this.updateViewer;
    end
end


