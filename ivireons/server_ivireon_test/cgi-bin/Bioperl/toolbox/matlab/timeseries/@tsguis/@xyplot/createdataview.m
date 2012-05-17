function [data, view, dataprops] = createdataview(this, Nresp)

% Copyright 2004 The MathWorks, Inc.

%% Overloaded createView which creates tsgui sublasses of specview and
%% wavepack.freqdata

for ct = Nresp:-1:1
  % Create @respdata objects
  data(ct,1) = tsguis.xydata;
  
  % Create @respview objects
  view(ct,1) = tsguis.xyview;
  view(ct).AxesGrid = this.AxesGrid;
end

% Return list of data-related properties of data object
dataprops = [data(1).findprop('XData'); data(1).findprop('YData')];
