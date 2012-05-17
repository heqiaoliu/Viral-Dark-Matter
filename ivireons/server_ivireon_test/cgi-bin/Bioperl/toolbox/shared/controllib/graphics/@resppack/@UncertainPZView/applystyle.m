function applystyle(this,Style,RowIndex,ColumnIndex,RespIndex)
%APPLYSTYLE  Applies line style to @view objects.
%
%  Applies line style to all gobjects making up the @view instance
%  (as returned by GHANDLES).

%  Author(s): John Glass
%  Copyright 1986-2010 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2010/05/10 17:37:28 $

% Line width adjustment
LW = Style.LineWidth;
pMS = ceil(6.5+LW);  % pole marker size
zMS = ceil(5.5+LW);

[Ny,Nu] = size(this.UncertainPoleCurves);
for ct1 = 1:Ny
   for ct2 = 1:Nu
      Color = getstyle(Style,RowIndex(ct1),ColumnIndex(ct2),RespIndex);
      Color = localGetColor(Color);
      set(this.UncertainPoleCurves(ct1,ct2,:),'Color',Color,...
         'LineWidth',LW,'MarkerSize',pMS)
      set(this.UncertainZeroCurves(ct1,ct2,:),'Color',Color,...
         'LineWidth',LW,'MarkerSize',zMS)
   end
end



function Color = localGetColor(Color)

hsvcolor = rgb2hsv(Color);
Color = hsv2rgb(hsvcolor+[0,-.8,0]);


