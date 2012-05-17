function addMenu(h, tplot, menutype)

% Copyright 2004 The MathWorks, Inc.

%% Get the right label and callback
if strcmp(menutype,'delete')
    propval = {'Label','Replace with NaNs','Callback',...
        @(es,ed) delselection(tplot)}; 
elseif strcmp(menutype,'remove')
    propval = {'Label','Remove observations','Callback',...
        @(es,ed) rmselection(tplot)}; 
elseif strcmp(menutype,'keep')
    propval = {'Label','Keep observations','Callback',...
        @(es,ed) rmselection(tplot,'complement')};    
else
    return
end

%% Install uimenu on to selected curve's context menu    
if isempty(h.Menu.(menutype))
    for k=1:prod(size(h.SelectionCurves))
          h.Menus.(menutype) = [h.Menus.(menutype); uimenu(propval{:},...
              'Parent',get(h.SelectionCurves(k),'Uicontextmenu'))];
    end
end
