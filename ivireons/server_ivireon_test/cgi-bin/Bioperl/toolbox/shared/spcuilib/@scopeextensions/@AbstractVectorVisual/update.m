function update(this)
%UPDATE   Update the vector visual.

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/03/31 18:41:16 $

source = this.Application.DataSource;

data = getData(source);
if isempty(data) || isempty(data(1).values)
    return;
end

frameData = reshape(data.values, data.dimensions');

hAxes = get(this, 'Axes');
hLine = get(this, 'Lines');

% Remove any deleted lines.
hLine = hLine(ishghandle(hLine));

nBuffers = this.DisplayBuffer;

if nBuffers > 1
    oldData = get(this, 'OldDataBuffer');

    % Add the new data to the end of the buffer
    oldData{end+1} = frameData;

    % Remove any data that has fallen out of the buffer.
    oldData(1:end-nBuffers) = [];

    frameData = oldData{1};
    for indx = 2:length(oldData)
        frameData = [frameData; oldData{indx}]; %#ok
    end

    set(this, 'OldDataBuffer', oldData);
end

% If we do not have an axes to render to, return after caching the old data
% so that we can use it if an axes becomes available.
if ~ishghandle(hAxes)
    return;
end

[lBuffer nChannels] = size(frameData);

frameData = reshape(frameData, lBuffer, nChannels);

xData = calculateXData(this, lBuffer);

xData = xData*this.Multiplier;

if length(hLine) == nChannels
    
    for indx = 1:nChannels
        
        yData = getYData(this, frameData, indx);
        set(hLine(indx), 'XData', xData, 'YData', yData);
    end
else

    % Delete any old lines that are still present.
    delete(hLine);

    % Create one line for each channel.
    for indx = 1:nChannels
        
        yData = getYData(this, frameData, indx);
        if isempty(yData)
            continue;
        end
        hLine(indx) = line(xData, yData, 'Parent', hAxes, 'EraseMode', 'XOR');
    end
    
    % Make sure we trim out any unneeded handles that might be existing
    % from previous update calls.
    hLine(nChannels+1:end) = [];
    set(this, 'Lines', hLine);
    
    % Make sure that the new lines match the properties specified for them.
    updateLineProperties(this);
    
    % Make sure that the legend now has the correct number of channels.
    updateLegend(this);
    
    % Update the XAxis Limits for "calculate xaxis limits"
    updateXAxisLimits(this);
end
drawnow expose

% -------------------------------------------------------------------------
function yData = getYData(this, frameData, indx)

% Apply the YScaling if there is any.  This will convert to db if
% necessary.
if isempty(this.YScalingFcn)
    yData = frameData(:, indx);
else
    yData = this.YScalingFcn(frameData(:, indx));
end

% Apply the XTransform.  This will convert [0...Fs] to
% [-Fs/2...Fs/2].
if ~isempty(this.XTransformFcn)
    yData = this.XTransformFcn(yData);
end

% [EOF]
