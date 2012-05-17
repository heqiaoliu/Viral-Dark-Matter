function applystyle(this,Style,RowIndex,ColumnIndex,RespIndex)
%APPLYSTYLE  Applies line style to @view objects.
%
%  Applies line style to all gobjects making up the @view instance
%  (as returned by GHANDLES).

%  Author(s): 
%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2008/12/29 02:11:37 $

%% Overloaded to color lines by column instead of by response so that
%% the columns of time series which are normally displayed on the same axes
%% are disinguishable
%% Overloaded so as not to call ghandles -which must now return all HG
%% objects including selection curves and CurorBars

%% Loop through the curve for each time series column and incrment the
%% color to distinguish those columns
for ct = 1:length(this.Curves(:))
   c = this.Curves(ct);
   [Color,LineStyle,Marker] = getstyle(Style,1,ct,RespIndex);
   set(c(ishghandle(c)),'Color',Color,'LineStyle',LineStyle,...
         'Marker',Marker,'LineWidth',Style.LineWidth)
end
