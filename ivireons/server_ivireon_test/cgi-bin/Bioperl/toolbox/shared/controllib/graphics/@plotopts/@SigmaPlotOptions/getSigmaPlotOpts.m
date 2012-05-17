function getSigmaPlotOpts(this,h,varargin)
%GETSIGMAPLOTOPTS Gets plot options of @sigmaplot h 

%  Author(s): C. Buhr
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:18:02 $

if isempty(varargin) 
   allflag = false;
else
    allflag = varargin{1};
end


this.FreqUnits = h.AxesGrid.XUnits;
this.FreqScale = h.AxesGrid.XScale;
this.MagUnits = h.AxesGrid.YUnits;
this.MagScale = h.AxesGrid.YScale;


if allflag
    getRespPlotOpts(this,h,allflag);
end