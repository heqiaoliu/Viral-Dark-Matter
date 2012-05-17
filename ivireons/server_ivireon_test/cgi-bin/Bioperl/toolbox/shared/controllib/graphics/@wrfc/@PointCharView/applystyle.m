function applystyle(this,Style,RowIndex,ColumnIndex,RespIndex)
%APPLYSTYLE  Applies style of parent @waveform to characteristics dots.

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:28:46 $
[nr,nc] = size(this.Points);
for ct2 = 1:nc
   for ct1 = 1:nr
      Color = getstyle(Style,RowIndex(ct1),ColumnIndex(ct2),RespIndex); 
      set(this.Points(ct1,ct2),'Color',Color,'MarkerEdgeColor',Color,'MarkerFaceColor',Color)
   end
end