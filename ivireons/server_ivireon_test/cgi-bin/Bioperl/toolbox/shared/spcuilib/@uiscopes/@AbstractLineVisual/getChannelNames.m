function channelNames = getChannelNames(this)
%GETCHANNELNAMES Get the channelNames.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/01/25 22:47:26 $

lineProperties = getPropValue(this, 'LineProperties');

if isempty(lineProperties)
    channelNames = cell(numel(this.Lines), 1);
else
    channelNames = {lineProperties.DisplayName};
end

% channelNames = getPropValue(this, 'LineNames');

% Any element that is empty, replace with the default string of 'Channel #'
for indx = 1:numel(channelNames)
    if isempty(channelNames{indx})
        channelNames{indx} = sprintf('Channel %d', indx);
    end
end

% If we don't have elements up to the number of lines, add the default.
for indx = length(channelNames)+1:numel(this.Lines)
    channelNames{indx} = sprintf('Channel %d', indx);
end

% Remove any extra channel names
channelNames(numel(this.Lines)+1:end) = [];

% [EOF]
