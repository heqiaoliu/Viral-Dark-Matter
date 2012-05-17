function applystyle(this,Style,RowIndex,ColIndex,RespIndex)
%APPLYSTYLE  Applies style of parent response.

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:19:17 $
Color = getstyle(Style,1,1,RespIndex);
set([this.MagPoints(ishandle(this.MagPoints)) ; ...
      this.PhasePoints(ishandle(this.PhasePoints))],...
   'Color',Color,'MarkerEdgeColor',Color,'MarkerFaceColor',Color)