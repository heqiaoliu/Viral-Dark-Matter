function mapCSTPrefs(this,varargin)
%MAPCSTPREFS Maps the CST or view prefs to the HSVPlotOptions

%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:17:28 $

if isempty(varargin)
    CSTPrefs = cstprefs.tbxprefs;
else
    CSTPrefs = varargin{1};
end

mapCSTPrefs2PlotOpts(this,CSTPrefs);

