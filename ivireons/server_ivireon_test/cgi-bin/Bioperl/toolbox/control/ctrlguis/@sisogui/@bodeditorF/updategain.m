function updategain(Editor)
% Lightweight plot update when modifying the feedforward gain.

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:50:53 $

% RE: Assumes gain does not change sign
if strcmp(Editor.EditMode,'off') || strcmp(Editor.Visible,'off')
   % Editor is inactive
   return
elseif strcmp(Editor.ClosedLoopVisible,'on')
   % Full update (need to recompute closed-loop response
   update(Editor)
end

% Only update plot of feedforward compensator
C = Editor.EditedBlock;
GainC = getZPKGain(C,'mag');

% Compute new filter mag data = filter gain * normalized filter response
MagData = unitconv(GainC*Editor.Magnitude,'abs',Editor.Axes.YUnits{1});
XFocus = getfocus(Editor);

% Update mag plot vertical position
set(Editor.HG.BodePlot(1),'Ydata',MagData); 
% REVISIT: Update XlimIncludeData of BodePlot(1)
set(Editor.HG.BodeShadow(1),'YData',...
   MagData(Editor.Frequency>=XFocus(1) & Editor.Frequency<=XFocus(2)))

% Update pole/zero positions in mag plot
Editor.interpy(MagData);

% Update axis limits
updateview(Editor)