function Range = xyextent(Editor, type)
%XYEXTENT  Finds X or Y extent of visible data.

%   Author(s): P. Gahinet, Bora Eryilmaz
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.10.4.3 $ $Date: 2006/06/20 20:02:54 $

PlotAxes = getaxes(Editor.Axes);

% Get comp. gain (zpk gain magnitude)
C = Editor.EditedBlock;
Gain = getZPKGain(C,'mag'); 

[VisX,VisY] = getConstraintBounds(Editor);
 
switch type
case 'mag'
   Lims = 10.^(get(PlotAxes, 'Ylim')/20);  % abs limits
   Lims = Lims/Gain;
   VisData = Editor.Magnitude(Editor.Magnitude >= Lims(1) & Editor.Magnitude <= Lims(2));
   VisData = [VisData; VisY];
case 'phase'
   Lims = unitconv(get(PlotAxes, 'Xlim'), Editor.Axes.XUnits, 'deg');
   VisData = Editor.Phase(Editor.Phase >= Lims(1) & Editor.Phase <= Lims(2));
   VisData = [VisData; VisX];
end

if length(VisData)>1
   Range = [min(VisData),max(VisData)]; % in abs or deg units !
else
   % Plot jumps over X or Y band
   Range = Lims;
end


function [VisX,VisY] = getConstraintBounds(Editor)
% find extents of constraints
Constraints = Editor.findconstr;
ConstrExtents = zeros(0,4);
for ct =1:length(Constraints)
    ConstrExtents = [ConstrExtents;Constraints(ct).extent];
end
VisX = [min(ConstrExtents(:,1));max(ConstrExtents(:,2))];
VisY = [min(ConstrExtents(:,3));max(ConstrExtents(:,4))];