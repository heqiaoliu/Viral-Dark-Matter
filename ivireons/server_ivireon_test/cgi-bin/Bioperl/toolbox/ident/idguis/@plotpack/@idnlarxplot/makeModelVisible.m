function makeModelVisible(this,Name,makeVisible)
% make all lines corresponding to the idnlarx model with name=Name visible
% or invisible.
% makeVisible: true or false.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/02/23 17:16:05 $

h = find(this.ModelData,'ModelName',Name);
h.isActive = makeVisible;

if ~any(cell2mat(get(this.ModelData,{'isActive'})))
    close(this.Figure)
    return
end

c1 = findall(this.MainPanels,'type','line','tag',Name);
c2 = findall(this.MainPanels,'type','surface','tag',Name);
c = [c1;c2];

if ~isempty(c)
    if makeVisible
        set(c,'Visible','on');
    else
        set(c,'Visible','off');
    end
end

% update active regressors before updating list of outputs because we want
% to update regressors of ALL outputs (including those that may be being
% deactivated).
this.updateActiveRegressors; 
this.OutputNames = this.getOutputNames;
this.updateLabelLegendCombo;
%this.showPlot;
