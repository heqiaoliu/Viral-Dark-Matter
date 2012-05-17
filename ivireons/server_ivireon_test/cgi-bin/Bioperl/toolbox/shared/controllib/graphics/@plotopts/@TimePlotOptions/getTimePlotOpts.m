function getTimePlotOpts(this,h,varargin)
%GETTIMEPLOTOPTS Gets plot options of @timeplot h 

%  Author(s): C. Buhr
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:18:07 $

if isempty(varargin) 
   allflag = false;
else
    allflag = varargin{1};
end

this.Normalize = h.AxesGrid.YNormalization;     
this.SettleTimeThreshold = h.Options.SettlingTimeThreshold;
this.RiseTimeLimits = h.Options.RiseTimeLimits;
          
if allflag
    getRespPlotOpts(this,h,allflag);
end