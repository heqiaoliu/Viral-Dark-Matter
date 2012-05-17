function addaxes(h,varargin)

% Copyright 2004-2006 The MathWorks, Inc.

%% Find the number of axes to add
if nargin>=2 && ~isempty(varargin{1})
    num2add = varargin{1};
else
    num2add = 1;
end

%% Find the new set of channel names
if ~all(cellfun('isempty',h.ChannelName))
    outputNames = [h.ChannelName; repmat({' '},[num2add 1])];
else
    outputNames = [repmat({' '},[h.AxesGrid.size(1) 1])];
end

%% Cache the limit modes
xlimmode = h.AxesGrid.xlimmode;

%% Update the grid - retaining the scales of axes in manual
cacheYlimMode = h.AxesGrid.YlimMode;
cacheYlimScale = h.AxesGrid.getylim;
h.resize(outputNames);
for k=1:length(cacheYlimMode)
    if strcmpi(cacheYlimMode{k},'manual')
        h.AxesGrid.setylim(cacheYlimScale{k},k);
    end
end

%% Restore the limit modes
h.AxesGrid.xlimmode = xlimmode;

%% Customize behavior
h.setbehavior

%% Notify axesgrid listeners to update the axes table
h.AxesGrid.send('viewchanged')

    