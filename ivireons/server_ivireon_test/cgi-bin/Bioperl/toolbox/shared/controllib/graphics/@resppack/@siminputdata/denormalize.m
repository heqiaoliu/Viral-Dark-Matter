function ydata = denormalize(this,ydata,Xlims,varargin)
%DENORMALIZE  Infers true Y value from normalized Y value.
%
%  Input arguments:
%    * YDATA is the Y data to be normalized
%    * XLIMS are the X limits for the axes of interest
%    * The last argument(s) is either an absolute index or a pair
%      of row/column indices specifying the axes location in the 
%      axes grid.

%  Author(s): P. Gahinet
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:24:26 $
[ns,ny,nu] = size(this.Amplitude);
if ny>0
   [ymin,ymax,FlatY] = ydataspan(this.Time,this.Amplitude,Xlims);
   ydata = (ymin+ymax)/2 + ydata * ((ymax-ymin)/2+FlatY);
end
