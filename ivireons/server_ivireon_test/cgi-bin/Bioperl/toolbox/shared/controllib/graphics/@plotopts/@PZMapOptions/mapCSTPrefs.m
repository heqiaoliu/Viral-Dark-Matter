function mapCSTPrefs(this,varargin)
%MAPCSTPREFS for PZMapPlotOptions

%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:17:44 $

if isempty(varargin)
    CSTPrefs = cstprefs.tbxprefs;
else
    CSTPrefs = varargin{1};
end

mapCSTPrefs2RespPlotOpts(this,CSTPrefs);
mapCSTPrefs2PlotOpts(this,CSTPrefs);

this.FreqUnits = CSTPrefs.FrequencyUnits; 
