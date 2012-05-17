function setaxespositions(h)
%SETAXESPOSITIONS  Set axes positions for multipath figure object.

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/07/03 20:41:06 $

% Get axes panel width and height (in pixels).
axesPanelPos = get(h.UIHandles.AxesPanel, 'position');
axesPanelWidth = axesPanelPos(3);
axesPanelHeight = axesPanelPos(4);

% Get indices and positions of selected axes (from menu).
menuIdx = get(h.UIHandles.VisMenu, 'value');
selectedAxesIdx = h.AxesIdxDirectory{menuIdx};
selectedAxesRows = h.AxesRowDirectory{menuIdx};
selectedAxesWidths = h.AxesWidthDirectory{menuIdx};

% Multipath axes objects
axObjs = h.AxesObjects;

% Inactivate any current axes not selected from menu.
for m = h.CurrentAxesIdx
    if (~any(selectedAxesIdx==m))
        axObjs{m}.Active = false;
    end
end

% Position multipath axes objects.

% Axes layout parameters
numRows = max(selectedAxesRows);  % Number of axes rows
margin = 30;  % Margin in pixels
extraLeftMargin = 25;  % Additional margin on left side
extraTopMargin = 30;  % Additional margin at top for control panel
x0 = margin + extraLeftMargin;
y0 = margin;

% These variables are used in eval expressions to compute axes widths.
W = (axesPanelWidth-2*margin-extraLeftMargin);
H = (axesPanelHeight-2*margin-extraTopMargin)/numRows;

lastRow = 0;
for n = 1:length(selectedAxesIdx)

    % Get multipath axes object.
    m = selectedAxesIdx(n);
    ax = axObjs{m};
    
    % Compute axes position.
    row = selectedAxesRows(n);
    evalWidth = eval(selectedAxesWidths{n});
    if (row>lastRow)
        xEnd = x0;
    end
    width = evalWidth - 2*margin;
    height = H - 2*margin;
    x1 = xEnd + margin;
    y1 = (numRows-row)*H + margin + y0;
    
    % Store for next loop.
    lastRow = row;
    xEnd = xEnd + evalWidth;

    % Make axes active and set position.
    ax.Active = true;
    ax.Position = [x1 y1 width height]+0;

    % Re-position legend after resize
    if ( isequal(class(ax), 'channel.mpdoppleraxes') ...
            || isequal(class(ax), 'channel.mpscatteraxes') )
        % No re-positioning done the first time selectaxes is called (because
        % ax.PlotHandles doesn't contain anything yet)
        if (~ax.FirstPlot)
            N = length(ax.PlotHandles);
            ax.AuxObjHandles = ...
                legend(ax.AxesHandle, [ax.PlotHandles(1) ax.PlotHandles(N/2+1)], ...
                    'Theoretical', 'Measurement', 'Location', 'NorthEast');
        end
    end  
    
    % Forces the 'Position' property of h.AxesHandle to stay the same as
    % the 'Position' property of ax, because the legend command above
    % changes the width/height of the axes plot.
    set(ax.AxesHandle,'Position', ax.Position);

    % Refresh ZTickLabels after resize
    if ( isequal(class(ax), 'channel.mpscatteraxes') )
        % Manually set ZTickLabels because when in auto mode, 10^-x overlaps with
        % the title. When figure is resized, ZTickLabels must be manually set again.
        set(ax.AxesHandle,'ZTickLabelmode','auto')  % Let Matlab recompute ZTick
        zsc = cellstr(num2str(get(ax.AxesHandle,'ZTick')'));
        set(ax.AxesHandle,'ZTickLabel',zsc);
    end    

    % Refresh YTickLabels after resize
    if ( isequal(class(ax), 'channel.mpdoppleraxes') )
        % Manually set YTickLabels because when in auto mode, 10^-x overlaps with
        % the title. When figure is resized, YTickLabels must be manually set again.
        set(ax.AxesHandle,'YTickLabelmode','auto')  % Let Matlab recompute YTick
        zsc = cellstr(num2str(get(ax.AxesHandle,'YTick')'));
        set(ax.AxesHandle,'YTickLabel',zsc);
    end    
    
end

% Set current axes indices.
h.CurrentAxesIdx = selectedAxesIdx;
