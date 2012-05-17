function makeModelVisible(this,Name,makeVisible)
% make all lines corresponding to the idnlhw mode with name=Name visible or
% invisible.
% makeVisible: true or false.

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:56:33 $

h = find(this.ModelData,'ModelName',Name);
h.isActive = makeVisible;

if ~any(cell2mat(get(this.ModelData,{'isActive'})))
    close(this.Figure)
    return
end


c = findall(this.MainPanels,'type','line','tag',Name);

if ~isempty(c)
    if makeVisible
        set(c,'Visible','on');
    else
        set(c,'Visible','off');
    end
end

this.setIONames;
this.updateLabelLegendCombo;
this.showPlot;
