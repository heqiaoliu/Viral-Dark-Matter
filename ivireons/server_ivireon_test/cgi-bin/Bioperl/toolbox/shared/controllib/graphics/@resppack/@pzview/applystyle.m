function applystyle(this,Style,RowIndex,ColumnIndex,RespIndex)
%APPLYSTYLE  Applies style to pole zero plot.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:23:01 $

% Line width adjustment
LW = Style.LineWidth;
pMS = ceil(6.5+LW);  % pole marker size
zMS = ceil(5.5+LW);

[Ny,Nu] = size(this.PoleCurves);
for ct1 = 1:Ny
   for ct2 = 1:Nu
      Color = getstyle(Style,RowIndex(ct1),ColumnIndex(ct2),RespIndex);
      set(this.PoleCurves(ct1,ct2,:),'Color',Color,...
         'LineWidth',LW,'MarkerSize',pMS)
      set(this.ZeroCurves(ct1,ct2,:),'Color',Color,...
         'LineWidth',LW,'MarkerSize',zMS)
   end
end