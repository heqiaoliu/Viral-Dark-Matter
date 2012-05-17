function mapCSTPrefs2RespPlotOpts(this,varargin)
%MAPCSTPREFS Maps the CST or view prefs to the RespPlotOptions

%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:17:58 $

if isempty(varargin)
    CSTPrefs = cstprefs.tbxprefs;
else
    CSTPrefs = varargin{1};
end

this.InputLabels = struct('FontSize', CSTPrefs.IOLabelsFontSize , ...
                          'FontWeight', CSTPrefs.IOLabelsFontWeight, ...
                          'FontAngle', CSTPrefs.IOLabelsFontAngle, ...
                          'Color', [0.4000 0.4000 0.4000]);


this.OutputLabels =  struct('FontSize', CSTPrefs.IOLabelsFontSize , ...
                            'FontWeight', CSTPrefs.IOLabelsFontWeight, ...
                            'FontAngle', CSTPrefs.IOLabelsFontAngle, ...
                            'Color', [0.4000 0.4000 0.4000]);




