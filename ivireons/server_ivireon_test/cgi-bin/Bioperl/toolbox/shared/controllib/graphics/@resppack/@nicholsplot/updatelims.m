function updatelims(this)
%UPDATELIMS  Custom limit picker.
%
%  UPDATELIMS(H) implements a custom limit picker for Nichols plots. 
%  This limit picker
%     1) Computes common X limits across columns for axes in auto mode.
%     2) Computes common Y limits across rows for axes in auto mode.
%     3) Adjusts the phase ticks (for phase in degrees)
%     4) Adjusts the limits to show full 180 portions of the Nichols grid

%  Author(s): P. Gahinet, Bora Eryilmaz
%  Copyright 1986-2010 The MathWorks, Inc.
%  $Revision: 1.1.8.2 $ $Date: 2010/05/10 17:37:38 $

AxGrid = this.AxesGrid;

% Let HG compute the limits
updatelims(AxGrid)

% Adjust limits to accommodate Nichols chart (SISO only)
NicChartOn = (prod(AxGrid.Size)==1 & strcmp(AxGrid.Grid,'on'));
if NicChartOn
   PlotAxes = getaxes(AxGrid);
   Xlim = get(PlotAxes,'Xlim');
   Ylim = get(PlotAxes,'Ylim');
   if strcmp(AxGrid.XlimMode,'auto')
      set(PlotAxes,'Xlim',niclims('phase', Xlim, AxGrid.XUnits))
   end
   if strcmp(AxGrid.YlimMode,'auto')
       set(PlotAxes,'Ylim',niclims('mag', Ylim, AxGrid.YUnits))
   end
end

% Set minimum magnitude limits for ylim with auto if Min gain lvl is enabled
if ~isempty(this.Options) && strcmp(this.Options.MinGainLimit.Enable,'on') ...
        && isfinite(this.Options.MinGainLimit.MinGain )
    LocalMinMag(this);
end

% Adjust phase ticks
LocalAdjustPhaseTicks(this,NicChartOn)

% --------------------------------------------------------------------------- %
% Local Functions
% --------------------------------------------------------------------------- %
function LocalAdjustPhaseTicks(this,NicChartOn)
% Adjust phase tick labels for degrees (THIS = @respplot handle)
% Data visibility
AxGrid = this.AxesGrid;
DataVis = datavis(this);
if ~any(DataVis(:))
   return
end

% Phase axes and their Y limit mode
PlotAxes = getaxes(this);
XLimMode = AxGrid.XLimMode;
if ischar(XLimMode)
   AutoX = repmat(strcmp(XLimMode, 'auto'), [size(PlotAxes,2) 1]);
else
   AutoX = strcmp(XLimMode, 'auto');  % phase rows in auto mode
end

% Compute phase extent
Xextent = LocalGetPhaseExtent(this, DataVis);
if any(strcmp(this.IOGrouping, {'all', 'inputs'}))
   % Row grouping
   PlotAxes = PlotAxes(:,1);
   AutoX = any(AutoX);
   Xextent = cat(1,Xextent{:});
   Xextent = {[min(Xextent(:,1)) , max(Xextent(:,2))]};
end

% Adjust phase extent when Nichols chart is on
if NicChartOn & AutoX
  Xextent{1} = niclims('phase', Xextent{1}, AxGrid.XUnits);
end
   
% Bottom visible row
visrow = find(any(DataVis'));
visrow = visrow(end);  
set(PlotAxes(visrow,:), 'XtickMode', 'auto') % release x ticks 

% Adjust ticks
if all(strcmp(AxGrid.XUnits,'deg'))
   for ct = 1:size(PlotAxes,2)
      XlimP  = get(PlotAxes(visrow, ct), 'Xlim');
      Xticks = get(PlotAxes(visrow, ct), 'XTick');
      if isempty(Xextent{ct})
         % No data
         NewTicks = Xticks;
      elseif AutoX(ct)
         % Auto mode
         [NewTicks, XlimP] = phaseticks(Xticks,XlimP,Xextent{ct});
      else
         % Fixed limit mode
         NewTicks = phaseticks(Xticks, XlimP);
      end
      set(PlotAxes(:,ct), 'XTick', NewTicks)
      set(PlotAxes(:,ct), 'Xlim',  XlimP);
   end
end


% --------------------------------------------------------------------------- %
function Xextent = LocalGetPhaseExtent(this, DataVis)
% Computes spread of phase values
hx = zeros(0, size(DataVis,2));
for r = this.Responses(strcmp(get(this.Responses, 'Visible'), 'on'))'
   % For each visible response plots
   hx = cat(1, hx , r.xextent(DataVis));
end
Xextent = LocalGetExtent(hx(:,:,1));

%Merge phase extent of any requirements on the plot into the 1st axes
%extents.
%REVISIT: Constraints on MIMO plots
xf = getconstrfocus(this,this.AxesGrid.XUnits);
if ~isempty(xf)
   if isempty(Xextent{1})
      Xextent{1} = xf;
   else
      Xextent{1} = [min(Xextent{1}(1),xf(1)) , max(Xextent{1}(2),xf(2))];
   end
end


% --------------------------------------------------------------------------- %
function Xextent = LocalGetExtent(Xhandles)
% Computes X extent spanned by handles XHANDLES for current X limits.
% REVISIT: This should be an HG primitive!!
nc = size(Xhandles,2);
Xextent = cell(1,nc);
for ctc = 1:nc
   Xh = Xhandles(:,ctc);
   Xh = Xh(ishandle(Xh));
   Xx = zeros(0,2);
   for ctr = 1:length(Xh)
      Xdata = get(Xh(ctr),'Xdata');
      Ydata = get(Xh(ctr),'Ydata');
      YRange = get(ancestor(Xh(ctr),'axes'), 'Ylim');
      Xdata = Xdata(Ydata>=YRange(1) & Ydata<=YRange(2));
      Xx = [Xx ; [min(Xdata) , max(Xdata)]];
      Xx = [min(Xx(:,1)) , max(Xx(:,2))];
   end
   Xextent{ctc} = Xx;
end

% ------------------------------------------------------------------------%
function LocalMinMag(this)
% Sets Lower magnitude limits for when Minimum gain lvl is set

magax = getaxes(this.Axesgrid);
AutoY = strcmp(this.AxesGrid.YLimMode,'auto');
for ct = 1:length(AutoY)
    if AutoY(ct)
        curylim = get(magax(ct,:),{'Ylim'});
        for ct2 = 1:length(curylim)
            curylim{ct2}(1)=this.Options.MinGainLimit.MinGain;
            if curylim{ct2}(1)>=curylim{ct2}(2)
                % Case when response upper auto limit is less then 
                % MinGain limit
                curylim{ct2}(2) = curylim{ct2}(1) + 10;
            end
            set(magax(ct,ct2),'Ylim',curylim{ct2})
        end
    end
end
