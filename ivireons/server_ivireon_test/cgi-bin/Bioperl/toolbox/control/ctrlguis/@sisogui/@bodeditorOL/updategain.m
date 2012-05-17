function updategain(this)
% Lightweight plot update when modifying the gain of locally edited
% compensator

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $  $Date: 2010/05/10 16:59:16 $

% RE: Assumes gain does not change sign
if strcmp(this.EditMode,'off') || strcmp(this.Visible,'off') || this.SingularLoop
    % this is inactive
    return
end
C = this.EditedBlock;

% Compute new mag data = loop gain * normalized open-loop gain
GainMag = getZPKGain(C,'mag');
MagData = unitconv(GainMag*this.Magnitude,'abs',this.Axes.YUnits{1});

% Update mag plot vertical position
set(this.HG.BodePlot(1),'Ydata',MagData); 
% REVISIT: Update XlimIncludeData
XFocus = getfocus(this);
set(this.HG.BodeShadow(1),'YData',MagData(this.Frequency >= XFocus(1) & this.Frequency <= XFocus(2)))

% Update Uncertain bound
if this.isMultiModelVisible
    this.UncertainBounds.setData(GainMag*this.UncertainData.Magnitude,...
        this.UncertainData.Phase,this.UncertainData.Frequency)
end

% Update pole/zero positions in mag plot
this.interpy(MagData);

% Update margins
showmargin(this)

% Update axis limits (also updates margin display)
updateview(this)