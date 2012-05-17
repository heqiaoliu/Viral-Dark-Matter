function draw(this,varargin)
%DRAW  (Re)draws @waveform object.
%
%  DRAW(WF) draws the waveform WF and all its dependencies.

%  Author(s): Bora Eryilmaz, P. Gahinet
%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:20:48 $

% RE: first argument = NoCheckFlag
hPlot = this.Parent;
NormalRefresh = strcmp(this.RefreshMode,'normal');

% Update the response data
if ~isempty(this.DataFcn)
   % RE: For optimal performance, DataFcn should only recompute 
   %     MIMO responses that are visible and have been cleared. 
   feval(this.DataFcn{:});
end

% Set data exception boolean to flag invalid data
this.Data.Exception = any(getsize(this.Data)~=[1 1]);

% Draw HSV chart
if this.Data.Exception
   % Invalid data: clear graphics and refresh to remove bars
   set(this.View.FiniteSV,'XData',NaN,'YData',NaN)
   refresh(this.View.FiniteSV)
   set(this.View.InfiniteSV,'XData',NaN,'YData',NaN)
   refresh(this.View.InfiniteSV)
else
   % Valid data: proceed with draw
   this.View.draw(this.Data,NormalRefresh)
end

% Limit management
if NormalRefresh
   % Issue ViewChanged event to trigger limit picker
   % RE: Ignored when @axesgrid's LimitManager is off, e.g., during @waveplot/draw
   hPlot.AxesGrid.send('ViewChanged')
   if this.Data.Exception && ...
         strcmp(hPlot.DataExceptionWarning,'on')
     ctrlMsgUtils.warning('Controllib:plots:HSVPlotMissingData')
   end
else
   % Redraw g-objects whose updating is normally tied to the 'PostLimitChanged' event
   adjustview(this,'postlim')
end
