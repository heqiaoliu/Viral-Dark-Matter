function addLinePropertyMenus(this)
%ADDLINEPROPERTYMENUS 

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/04/21 21:49:35 $

hLineProperties = this.LineProperties;
if isempty(hLineProperties)
    hLineProperties = this.Application.getGUI.findchild('Base/Menus/View/LineVisual/LineProperties');
    this.LineProperties = hLineProperties;
end

% The main line properties menu was not installed, we cannot proceed.
if isempty(hLineProperties)
    return;
end

channelNames = getChannelNames(this);
removeChildren(hLineProperties);

for indx = 1:min(numel(this.Lines), 20)
    hChannel = uimgr.uimenugroup(sprintf('Channel%d', indx), indx, channelNames{indx});
    hVisible = uimgr.uimenu('Visible', 1, '&Visible');
    
    hVisible.WidgetProperties = { ...
        'Callback', @(h,ev) toggleVisible(this, indx)};
    
    % Add the style menu and its submenu.
    hStyle = uimgr.uimenugroup('LineStyle', 1, '&Style');

    labels = {'&None', '-','--',':','-.'};
    styleids = {'none','-','--',':','-.'};
    
    for jndx = 1:numel(labels)
        hMenu = uimgr.uimenu(styleids{jndx}, jndx, labels{jndx});
        hMenu.WidgetProperties = { ...
            'Callback', @(h, ev) setLineProperty(this, 'LineStyle', styleids{jndx}, indx)};
        hStyle.add(hMenu);
    end
    
    % Add the marker menu and its submenu.
    hMarker = uimgr.uimenugroup('Marker', 2, '&Marker');
    
    labels = {'&None', '+','o','*','.','x','square','diamond'};
    markerids = {'none','+','o','*','.','x','square','diamond'};
    
    for jndx = 1:numel(labels)
        hMenu = uimgr.uimenu(markerids{jndx}, jndx, labels{jndx});
        hMenu.WidgetProperties = { ...
            'Callback', @(h, ev) setLineProperty(this, 'Marker', markerids{jndx}, indx)};
        hMarker.add(hMenu);
    end
    
    % Add the color menu and its submenu.
    hColor = uimgr.uimenugroup('Color',  3, '&Color');
    
    labels = {'&Cyan', '&Magenta', '&Yellow', 'Blac&k', '&Red', '&Blue', '&Green'};
    colorids = {'c','m','y','k', 'r','b','g'};
    
    for jndx = 1:numel(labels)
        hMenu = uimgr.uimenu(colorids{jndx}, jndx, labels{jndx});
        hMenu.WidgetProperties = { ...
            'Callback', @(h, ev) setLineProperty(this, 'Color', colorids{jndx}, indx)};
        hColor.add(hMenu);
    end
    
    hMenu = uimgr.uimenu('other', numel(labels)+1, 'Other');
    hMenu.WidgetProperties = { ...
        'Callback', @(h, ev) setOtherColor(this, indx)};

    hColor.add(hMenu);

    hLineDisplay = uimgr.uimenugroup('LineDisplay', 2, hStyle, hMarker, hColor);
    
    hChannel.add(hVisible);
    hChannel.add(hLineDisplay);
    
    hLineProperties.add(hChannel);
end

render(hLineProperties, this.Application.Parent);

% -------------------------------------------------------------------------
function setOtherColor(this, index)

newValue = uisetcolor;
if isequal(newValue, 0)
    return;
end
setLineProperty(this, 'Color', newValue, index);

% -------------------------------------------------------------------------
function setLineProperty(this, prop, value, index)

updatePropertyDb(this);
lineProperties = getPropValue(this, 'LineProperties');

lineProperties(index).(prop) = value;

setPropValue(this, 'LineProperties', lineProperties);

% -------------------------------------------------------------------------
function toggleVisible(this, index)

updatePropertyDb(this);
lineProperties = getPropValue(this, 'LineProperties');

oldValue = lineProperties(index).Visible;

if strcmpi(oldValue, 'on')
    newValue = 'off';
else
    newValue = 'on';
end

lineProperties(index).Visible = newValue;

this.setPropValue('LineProperties', lineProperties);

% [EOF]
