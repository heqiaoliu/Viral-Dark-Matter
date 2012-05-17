function applyTimePlotOpts(this,h,varargin)
%APPLYTIMEPLOTOPTS  set timeplot properties

%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:18:06 $

if isempty(varargin) 
    allflag = false;
else
    allflag = varargin{1};
end

h.AxesGrid.YNormalization = this.Normalize;  
h.Options.SettlingTimeThreshold = this.SettleTimeThreshold;
h.Options.RiseTimeLimits = this.RiseTimeLimits;    
                 
if allflag
   applyRespPlotOpts(this,h,allflag);
end