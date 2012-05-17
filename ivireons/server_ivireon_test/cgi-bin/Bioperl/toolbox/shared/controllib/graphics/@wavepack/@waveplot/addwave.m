function w = addwave(this, varargin)
%ADDWAVE  Adds a new wave to a wave plot.
%
%   W = ADDWAVE(WAVEPLOT,CHANNELINDEX,NWAVES) adds a new wave W
%   to the wave plot WAVEPLOT.  The index vector CHANNELINDEX
%   specify the wave position in the axes grid, and NWAVES is
%   the number of waves in W (default = 1).
%
%   W = ADDWAVE(WAVEPLOT,DATASRC) adds a wave W that is linked to the 
%   data source DATASRC.

%  Author(s): P. Gahinet
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:28:14 $

if ~isempty(varargin) & isnumeric(varargin{1})
   % Size check
   if max(varargin{1})>this.AxesGrid.Size(1)
       ctrlMsgUtils.error('Controllib:plots:addwave1')
   end 
   % Insert column index
   varargin = [varargin(1) {1} varargin(2:end)];
end

% Add new wave
try
   w = addwf(this,varargin{:});
catch ME
   throw(ME)
end

% Resolve unspecified name against all existing "untitledxxx" names
setDefaultName(w,this.Waves)

% Add to list of waves
this.Waves = [this.Waves ; w];