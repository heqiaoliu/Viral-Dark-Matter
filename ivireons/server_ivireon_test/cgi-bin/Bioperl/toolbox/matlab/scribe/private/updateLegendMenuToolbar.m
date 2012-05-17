function updateLegendMenuToolbar(hProp,eventData, cax) %#ok
%updateLegendMenuToolbar Update menu and toolbar for legend

%   Copyright 2005-2007 The MathWorks, Inc.

if ~isempty(eventData), cax = eventData.NewValue; end
cax = double(cax);
fig = ancestor(cax,'figure');

if isa(handle(cax),'scribe.legend') || isa(handle(cax),'scribe.colorbar')
  hlc = handle(cax);
  cax = double(hlc.Axes);
end

%Get the legend toggle and the legend menuitem
ltogg = uigettool(fig,'Annotation.InsertLegend');
lmenu = findall(fig,'Tag','figMenuInsertLegend');
%Get the colorbar toggle and the colorbar menuitem
cbtogg = uigettool(fig,'Annotation.InsertColorbar');
cbmenu = findall(fig,'Tag','figMenuInsertColorbar');

%Check if the legend is on for the current axes
legs = find(handle(fig),'-isa','scribe.legend');
legon = false;
for k=1:length(legs)
  leg = handle(legs(k));
  if isequal(double(leg.Axes),cax) && ...
    ~strcmpi(get(leg,'BeingDeleted'),'on')
    legon=true;
  end
end
%Check if the colorbar is on for the current axes
cbars = find(handle(fig),'-isa','scribe.colorbar');
cbaron = false;
for k=1:length(cbars)
  cbar = handle(cbars(k));
  if isequal(double(cbar.Axes),cax) && ...
    ~strcmpi(get(cbar,'BeingDeleted'),'on')
    cbaron=true;
  end
end

%set the legend toggle/menuitem appropriately
if legon
  if ~isempty(ltogg)
    set(ltogg,'state','on');
  end
  if ~isempty(lmenu)
    set(lmenu,'checked','on');
  end
else
  if ~isempty(ltogg)
    set(ltogg,'state','off');
  end
  if ~isempty(lmenu)
    set(lmenu,'checked','off');
  end
end
%set the colorbar toggle/menuitem appropriately
if cbaron
  if ~isempty(cbtogg)
    set(cbtogg,'state','on');
  end
  if ~isempty(cbmenu)
    set(cbmenu,'checked','on');
  end
else
  if ~isempty(cbtogg)
    set(cbtogg,'state','off');
  end
  if ~isempty(cbmenu)
    set(cbmenu,'checked','off');
  end
end
