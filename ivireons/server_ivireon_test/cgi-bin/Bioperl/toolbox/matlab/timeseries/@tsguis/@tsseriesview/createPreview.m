function wb = createPreview(h,ts,wb)

% Copyright 2006-2008 The MathWorks, Inc.

%% Create a preview of the plot for early viewing...

set(findobj(allchild(h.Figure),'type','uimenu'),'enable','off');
set(allchild(findobj(allchild(h.Figure),'type','uitoolbar')),'enable','off')
ax1 = axes('parent',double(h.Figure),'Position',[0.1419 0.11 0.7631 0.7750]);
drawnow % Make sure queue is flushed so the figure paints immediately
set(h.Figure,'visible','on','HandleVisibility','on')
plot(timeseries(ts{1}.TsValue),'b');
set(h.Figure,'HandleVisibility','callback');
wb = waitbar(0,xlate('Creating Plot Preview'),'Name',xlate('Time Series Tools'));
figure(wb)
drawnow % Flush the queue so the figure shows first without the legend
leg = legend(ax1,h.getRoot.trimPath(ts{1}));