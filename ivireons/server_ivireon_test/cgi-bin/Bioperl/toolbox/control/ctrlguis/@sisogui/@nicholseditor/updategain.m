function updategain(this)
%UPDATEGAINC  Lightweight plot update when modifying the loop gain.

%   Author(s): Bora Eryilmaz
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.4 $  $Date: 2010/05/10 16:59:23 $

% Return if this is inactive.
if strcmp(this.EditMode, 'off') || strcmp(this.Visible, 'off') || this.SingularLoop
  return
end
C = this.EditedBlock;

% Compute new mag data = loop gain * normalized open-loop gain
Gain = getZPKGain(C,'mag');  % abs zpk gain
MagData = mag2db(Gain * this.Magnitude);
PhaseData = unitconv(this.Phase, 'deg', this.Axes.XUnits);

% Update mag plot vertical position
set(this.HG.NicholsPlot, 'Ydata', MagData); 
% REVISIT: Update XlimIncludeData
InFocus = (this.Frequency>=this.FreqFocus(1) & this.Frequency<=this.FreqFocus(2));
set(this.HG.NicholsShadow, 'YData', MagData(InFocus))

% Update Uncertain bound
if this.isMultiModelVisible
    this.UncertainBounds.setData(Gain*this.UncertainData.Magnitude,...
        this.UncertainData.Phase,this.UncertainData.Frequency)
end

% Update pole/zero positions in Nichols plot (in current units)
this.interpxy(MagData, PhaseData);

% Update margins
showmargin(this)

% Update axis limits (also updates margin display)
updateview(this) 
