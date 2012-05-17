function addTs(h,ts,varargin)

% Copyright 2004-2006 The MathWorks, Inc.

import com.mathworks.mde.desk.*;
import com.mathworks.mwswing.*;
import com.mathworks.mwswing.desk.*;

if ~iscell(ts)
    ts = {ts};
end

%% Add the new time series
buildnewplot = false;
if length(ts)==1
    %% Case 1: No time series yet added
    if isempty(h.Timeseries1) && isempty(h.Timeseries2)
        h.Timeseries1 = ts{1};
        h.Timeseries2 = ts{1};
        % If necessary build the @corrplot
        if isempty(h.Plot) || ~ishandle(h.Plot) 
            localBuildPlot(h)
            buildnewplot = true;
        end
        %% Add the time series
        h.Plot.addTs(h.Timeseries1,h.Timeseries2);
    %% Case 2: Two timeseries already there - ask which one to replace
    elseif ~isempty(h.Timeseries1) && ~isempty(h.Timeseries2)
        if h.Timeseries1~=ts{1} && h.Timeseries2~=ts{1}
            if isempty(varargin)
                if h.Timeseries1~=h.Timeseries2
                    ButtonName = questdlg('Replace which Time Series object?', ...
                               'Time Series Tools', ...
                               ['' h.Timeseries1.Name '' ' '],['' h.Timeseries2.Name '' '  '],'Cancel','Cancel');
                    ButtonName = xlate(ButtonName);
                    switch ButtonName,
                        case ['' h.Timeseries1.Name '' ' '], 
                            h.Timeseries1 = ts{1};
                        case ['' h.Timeseries2.Name '' '  '],
                            h.Timeseries2 = ts{1};
                        case xlate('Cancel')
                            return
                    end 
                    h.Plot.addTs(h.Timeseries1,h.Timeseries2);
                else
                    h.Timeseries1 = ts{1};
                    h.Plot.addTs(h.Timeseries1,h.Timeseries2);
                end
            else
               if  strcmp(varargin,'x')
                   h.Timeseries1 = ts{1};
               else
                   h.Timeseries2 = ts{1};
               end
               h.Plot.addTs(h.Timeseries1,h.Timeseries2);
            end
        else
            if isempty(varargin)
                return
            else
                if strcmp(varargin,'x')
                    h.Timeseries1 = ts{1};
                else
                    h.Timeseries2 = ts{1};
                end
                h.Plot.addTs(h.Timeseries1,h.Timeseries2);
            end
        end
    %% Case 3: Put the time series in the missing spot and show
    else
       if isempty(h.Timeseries1)
           h.Timeseries1 = ts{1};
       else
           h.Timeseries2 = ts{1};
       end
       %% Add the time series
       h.Plot.addTs(h.Timeseries1,h.Timeseries2);
    end
else
   if ~isempty(h.Timeseries1) || ~isempty(h.Timeseries2)
       ButtonName = questdlg('Replace time series?', ...
                           'Time Series Tools', ...
                           'OK','Cancel','Cancel');
       ButtonName = xlate(ButtonName);
       if strcmp(ButtonName,xlate('Cancel'))
           return
       end
   end
   h.Timeseries1 = ts{1};
   h.Timeseries2 = ts{2};
   % If necessary build the @corrplot
   if isempty(h.Plot) || ~ishandle(h.Plot) 
       localBuildPlot(h)
       buildnewplot = true;
   end
   h.Plot.addTs(h.Timeseries1,h.Timeseries2);
end    

% Hide status text
set(h.Handles.InitTXT,'Visible','off')
%% Fire tschanged event to announce the change
h.send('tschanged',handle.EventData(h,'tschange'));

%% Refresh
if ~isempty(h.Plot) && ishandle(h.Plot)
    fig = ancestor(h.Plot.AxesGrid.Parent,'Figure');
    h.maybeDockFig;
    drawnow
    h.Plot.Visible = 'on';
    figure(fig);

end
h.setDropAdaptor(h.DropAdaptor);
    
function localBuildPlot(h)

viewpanel = tsguis.uitspanel('Parent',h.Figure,'Name','Time series correlation',...
    'SelectionHighlight','off');
b  = hggetbehavior(viewpanel,'PlotEdit');
b.EnableDelete = false;
ts1Size = h.Timeseries1.getdatasamplesize;
ts2Size = h.Timeseries2.getdatasamplesize;
h.Plot = tsguis.corrplot(viewpanel,...
    ts1Size(1),ts2Size(1));
h.Plot.Parent = h; %  Install parent
viewpanel.Plot = h.Plot; % On-the-fly build of property editor needs a plot handle