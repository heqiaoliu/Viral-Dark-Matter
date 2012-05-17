function draw(this, Data,NormalRefresh)
%DRAW  Draws Bode response curves.
%
%  DRAW(VIEW,DATA) maps the response data in DATA to the curves in VIEW.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:22:12 $

AxGrid = this.AxesGrid;

% Sizes and unit conversions
[Ny, Nu] = size(this.Curves);
Mag   = unitconv(Data.Magnitude, Data.MagUnits,   'dB');
Phase = unitconv(Data.Phase,     Data.PhaseUnits, AxGrid.XUnits);

if strcmp(this.UnwrapPhase, 'off')
  Pi = unitconv(pi, 'rad', AxGrid.XUnits);
  Phase = mod(Phase+Pi,2*Pi) - Pi;
end

% Phase Matching
doComparePhase = strcmp(this.ComparePhase.Enable, 'on');
if doComparePhase
    ax = AxGrid.getaxes; % Revisit
    h = gcr(ax(1));
    Freq = unitconv(Data.Frequency,Data.FreqUnits,h.FrequencyUnits);
    idx = find(Freq>this.ComparePhase.Freq,1,'first');
    if isempty(idx)
        idx = 1;
    end
    Pi = unitconv(pi,'rad',AxGrid.XUnits);
end


% Redraw curves
for ct = 1:Ny*Nu
    % REVISIT: remove conversion to double (UDD bug where XOR mode ignored)
    if ~isempty(Mag)
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
        set(double(this.Curves(ct)), 'XData', Phase(:,ct), 'YData', Mag(:,ct));
    else
        set(double(this.Curves(ct)), 'XData', [], 'YData', []);
    end
end