function xfocus = getfocus(this)
%GETFOCUS  Computes optimal X limits for wave plot 
%          by merging Focus of individual waveforms.

%  Author(s):  
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.6.5 $ $Date: 2005/12/15 20:56:52 $

% Collect time Focus for all visible MIMO responses
xfocus = [];
% Upper limit imposed by caching large data. In this case the focus will
% span the interval earliest time to end time of the time first large time
% series
upperCacheLim = inf;
for rct = allwaves(this)'
  % For each visible response...
  if rct.isvisible
    thisfocus = {unitconv(get(rct.Data,'Focus'),rct.Data.FreqUnits,...
        this.axesgrid.xunits)};
    xfocus = [xfocus; thisfocus];
  end
  % Find any time series longer than 5000 samples
  v = tsguis.tsviewer;
  if length(rct.Data.Frequency)>v.MaxPlotLength
      upperCacheLim = min(upperCacheLim,rct.Data.Frequency(end));
  end
end

% Merge into single focus
xfocus = LocalMergeFocus(xfocus);
if length(xfocus)>=2
    xfocus(2) = min(xfocus(2),upperCacheLim);
end

% Round it up
% REVISIT: should depend on units.
% Return something reasonable if empty.
if isempty(xfocus)
  xfocus = [0 1];
end


% ----------------------------------------------------------------------------%
% Purpose: Merge all ranges
% ----------------------------------------------------------------------------%
function focus = LocalMergeFocus(Ranges)
% Take the union of a list of ranges
focus = zeros(0,2);
for ct = 1:length(Ranges)
  focus = [focus ; Ranges{ct}];
  focus = [min(focus(:,1)) , max(focus(:,2))];
end
