function dropCallback(h,x,y)

% Copyright 2004-2006 The MathWorks, Inc.

% tsnode -> viewnode
% tsnode -> viewcontainer
% viewnode -> viewcontainer
% viewnode -> viewnode


%% Find currently selected node 
n = h.Tree.getSelectedNodes;
if isempty(n)
   return
end
droppednode = handle(n(1).getValue);

%% Get the target node and make sure that it fits one of the above cases
targetviewnode = handle(h.Tree.getTree.getPathForLocation(x,y).getLastPathComponent.getValue);
strvec = 'ft';

switch strvec([isa(droppednode,'tsguis.viewnode'),...
        (isa(droppednode,'tsguis.tsnode') || isa(droppednode,'tsguis.tscollectionNode')),...
        isa(targetviewnode,'tsguis.viewnode'),isa(targetviewnode,'tsguis.viewcontainer')]+1)
    case 'fttf' % Data dropped onto a view
         ts = droppednode.getTimeSeries;
         if localChkNumTs(ts)
             return;
         end
         newview = targetviewnode;
    case 'ftft' % Data dropped onto a view container
         ts = droppednode.getTimeSeries;
         if localChkNumTs(ts)
             return;
         end
         newview = targetviewnode.addplot(h);
    case 'tftf' %View dropped onto a view
         targetviewnode = targetviewnode.up;
         % If the selected and drop nodes are views of the same type then there is
         % nothing to do
         if targetviewnode==droppednode.up
            return
         end
         if ~isempty(droppednode.Plot)
             ts = droppednode.Plot.getTimeSeries;
         else
             ts = [];
         end
         if localChkNumTs(ts)
             return;
         end
         newview = targetviewnode.addplot(h);
         ts = localDealWithDups(droppednode,targetviewnode,ts);
    case 'tfft' % View dropped onto a view container
         % If the selected and drop nodes are views of the same type then there is
         % nothing to do
         if targetviewnode==droppednode.up
            return
         end
         if ~isempty(droppednode.Plot)
             ts = droppednode.Plot.getTimeSeries;
         else
             ts = [];
         end
         if localChkNumTs(ts)
             return;
         end
         newview = targetviewnode.addplot(h);
         ts = localDealWithDups(droppednode,targetviewnode,ts);
end  

%% Add content time series to plot
if length(ts)>=2 && ...
        (isa(newview,'tsguis.tscorrnode') || isa(newview,'tsguis.tsxynode'))
    newview.addTs(ts(1:2));
elseif ~isempty(ts)
    newview.addTs(ts);
else % Make empty fig visible and dock it 
    set(newview.Figure,'Visible','on');
    if ~isempty(h.Root.tsViewer.MDIGroupName)
        set(ancestor(newview.Figure,'Figure'),'WindowStyle','docked')
    end
end
  
%% Local functions
function abortFlag = localChkNumTs(tsList)

abortFlag = false;
if length(tsList)>10
    ButtonName = questdlg(sprintf('Attempting to plot more than %d time series in a single axes may take time. Continue?',length(tsList)), ...
                       xlate('Time Series Tools'), ...
                       xlate('Continue'),xlate('Abort'),xlate('Abort'));
    if strcmp(ButtonName,xlate('Abort'));
        abortFlag = true;
    end
end

function tsout = localDealWithDups(droppednode,targetviewnode,ts)

 % Handle the case where a xyplot or corrplot with duplicate time
 % series is dropped to create a timeplot/specpplot/histplot
 tsout = ts;
 if (isa(droppednode,'tsguis.tsxynode') || isa(droppednode,'tsguis.tscorrnode')) && ...
         isa(targetviewnode,'tsguis.viewcontainer') && ...
         (strcmp(targetviewnode.childClass,'tsguis.tsseriesview') || ...
          strcmp(targetviewnode.childClass,'tsguis.tsspecnode') || ...
          strcmp(targetviewnode.childClass,'tsguis.tshistnode')) && ...
          length(ts)>=2 && ~isempty(ts{1}) && ~isempty(ts{2}) && ...
          ts{1} == ts{2}
      tsout = ts{1};
 end
         