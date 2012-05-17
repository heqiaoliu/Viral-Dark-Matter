function applystyle(this,Style,RowIndex,ColumnIndex,RespIndex)
%APPLYSTYLE  Applies line styles to @sigmaview.

%  Author(s): Kamesh Subbarao, 10-15-2001
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:24:17 $
[Color,LineStyle,Marker] = getstyle(Style,1,1,RespIndex);
set(this.Curves,'Color',Color,'LineStyle',LineStyle,'Marker',Marker)