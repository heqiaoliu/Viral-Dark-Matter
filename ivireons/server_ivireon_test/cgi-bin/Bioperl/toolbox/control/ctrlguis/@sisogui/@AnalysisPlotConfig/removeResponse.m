function removeResponse(this,Contents)

%   Author(s): C. Buhr
%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2006/03/26 01:11:07 $


idx = find(strcmp(Contents.PlotType,this.PlotTypes));

for ct = 1:length(idx)
    if isequal([this.RespData{Contents.VisibleModels,idx(ct)}],true(size(Contents.VisibleModels)));
        this.RespData(Contents.VisibleModels,idx(ct))= {false};
        if ~any([this.RespData{:,idx(ct)}]);
            this.PlotTypes{idx(ct)} = 'none';
        end
        break
    end
end

this.refreshPanel;
this.updateViewer;