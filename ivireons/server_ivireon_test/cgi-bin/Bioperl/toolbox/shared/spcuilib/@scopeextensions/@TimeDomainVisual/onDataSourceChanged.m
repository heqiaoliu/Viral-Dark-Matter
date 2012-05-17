function onDataSourceChanged(this)
%ONDATASOURCECHANGED React to Data Source changes.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7.4.1 $  $Date: 2010/07/13 19:33:29 $

% If we aren't rendered, we don't need to do anything here.
source = this.Application.DataSource;

% If there is no axes, no source, or the source is not valid for the
% current set up of this visual, return early as there is nothing to do.
if ~ishghandle(this.Axes) || isempty(source) || ~validateSource(this, source)
    return;
end

maxDims = getMaxDimensions(source);
sampleTimes = getSampleTimes(source);

% There is no data, cannot determine channels.
if isempty(maxDims) || isempty(sampleTimes)
    return;
end

if strcmp(getPropValue(this, 'InputProcessing'), 'FrameProcessing')
    nChannels = sum(prod(maxDims(:, 2:end), 2));
    lChannels = max(maxDims(:, 1));
else
    nChannels = sum(prod(maxDims, 2));
    lChannels = 1;
end

% Delete any lines beyond the new number of channels.
hLines = this.Lines;
delete(hLines(nChannels+1:end));
hLines(nChannels+1:end) = [];

selectBehavior = uiservices.getPlotEditBehavior('select');
for indx = 1:nChannels
    
    % Create new lines if the line vector is short or the element is no
    % longer a valid
    if length(hLines) < indx || ~ishghandle(hLines(indx))
        
        hLines(indx) = line(0, NaN, 'Parent', this.Axes, 'EraseMode', 'None');
        hgaddbehavior(hLines(indx), selectBehavior);
    else
        set(hLines(indx), 'XData', 0, 'YData', NaN);
    end
end

this.Lines = hLines;

% Update all of the line properties on any new lines we've added.
addLinePropertyMenus(this);
updateLineProperties(this);

% Reset the time and timeoffset.  These will be updated as soon as we get
% data from the scope.
this.TimeOffset = 0;
this.Time       = 0;
this.MaxDimensions = maxDims;
this.SampleTimes   = sampleTimes;
this.LengthOfChannels = lChannels;

% Make sure that the input sample time and time range are up to date.
evalAllProperties(this);

% If the number of channels changed, we need to update the legend.
updateLegend(this);

% [EOF]
