function resize(this, NewChannelNames)
% RESIZE Reconfigures plot given new set of collective channel names.
% Overloaded so as not to call localize on each waveform which
% automatically redistributes all wave data to rows 1:n. Also
% Re-initializes Event dataviews to span additonal axes. Also caches
% the xlimmode.

% Author:  
% Revised: 
% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2008/12/29 02:11:40 $

AxGrid = this.AxesGrid;
OldSize = AxGrid.Size;
RowSize = length(NewChannelNames);

% Resize if necessary
NewSize = [RowSize 1 OldSize(3:end)];
if ~isequal(NewSize, OldSize)
  % Axes grid needs to be resized
  % 1) Reparent all responses to first axes (other axes may be deleted
  %    when downsizing)
  
  % Cache xlim mode in case its in manual
  xlimmodecache = AxGrid.xlimmode;
  
  Axes = getaxes(AxGrid);
  Axes = Axes(ones(OldSize));
  for r = allwaves(this)'
    r.reparent(Axes)
  end
  
  % 2) Resize the axes grid
  AxGrid.Size = NewSize;
  
  % 3) Tatoo new HG axes
  ax = allaxes(this);
  for ct = 1:prod( size(ax) )
    setappdata( ax(ct), 'WaveRespPlot', this )
  end
  
  % 4) Update plot's I/O-related properties (no listeners to prevent
  %    errors due to partial update)
  this.Listeners.setEnabled(false);
  limmgrcache = this.AxesGrid.LimitManager;
  this.AxesGrid.LimitManager = 'off';
  localLocalize(this,NewChannelNames)
  this.ChannelName = NewChannelNames;
  if all( NewSize([1 2]) == 1 )
    this.ChannelGrouping = 'none';
  end
  this.Listeners.setEnabled(true);
  
  % 5) Update plot labels
  rclabel(this)
  
  % Link xlims on axes for smooth linked panning
  this.xaxeslink = linkprop(AxGrid.getaxes,'xlim');
  
  % Restore xlimmode and limit manager
  AxGrid.xlimmode = xlimmodecache;
  this.AxesGrid.LimitManager = limmgrcache;
  
else
  % Just updates I/O names (cf. geck 84020)
  localLocalize(this,NewChannelNames)
  this.ChannelName = NewChannelNames;
end

% Relocate responses in axes grid
for r = allwaves(this)'
%   localize(r)
    r.reparent;
end

function localLocalize(this,NewChannelNames)

%% Loop through each wave, if the channel name has changed try to find its
%% new position. If this fails just assign it to 1
for k=1:length(this.waves)
    for j=1:length(this.waves(k).RowIndex)
        if ~(this.waves(k).RowIndex(j)<=length(NewChannelNames) && ...
               strcmp(this.ChannelName{this.waves(k).RowIndex(j)},...
               NewChannelNames{this.waves(k).RowIndex(j)}))
           ind = find(strcmp(this.ChannelName{this.waves(k).RowIndex(j)},NewChannelNames));
           if ~isempty(ind)
               this.waves(k).RowIndex(j) = ind(1);
           else
               this.waves(k).RowIndex(j) = 1;
           end    
        end
    end
end