function updatelims(this)
%UPDATELIMS  Custom limit picker.
%
%  UPDATELIMS(H) implements a custom limit picker for Bode plots. 
%  This limit picker
%     1) Computes an adequate X range from the data or source
%     2) Computes common Y limits across rows for axes in auto mode.
%     3) Adjusts the phase ticks (for phase in degrees)

%  Author(s): P. Gahinet, Bora Eryilmaz
%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:20:22 $

AxGrid = this.AxesGrid;
% Update X range by merging time Focus of all visible data objects.
ax = getaxes(AxGrid,'2d');
AutoX = strcmp(AxGrid.XLimMode,'auto');
if any(AutoX)
  XRange = getfocus(this);
  % RE: Do not use SETXLIM in order to preserve XlimMode='auto'
  set(ax(:,AutoX),'Xlim',XRange)
end

% Update Y limits
AxGrid.updatelims('manual',[])

% Set minimum magnitude limits for ylim with auto if Min gain lvl is enabled
if isfield(this.Options,'MinGainLimit') && strcmp(this.Options.MinGainLimit.Enable,'on')
    LocalMinMag(this);
end
 


% Fine tune phase limits/ticks
if strcmp(this.PhaseVisible,'on')
  LocalAdjustPhaseTicks(this);
end

%------------------------- Local Functions -----------------------------
function LocalAdjustPhaseTicks(h)
% Adjust phase tick labels for degrees (H = @respplot handle)
% Data visibility
DataVis = datavis(h);
PhaseVis = DataVis(:,:,2);
if ~any(PhaseVis(:))
   return
end
% Phase axes and their Y limit mode
ax = getaxes(h);
PhaseAxes = ax(:,:,2);
YLimMode = h.AxesGrid.YLimMode;
if ischar(YLimMode)
   AutoY = repmat(strcmp(YLimMode,'auto'),[size(PhaseAxes,1) 1]);
else
   AutoY = strcmp(YLimMode(2:2:end),'auto');  % phase rows in auto mode
end
% Compute phase extent
DataVis(:,:,1) = false;
Yextent = LocalGetPhaseExtent(h,DataVis);
if any(strcmp(h.IOGrouping,{'all','outputs'}))
   % Row grouping
   PhaseAxes = PhaseAxes(1,:);
   AutoY = any(AutoY);
   Yextent = cat(1,Yextent{:});
   Yextent = {[min(Yextent(:,1)) , max(Yextent(:,2))]};
end

% Leftmost visible column of phase axes
viscol = find(any(DataVis(:,:,2)));
viscol = viscol(1);  

% Adjust ticks
set(PhaseAxes(:,viscol),'YtickMode','auto') % release y ticks 
if all(strcmp(h.AxesGrid.YUnits(2:2:end),'deg'))
   for ct=1:size(PhaseAxes,1)
      YlimP = get(PhaseAxes(ct,viscol),'Ylim');
      Yticks = get(PhaseAxes(ct,viscol),'YTick');
      if isempty(Yextent{ct})
         % No data
         NewTicks = Yticks;
      elseif AutoY(ct)
         % Auto mode
         % REVISIT: must include findobj(PhaseAxes,'Tag','MarginVline'); --> margin V lines
         [NewTicks,NewLims] = phaseticks(Yticks,YlimP,Yextent{ct});
         YlimP = NewLims + [-0.01 0.01] * (NewLims(2)-NewLims(1));
         set(PhaseAxes(ct,:),'Ylim',YlimP);
      else
         % Fixed limit mode
         NewTicks = phaseticks(Yticks,YlimP);
      end
      set(PhaseAxes(ct,:),'YTick',NewTicks)
   end
end


function Yextent = LocalGetPhaseExtent(h,DataVis)
% Computes spread of phase values
hy = zeros(size(DataVis,1),0,2);
% REVISIT: use FIND
for r=h.Responses(strcmp(get(h.Responses,'Visible'),'on'),:)'
   % For each visible response plots
   hy = cat(2, hy , r.yextent(DataVis));
end
Yextent = LocalGetExtent(hy(:,:,2));


function Yextent = LocalGetExtent(Yhandles)
% Computes Y extent spanned by handles YHANDLES for current X limits.
% REVISIT: This should be an HG primitive!!
nr = size(Yhandles,1);
Yextent = cell(nr,1);
for ctr=1:nr
   Yh = Yhandles(ctr,:);
   Yh = Yh(ishandle(Yh));
   Yx = zeros(0,2);
   for ctc=1:length(Yh)
      Xdata = get(Yh(ctc),'Xdata');
      Ydata = get(Yh(ctc),'Ydata');
      XRange = get(ancestor(Yh(ctc),'axes'),'Xlim');
      Ydata = Ydata(Xdata>=XRange(1) & Xdata<=XRange(2));
      Yx = [Yx ; [min(Ydata) , max(Ydata)]];
      Yx = [min(Yx(:,1)) , max(Yx(:,2))];
   end
   Yextent{ctr} = Yx;
end


function LocalMinMag(this)
% Sets Lower magnitude limits for when Minimum gain lvl is set

ax = getaxes(this.Axesgrid);
magax = ax(:,:,1);
AutoY = strcmp(this.AxesGrid.YLimMode,'auto');
AutoY = AutoY(1:2:end);
for ct = 1:length(AutoY)
    if AutoY(ct)
        curylim = get(magax(ct,:),{'Ylim'});
        for ct2 = 1:length(curylim)
            curylim{ct2}(1)= this.Options.MinGainLimit.MinGain;
            if curylim{ct2}(1)>=curylim{ct2}(2)
                % Case when response upper auto limit is less then 
                % MinGain limit
                curylim{ct2}(2) = curylim{ct2}(1) + 10;
            end
            set(magax(ct,ct2),'Ylim',curylim{ct2})
        end
    end
end