function rmwave(this, h)
%RMWAVE  Removes a waveform from the current wave plot.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:28:33 $

% Validate input argument
if ~ishandle(h)
    ctrlMsgUtils.error('Controllib:plots:rmwave1','wavepack.waveplot/rmwave')
end

% Find position of @waveform object
idx = find(this.Waves == h);

% Delete @waveform object
if ~isempty(idx)
  delete(this.Waves(idx));
  this.Waves = this.Waves([1:idx-1, idx+1:end]);
end

% Redraw plot
draw(this)
