function updateLegends(this)
% update legends on all axes

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:56:06 $

Ax = findobj(this.MainPanels,'type','axes');

for k = 1:length(Ax)
    axk = Ax(k);
    y = get(axk,'tag'); %output name
    robj = find(this.RegressorData,'OutputName',y);
    if ~isempty(robj)
        this.addLegend(axk,robj.is2D); 
    end
end
