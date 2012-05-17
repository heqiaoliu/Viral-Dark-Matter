function this = TimeDomainVisual(varargin)
%TIMEDOMAINVISUAL Construct a TIMEDOMAINVISUAL object

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5.4.1 $  $Date: 2010/07/13 19:33:28 $

this = scopeextensions.TimeDomainVisual;

initVisual(this, varargin{:});

lclConvertObsoleteProps(this);

hApp = this.Application;
this.SourceListeners = [ ...
    handle.listener(hApp, 'SourceRun',         @(h, ev) onSourceRun(this)) ...
    handle.listener(hApp, 'SourceStop',        @(h, ev) onSourcePauseStop(this)) ...
    handle.listener(hApp, 'SourcePause',       @(h, ev) onSourcePauseStop(this)) ...
    handle.listener(hApp, 'SourceContinue',    @(h, ev) onSourceContinue(this)) ...
    handle.listener(hApp, 'DataSourceChanged', @(h, ev) onDataSourceChanged(this))];

propertyChanged(this, 'InputProcessing');
propertyChanged(this, 'TimeDisplayOffset');

% -------------------------------------------------------------------------
function onSourcePauseStop(this)
%ONSOURCESTOP React to the datasource stopping.

% Make sure that we have as much data in the display as possible.
source = this.Application.DataSource;
if ~isempty(source)
    if ~validateSource(this, source)
        return;
    end
    update(this, getOriginTime(source), getTimeOfDisplayData(source));
end

% Get all of the good lines.
hLines = this.Lines;
hLines(~ishghandle(hLines)) = [];

% Set the erasemode back to normal so the user sees exactly what we have
% stored on the lines.
set(hLines, 'EraseMode', 'Normal');

if ~this.MissingDataWarningThrown && ~isempty(hLines)

    % Check all the xdata from the lines and make sure that
    xdata = get(hLines, 'XData');
    xlim = get(this.Axes, 'XLim');
    if ~iscell(xdata)
        xdata = {xdata};
    end
    
    % Get all of the time display offsets.
    tdo = this.TimeDisplayOffset;
    
    for indx = 1:numel(xdata)
        
        % Get the time display offset for this line.
        if isscalar(tdo)
            itdo = tdo;
        elseif numel(tdo) < indx
            itdo = 0;
        else
            itdo = tdo(indx);
        end
        % If the first xdata point is greater than 1% away from the left edge
        % throw the warning that we have not buffered enough data.
        if ~isempty(xdata{indx}) && (xdata{indx}(1)-itdo) / (xlim(2)-xlim(1)) > .01
            
            add(this.Application.MessageLog, 'Warn', 'Extension', ...
                'Missing Data', uiscopes.message('MissingDataInTimeDomain'));
            this.MissingDataWarningThrown = true;
            return;
        end
    end
end

% -------------------------------------------------------------------------
function onSourceRun(this)
%ONSOURCERUN React to the datasource running.

% Reset the YExtents because new data is coming in.
this.YExtents = [NaN NaN];

% When the source is started up again, we need to clear the buffer.  The
% buffer is stored in the lines themselves.  Delete them.
hLines = get(this, 'Lines');
for indx = 1:length(hLines)
    set(hLines(indx), ...
        'YData', NaN(1, numel(get(hLines(indx), 'XData'))), ...
        'EraseMode', 'None');
end

if ~screenMsg(this.Application)
    updateLegend(this);
end

% -------------------------------------------------------------------------
function onSourceContinue(this)

hLines = this.Lines;

set(hLines(ishghandle(hLines)), 'EraseMode', 'None');

% -------------------------------------------------------------------------
function lclConvertObsoleteProps(this)

hPropDb = this.Config.PropertyDb;

prop = hPropDb.findProp('MinXLim');
if ~isempty(prop) && isnumeric(prop.Value)
    hPropDb.remove(prop);
    hPropDb.add('MinXLim', 'string', num2str(prop.Value));
end
prop = hPropDb.findProp('MaxXLim');
if ~isempty(prop) && isnumeric(prop.Value)
    hPropDb.remove(prop);
    hPropDb.add('MaxXLim', 'string', num2str(prop.Value));
end

prop = hPropDb.findProp('MinYLim');
if ~isempty(prop) && isnumeric(prop.Value)
    hPropDb.remove(prop);
    hPropDb.add('MinYLim', 'string', num2str(prop.Value));
end
prop = hPropDb.findProp('MaxYLim');
if ~isempty(prop) && isnumeric(prop.Value)
    hPropDb.remove(prop);
    hPropDb.add('MaxYLim', 'string', num2str(prop.Value));
end

% Replace any old Line* properties with the structure LineProperties
% property.  Remove the old Properties from the Config.
prop = hPropDb.findProp('LineNames');
if ~isempty(prop)
    
    names = prop.Value;
    defaultProps = this.getDefaultLineProperties;
    lineProperties = repmat(defaultProps, length(names), 1);
    for indx = 1:length(names)
        lineProperties(indx).DisplayName = names{indx};
    end
    
    % Build the structure for the LineProperties.
    lineProperties = fixLineProperties(hPropDb, lineProperties, ...
        defaultProps, 'LineVisibilities', 'Visible');
    
    lineProperties = fixLineProperties(hPropDb, lineProperties, ...
        defaultProps, 'LineMarkers', 'Marker');

    lineProperties = fixLineProperties(hPropDb, lineProperties, ...
        defaultProps, 'LineColors', 'Color');

    for indx = 1:numel(lineProperties)
        if ischar(lineProperties(indx).Color) && numel(lineProperties(indx).Color) > 1
            lineProperties(indx).Color = evalin('base', lineProperties(indx).Color);
        end
    end
    
    lineProperties = fixLineProperties(hPropDb, lineProperties, ...
        defaultProps, 'LineStyles', 'LineStyle');
    
    % Remove the old properties.
    hPropDb.remove(hPropDb.findProp('LineNames'));
    hPropDb.remove(hPropDb.findProp('LineVisibilities'));
    hPropDb.remove(hPropDb.findProp('LineMarkers'));
    hPropDb.remove(hPropDb.findProp('LineColors'));
    hPropDb.remove(hPropDb.findProp('LineStyles'));
    
    % If we have a LineProperties property, use it and make sure that we do
    % not cause an update to fire.  If we do not, make a new one.
    prop = hPropDb.findProp('LineProperties');
    if isempty(prop)
        hPropDb.add('LineProperties', 'mxArray', lineProperties);
    else
        setPropValue(this, 'LineProperties', lineProperties, true);
    end
end

% -------------------------------------------------------------------------
function lineProperties = fixLineProperties(hPropDb, lineProperties, ...
    defaultProperties, oldPropName, newPropName)

values = uiservices.pipeToCell(hPropDb.findProp(oldPropName).Value);

% Preallocate the LineProperties out to the number of elements needed.
lineProperties(end+1:numel(values)) = defaultProperties;
for indx = 1:numel(values)
    if ~isempty(values{indx})
        lineProperties(indx).(newPropName) = values{indx};
    end
end

% [EOF]
