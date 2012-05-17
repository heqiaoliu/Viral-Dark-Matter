function plotinfigure(h, varargin)
%PLOTINFIGURE plot this results signal 


%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/05/20 02:18:15 $

isupdating = false;
if(nargin > 1)
    isupdating = varargin{1};
end

hfig = h.figures.get('plotinfigure');
hfig = handle(hfig);
if(isempty(hfig))
    hfig = createfig(h);
    h.figures.put('plotinfigure',double(hfig));
end

try
    %plot the selected signal
    ts = h.Signal;
    figure(hfig);
    set(hfig, 'HandleVisibility', 'on');
    % Set the Events to [] to prevent them from being plotted along with the data. A change has been introduce in plotting
    % to plot any event data. Since we do not want this, set the Event to []. The unified data logging will not populate this
    % field in the future and the below code can be removed at that point.
    ts.Events = [];
    plot(ts);
    %add title
    haxes = findall(hfig,'Type','Axes');
    htitle = get(haxes, 'Title');
    set(htitle, ...
        'Interpreter', 'none', ...
        'fontweight','b', ...
        'Tag', 'title');
    plottitle = h.getplottitle;
    set(htitle, 'String', [plottitle ' (' h.Run ')']);
    if(isfield(ts.DataInfo.UserData, 'isindexed') && ts.DataInfo.UserData.isindexed)
        %leave a space at the end so xlate sees 1 word
        xlabel(DAStudio.message('FixedPoint:fixedPointTool:xlabelIndex'));
    else
        xlabel(DAStudio.message('FixedPoint:fixedPointTool:xlabelTime'));
    end
    ylabel(DAStudio.message('FixedPoint:fixedPointTool:ylabelRealWorldValue'));
    %set tags for testing
    hxlabel = get(haxes, 'XLabel');
    set(hxlabel, 'Tag', 'xlabel');
    hylabel = get(haxes, 'YLabel');
    set(hylabel, 'Tag', 'ylabel');  
    drawnow;    
catch e %#ok
    hfig = h.figures.remove('plotinfigure');
    delete(handle(hfig));
    fxptui.showdialog('ploterror');
    return;
end
if(~isupdating)
    set(hfig, 'Visible', 'on');
end
set(hfig, 'HandleVisibility', 'callback');

%--------------------------------------------------------------------------
function hfig = createfig(h)
scrsz = get(0,'ScreenSize');
hfig = figure( ...
    'Visible', 'off', ...
    'Position', [.64*scrsz(3) .58*scrsz(4) .25*scrsz(3) .25*scrsz(4)], ...
    'Name',  DAStudio.message('FixedPoint:fixedPointTool:plotTitleTimeSeries'), ...
    'IntegerHandle', 'off', ...
    'NumberTitle', 'off', ...
    'CloseRequestFcn', @(s,e)figureclose(s,e), ...
    'HandleVisibility','callback',...
    'Tag','FixedPointToolTSPlotFig');
set(hfig,'CloseRequestFcn', @(s,e)fxptui.figureclose(s,e,hfig));


% [EOF]
