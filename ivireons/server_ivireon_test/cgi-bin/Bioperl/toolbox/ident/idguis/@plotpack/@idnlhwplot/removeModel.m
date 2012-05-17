function removeModel(this,Name)
%Remove model with name=Name from plot

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:56:35 $

h = find(this.ModelData,'ModelName',Name);

if isempty(h) || ~ishandle(h)
    return;
end

this.ModelData(this.ModelData==h) = [];

if isempty(this.ModelData)
    close(this.Figure);
    return
end

% delete lines
c = findall(this.MainPanels,'type','line','tag',Name);
delete(c)

% delete those panels that have empty axes
%Ax = findall(this.MainPanels,'type','axes');
Ax = this.getAllAxes;
uirem = handle([]);
for k = 1:length(Ax)    
    l = findobj(Ax(k),'type','line');
    if isempty(l)
        uirem(end+1) = get(Ax(k),'Parent');
    end
end

delete(unique(uirem));

this.setIONames;
this.updateLabelLegendCombo;

this.showPlot;
