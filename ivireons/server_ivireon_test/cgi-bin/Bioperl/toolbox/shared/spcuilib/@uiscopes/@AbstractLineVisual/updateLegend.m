function updateLegend(this)
%UPDATELEGEND Update the legend for the plot.

%   Author(s): J. Schickler
%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2010/05/20 03:08:17 $

% If the axes isn't rendered we cannot add a legend and there isn't a
% legend that we need to remove.
if ~ishghandle(this.Axes)
    return;
end

legendStrings = getChannelNames(this);

legendValue = getPropValue(this, 'Legend');

hGUI = getGUI(this.Application);
hMenu = findwidget(hGUI, 'Menus', 'View', 'LineVisual', 'Legend');
set(hMenu, 'Checked', uiservices.logicalToOnOff(legendValue));

if isempty(legendStrings)
    legendValue = false;
end

hLegend = get(this, 'Legend');
if legendValue
    
    hLines = this.Lines;
    hLines(21:end) = [];
    legendStrings(21:end) = [];
    
    if ishghandle(hLegend)
        w = warning;
        warning('off', 'MATLAB:legend:IgnoringExtraEntries');
        if length(legendStrings) == length(get(hLegend, 'String'))

            set(hLegend, 'String', legendStrings(:)', 'Visible', 'on'); 
        else
            % If we are changing the number of legend strings, we need to
            % redraw the whole legend.
            oldLegendPosition = getpixelposition(hLegend);
            panelPosition = getpixelposition(get(this.Axes, 'Parent'));
            
            delete(hLegend)
            this.Legend = legend(hLines, legendStrings{:});
            newLegendPosition = getpixelposition(this.Legend);

            newLegendPosition(1:2) = oldLegendPosition(1:2);
            
            % Make sure that the top doesn't exceed the top of the display.
            if newLegendPosition(1)+newLegendPosition(3) > panelPosition(3)
                newLegendPosition(1) = panelPosition(3)-newLegendPosition(3)-1;
            end
            if newLegendPosition(2)+newLegendPosition(4) > panelPosition(4)
                newLegendPosition(2) = panelPosition(4)-newLegendPosition(4)-1;
            end
            
            % make sure that the bottom doesn't fall below the bottom of
            % the display.
            if newLegendPosition(1) < 1
                newLegendPosition(1) = 1;
            end
            if newLegendPosition(2) < 2
                newLegendPosition(2) = 2;
            end
            setpixelposition(this.Legend, newLegendPosition);
        end
        warning(w);
    else
        this.Legend = legend(hLines, legendStrings{:}, 'Location', 'Best');
        set(this.Legend, 'UIContextMenu', [], 'Location', 'None');
        for indx = 1:numel(this.Lines)
            l = uiservices.addlistener(this.Lines(indx), 'DisplayName', ...
                'PostSet', makeLegendStringCallback(this));
            setappdata(this.Lines(indx), 'DisplayNameListener', l);
        end
    end
elseif ishghandle(hLegend)
    
    % Turn off the listeners.
    legendcolorbarlayout(this.Axes, 'off');

    % Delete the legend.
    delete(hLegend);
end

% -------------------------------------------------------------------------
function cb = makeLegendStringCallback(this)

cb = @(h, ev) onLegendStringChanged(this);

% -------------------------------------------------------------------------
function onLegendStringChanged(this)

updatePropertyDb(this);

% Need to update channel names in the line props.
hLineProperties = this.LineProperties;

if ~isempty(hLineProperties)
    channelNames = getChannelNames(this);
    iterator.visitImmediateChildren(hLineProperties, ...
        @(hChannel) set(hChannel.WidgetHandle, 'Label', channelNames{hChannel.Placement}));
end

% [EOF]
