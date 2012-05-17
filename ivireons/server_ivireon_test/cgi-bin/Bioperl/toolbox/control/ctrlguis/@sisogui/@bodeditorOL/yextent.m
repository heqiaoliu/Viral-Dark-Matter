function Range = yextent(Editor,type)
%YEXTENT  Finds Y extent of visible data.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.16.4.3 $  $Date: 2005/12/22 17:42:36 $

% Current X limits (in rad/sec)
PlotAxes = getaxes(Editor.Axes);
Xlims = unitconv(get(PlotAxes(1),'Xlim'),Editor.Axes.XUnits,'rad/sec');
W = Editor.Frequency;

% Find minimal non-empty coverage of Xlims
idxs = max([1;find(W<Xlims(1))]);
idxe = min([find(W>Xlims(2));length(W)]);

switch type
case 'mag'
   VisData = Editor.Magnitude(idxs:idxe);
case 'phase'
   VisData = Editor.Phase(idxs:idxe);
   phsMrgn = Editor.HG.PhaseMargin;
   if ~isempty(phsMrgn),
      % Include phase margin line
      VisData = [VisData ; reshape(get(phsMrgn.vLine,'YData'),[2 1])];
   end
end
Range = [min(VisData) , max(VisData)];
   
