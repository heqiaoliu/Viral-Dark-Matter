function removets(view,ts)

% Copyright 2004-2008 The MathWorks, Inc.

%% Removes a time series from a view node. 
if ~isempty(view.Plot) && ishandle(view.Plot)
     for k=1:length(view.Plot.Responses)
        if ~isempty(view.Plot.Responses(k).DataSrc) && ...
                (isequal(view.Plot.Responses(k).DataSrc.Timeseries,ts) || ...
                 isequal(view.Plot.Responses(k).DataSrc.Timeseries2,ts))
             view.Plot.rmresponse(view.Plot.response(k));
             break
        end
    end
    
    % Synconize the node properties
    if isequal(ts,view.Timeseries1)     
         set(view,'Timeseries1',[])
    end
    if isequal(ts,view.Timeseries2)
        set(view,'Timeseries2',[])
    end
    
    % Programmatically refresh the time series table to remove any empty
    % axes or close the view if its empty    
     if isempty(view.Plot.Responses)

         if isempty(view.Timeseries1) && isempty(view.Timeseries2)
             view.remove(view.getRoot.Tsviewer.TreeManager);
         else
             view.Plot.resize({''},{''});
             view.Plot.AxesGrid.Title = xlate('XY Plot');
             set(view.Handles.InitTXT,'Visible','on') 
         end
     end
end

%% Notify listeners
view.send('tschanged',handle.EventData(view,'tschange'));