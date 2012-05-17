function draw(this, Data, NormalRefresh)
%DRAW  Draws Bode response curves.
%
%  DRAW(VIEW,DATA) maps the response data in DATA to the curves in VIEW.

%  Author(s): P. Gahinet
%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:20:27 $

AxGrid = this.AxesGrid;
Ts = Data.Ts;
if Ts~=0
   nf = unitconv(pi/abs(Ts),'rad/sec',AxGrid.XUnits);
end

% Input and output sizes
[Ny, Nu] = size(this.MagCurves);
Freq = unitconv(Data.Frequency,Data.FreqUnits,AxGrid.XUnits);
Mag = unitconv(Data.Magnitude,Data.MagUnits,AxGrid.YUnits{1});
Phase = unitconv(Data.Phase,Data.PhaseUnits,AxGrid.YUnits{2});

% Eliminate zero frequencies in log scale
if strcmp(AxGrid.Xscale{1},'log')
  idxf = find(Freq>0);
  Freq = Freq(idxf);
  if ~isempty(Mag)
    Mag = Mag(idxf,:);
  end
  if ~isempty(Phase)
    Phase = Phase(idxf,:);
  end
end

% Mag curves
for ct = 1:Ny*Nu
   % REVISIT: remove conversion to double (UDD bug where XOR mode ignored)
   set(double(this.MagCurves(ct)), 'XData', Freq, 'YData', Mag(:,ct));
end

% Mag Nyquist lines (invisible to limit picker)
if Ts==0
   YData = [];  XData = [];
else
   YData = unitconv(infline(0,Inf),'abs',AxGrid.YUnits{1});
   XData = nf(:,ones(size(YData)));
end
set(this.MagNyquistLines,'XData',XData,'YData',YData)

% Phase curves
if isempty(Phase)
  set([this.PhaseCurves(:);this.PhaseNyquistLines(:)], ...
      'XData', [], 'YData', [])
else
  if strcmp(this.UnwrapPhase, 'off')
    Pi = unitconv(pi,'rad',AxGrid.YUnits{2});
    Phase = mod(Phase+Pi,2*Pi) - Pi;
  end
  
  % Phase Matching
  doComparePhase = strcmp(this.ComparePhase.Enable, 'on');
  if doComparePhase
      idx = find(Freq>this.ComparePhase.Freq,1,'first');
      if isempty(idx)
          idx = 1;
      end
      Pi = unitconv(pi,'rad',AxGrid.YUnits{2});
  end
  
  
  for ct = 1:Ny*Nu
     % Phase Matching
     if doComparePhase
         % If compare Phase(idx,ct) is nan find nearest phase which is not
         % nan to do comparison. Otherwise the phase response will become
         % nan.
         if isnan(Phase(idx,ct))
             [junk, nidx] = sort(abs(Freq-Freq(idx)));
             nidx = nidx(find(~isnan(Phase(nidx,ct)),1,'first'));
             if ~isempty(nidx)
                 idx = nidx;
             end
         end
         n = round(abs(Phase(idx,ct)-this.ComparePhase.Phase)/(2*Pi));
         Phase(:,ct) = Phase(:,ct)-sign(Phase(idx,ct)-this.ComparePhase.Phase)*n*2*Pi;
     end
     % REVISIT: remove conversion to double (UDD bug where XOR mode ignored)
     set(double(this.PhaseCurves(ct)), 'XData', Freq, 'YData', Phase(:,ct));
  end
  % Phase Nyquist lines (invisible to limit picker)
  if Ts==0
     YData = [];  XData = [];
  else
     YData = infline(-Inf,Inf);
     XData = nf(:,ones(size(YData)));
  end
  set(this.PhaseNyquistLines,'XData',XData,'YData',YData)
end