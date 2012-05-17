function mapCSTPrefs(this,varargin)
%MAPCSTPREFS for TimePlotOptions

%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:18:08 $


if isempty(varargin)
    CSTPrefs = cstprefs.tbxprefs;
else
    CSTPrefs = varargin{1};
end


mapCSTPrefs2RespPlotOpts(this,CSTPrefs);
mapCSTPrefs2PlotOpts(this,CSTPrefs);

this.SettleTimeThreshold = CSTPrefs.SettlingTimeThreshold;
this.RiseTimeLimits = CSTPrefs.RiseTimeLimits;
