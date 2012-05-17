function addPlot(h,label)

% Copyright 2004-2005 The MathWorks, Inc.

%% Add view menu callback which adds a new time series to the
%% MDI view
name = inputdlg('Name for new plot','Time Series Tools');
if isempty(name) % Cancel applied
    return
else % Keep the new plot dialog open until a non-empty name is entered
    while isempty(deblank(name{1}))
        name = inputdlg('Name for new plot','Time Series Tools');
        if isempty(name)
            return
        end
    end
end

%% Add the plot node
newview = h.ViewsNode.getChildren('Label',label).addplot(h.TreeManager,name{1});
set(newview.Figure,'Visible','on');
if ~isempty(h.MDIGroupName)
    set(ancestor(newview.Figure,'Figure'),'WindowStyle','docked')
end
