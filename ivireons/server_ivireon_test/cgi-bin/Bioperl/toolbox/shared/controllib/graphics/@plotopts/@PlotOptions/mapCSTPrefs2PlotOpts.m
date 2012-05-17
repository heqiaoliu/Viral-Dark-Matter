function mapCSTPrefs2PlotOpts(this,varargin)
%MAPCSTPREFS2PLOTOPTS Maps the CST or view prefs to the plotoptions

%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:17:53 $


if isempty(varargin)
    CSTPrefs = cstprefs.tbxprefs;
else
    CSTPrefs = varargin{1};
end

this.Title.FontSize = CSTPrefs.TitleFontSize;
this.Title.FontWeight = CSTPrefs.TitleFontWeight;
this.Title.FontAngle = CSTPrefs.TitleFontAngle;
this.Title.Color =[0 0 0];
             
this.XLabel.FontSize =   CSTPrefs.XYLabelsFontSize;
this.XLabel.FontWeight = CSTPrefs.XYLabelsFontWeight;
this.XLabel.FontAngle =  CSTPrefs.XYLabelsFontAngle;
this.XLabel.Color = [0 0 0];

this.YLabel.FontSize =   CSTPrefs.XYLabelsFontSize;
this.YLabel.FontWeight = CSTPrefs.XYLabelsFontWeight;
this.YLabel.FontAngle =  CSTPrefs.XYLabelsFontAngle;
this.YLabel.Color = [0 0 0];       

this.TickLabel.FontSize = CSTPrefs.AxesFontSize;
this.TickLabel.FontWeight = CSTPrefs.AxesFontWeight;
this.TickLabel.FontAngle = CSTPrefs.AxesFontAngle;
this.TickLabel.Color = CSTPrefs.AxesForegroundColor;

this.Grid = CSTPrefs.Grid;