function applystyle(this,Style,RowIndex,ColumnIndex,RespIndex)
%APPLYSTYLE  Applies line styles to @nyquistview.

%  Author(s): John Glass, P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:22:35 $
Curves = cat(3,this.PosCurves,this.NegCurves);
Arrows = cat(3,this.PosArrows,this.NegArrows);
for ct1 = 1:size(Curves,1)
   for ct2 = 1:size(Curves,2)
      [Color,LineStyle,Marker] = getstyle(Style,RowIndex(ct1),ColumnIndex(ct2),RespIndex);
      set(Curves(ct1,ct2,:),'Color',Color,'LineStyle',LineStyle,...
         'Marker',Marker,'LineWidth',Style.LineWidth)
      set(Arrows(ct1,ct2,:),'FaceColor',Color,'EdgeColor',Color)
   end
end