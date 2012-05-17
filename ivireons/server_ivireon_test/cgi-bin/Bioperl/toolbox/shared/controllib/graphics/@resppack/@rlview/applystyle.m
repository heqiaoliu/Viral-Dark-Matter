function applystyle(this,Style,RowIndex,ColumnIndex,RespIndex)
%APPLYSTYLE  Applies style to root locus plot.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.2 $  $Date: 2010/02/08 22:53:06 $
[Color,LineStyle,Marker] = getstyle(Style,1,1,RespIndex);
set(this.Locus,'Color',Color,'LineStyle',LineStyle,'Marker',Marker,...
    'LineWidth',Style.LineWidth)
set([this.SystemZero,this.SystemPole],'Color',Color)
