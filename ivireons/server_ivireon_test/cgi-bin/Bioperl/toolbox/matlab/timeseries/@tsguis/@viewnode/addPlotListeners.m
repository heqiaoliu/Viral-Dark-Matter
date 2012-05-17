function addPlotListeners(h)

% Copyright 2004-2005 The MathWorks, Inc.

%% Adds listeners which require a plot to be present

% Install a listener to update the axes table when a viewchanged event
% fires and so that the rowindices remain current
h.TableListener = handle.listener(h.Plot.Axesgrid,'Viewchanged',...
    {@localUpdateAxesTable h});   

%% Add a listener to keep the title of the figure synced with the node
%% label
h.addlisteners(handle.listener(h,h.findprop('Label'),'PropertyPostSet',...
    {@localUpdateFigTitle h}))  
    
h.Plot.addlisteners(handle.listener(h.Plot,'ObjectBeingDestroyed',{@localClose h}))


function localUpdateAxesTable(eventSrc,eventData,h)

%% Do nothing if limit manager is off
if strcmp(h.Plot.AxesGrid.LimitManager,'on') && ~isempty(h.Dialog)
    h.tstable;
end

function localUpdateFigTitle(eventSrc,eventData,h)

%% Callback for view node name changes which updates the figure title
thisTitle = get(ancestor(h.Plot.axesgrid.parent,'figure'),'Name');
colonpos = strfind(thisTitle,':');
if ~isempty(colonpos) && colonpos>0
    prefix = thisTitle(1:colonpos);
else
    prefix = '';
end
if ~isempty(h.Plot) && ishandle(h.Plot)
    set(ancestor(h.Plot.axesgrid.parent,'figure'),'Name',sprintf('%s %s',prefix,h.Label))
end

%% Update the dialog combo boxes
h.up.send('viewcontentschange')

function localClose(eventSrc,eventData,h)

%% Figure closing listener detaches view node. The node detachement
%% listener then disposes of the view
if ~isempty(h.up)
   h.up.removeNode(h);
end