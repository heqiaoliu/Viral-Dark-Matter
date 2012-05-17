function updatelims(Editor)
%UPDATELIMS  Resets axis limits.

%   Author(s): P. Gahinet, Bora Eryilmaz
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.22.4.3 $ $Date: 2009/05/23 07:53:18 $

% Return if Editor is inactive 
if strcmp(Editor.EditMode, 'off') || Editor.SingularLoop
   return
end
Axes = Editor.Axes;
PlotAxes = getaxes(Axes);
AutoX = strcmp(Axes.XlimMode,'auto');

% Enforce limit modes at HG axes level
set(PlotAxes,'XlimMode',Axes.XlimMode{1},'YlimMode',Axes.YlimMode{1})

% Acquire limits (automatically includes other objects such as constraints 
% and compensator poles and zeros)
Xlim = get(PlotAxes,'XLim');
Ylim = get(PlotAxes,'YLim');

% Adjust limits if grid is on (show full 180 degree sections)
PhaseExtent = Editor.xyextent('phase');
if strcmp(Axes.Grid,'on')
   if AutoX
      Xlim = niclims('phase', Xlim, Axes.XUnits);
      PhaseExtent = niclims('phase', PhaseExtent, Axes.XUnits);
      if hasDelay(Editor.getL)
          % Limit windings when system has delays to N revolutions or
          % value set by highest frequency tunable pole/zero
          effectivePi = unitconv(pi,'rad',Axes.XUnits);
          maxgap = 10*effectivePi;
          if (Xlim(2)-Xlim(1))> maxgap
             Xlim(1) = Xlim(1) + 2*effectivePi* floor(abs((Xlim(2)- Xlim(1) - maxgap))/ (2*effectivePi));
             % Determine if phase should be extended based on tunable
             % dynamics
             L = Editor.getL;
             [Z,P] = getTunedPZ(L);
             ZP = [Z(:);P(:)];
             if ~isempty(ZP)
                 wn = max(damp(ZP,L.Ts));
                 if L.Ts
                     wn = min(wn,pi/L.Ts);
                 end
                 MinPhaseZP = min(Editor.Phase(1:find(wn<Editor.Frequency,1)));
                 if unitconv(MinPhaseZP,'deg',Axes.XUnits)<Xlim(1)
                    Xlim(1) = unitconv(MinPhaseZP,'deg',Axes.XUnits);% unitconv(MinPhaseZP,'rad',Axes.XUnits);
                 end
             end
          end

         
      end
   end   
   if strcmp(Axes.YlimMode,'auto')
      Ylim = niclims('mag', Ylim, 'dB');
   end
end

% Adjust phase ticks for units = degree
set(PlotAxes, 'XtickMode', 'auto')
if strcmpi(Axes.XUnits, 'deg')
   set(PlotAxes, 'Xlim', Xlim)
   Xticks = get(PlotAxes, 'XTick');
   if AutoX
      % Auto mode. Adjust limits taking into account true extent of phase data 
      [NewTicks, Xlim] = phaseticks(Xticks, Xlim, PhaseExtent);
   else
      % Fixed limit mode
      NewTicks = phaseticks(Xticks, Xlim);
   end
   set(PlotAxes, 'XTick', NewTicks)
end

% All low-level limit modes are manual 
set(PlotAxes, 'Xlim', Xlim, 'Ylim', Ylim)
