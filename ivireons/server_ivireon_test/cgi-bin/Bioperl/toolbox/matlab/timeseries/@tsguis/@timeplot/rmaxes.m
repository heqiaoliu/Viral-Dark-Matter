function rmaxes(h,pos)
%% Removes axes at the specified position

%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2006/06/27 23:11:26 $

%% Check that there are enough axes to remove
if length(h.ChannelName)<2
    errordlg('The number of axes cannot be reduced to zero',...
        'Time Series Tools','modal')
    return
end

%% Check that the axes to be removed are empty
for k=1:length(h.Waves)
    if ~isempty(intersect(h.Waves(k).RowIndex,pos))
         ButtonName = questdlg(sprintf('Selected axes contain %s. Continue?', ...
             h.Waves(k).DataSrc.Timeseries.Name), ...
                       'Time Series Tools', ...
                       'OK','Cancel','Cancel');
         ButtonName = xlate(ButtonName);
         if strcmp(ButtonName,xlate('Cancel'))
             return
         end
         % Remove wave
         h.rmwave(h.Waves(k));
    end
end

%% Define the new channel names 
newChannelName = h.ChannelName;
newChannelName(pos) = [];

%% Resize the grid - retaining the scales of axes in manual
cacheYlimMode = h.AxesGrid.YlimMode;
cacheYlimScale = h.AxesGrid.getylim;
cacheYlimMode(pos) = [];
cacheYlimScale(pos) = [];
h.resize(newChannelName);
for k=1:h.AxesGrid.size(1)
    if strcmpi(cacheYlimMode{k},'manual')
        h.AxesGrid.setylim(cacheYlimScale{k},k);
    end
end

%% Announce the change to the axestable listenrs
h.AxesGrid.send('viewchanged')
