function sz = guiSizes(this)
%guiSizes Sizes for compare results window

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/05/31 23:14:47 $

% Get the standard size information and add eye scope specific sizing
sz = baseGuiSizes(this);

% Set the font parameters
sz = setFontParams(this, sz);

% Determine figure window size
pf = sz.pixf;
if ~ispc
    sz.FigWidth = 870 * pf;
else
    sz.FigWidth = 810 * pf;
end
sz.FigHeight = 600 * pf - sz.MenuHeight;

% Get the figure handle and set size
hFig = this.Parent;
pos = get(hFig, 'Position');
pos(3) = sz.FigWidth; 
pos(4) = sz.FigHeight;
set(hFig, 'Position', pos);

%--------------------------------------------------------------------------
% Determine the major are limits.  We will divide the window into three main
% areas as follows: A is the plot section, B is the info section, C is the
% list section.
% -----------------
% |        |      |
% |   A    |  B   |
% |        |      |
% |        |      |
% ---------|      |
% |   C    |      |
% -----------------
sz.PlotSectionHeight = sz.FigHeight*0.70;
sz.PlotSectionWidth = sz.FigWidth*0.56;
sz.PlotSectionX = 0;
sz.PlotSectionY = sz.FigHeight - sz.PlotSectionHeight;

sz.InfoSectionHeight = sz.FigHeight;
sz.InfoSectionWidth = sz.FigWidth - sz.PlotSectionWidth;
sz.InfoSectionX = sz.PlotSectionX + sz.PlotSectionWidth;
sz.InfoSectionY = 0;

sz.ListSectionHeight = sz.FigHeight - sz.PlotSectionHeight;
sz.ListSectionWidth = sz.PlotSectionWidth;
sz.ListSectionX = 0;
sz.ListSectionY = 0;

%--------------------------------------------------------------------------
% Calculate how much margin is needed for the axes
hDummyFig = figure('visible', 'off');
hDummyAxes = axes(...
    'Parent',hDummyFig,...
    'FontSize',get(0,'defaultuicontrolFontSize'),...
    'Units','pixel',...
    'Position',[100 100 200 200]);
ylabel(hDummyAxes, 'Amplitude (AU)');
xlabel(hDummyAxes, 'Time (s)');
title(hDummyAxes, 'Single Eye Diagram View');
tighInsetMargins = get(hDummyAxes, 'tightInset');
sz.AxesLeftMargin = tighInsetMargins(1);
sz.AxesBottomMargin = tighInsetMargins(2);
sz.AxesRightMargin = tighInsetMargins(3);
sz.AxesTopMargin = tighInsetMargins(4);
delete(hDummyFig);

%--------------------------------------------------------------------------
% Calculate the axes sizes for both real-only and complex
sz.AxesWidth = sz.PlotSectionWidth ...
    - sz.AxesLeftMargin - sz.AxesRightMargin - 2*sz.hcf;
sz.AxesHeight = sz.PlotSectionHeight ...
    - sz.AxesTopMargin- sz.AxesBottomMargin - 2*sz.vcf;
sz.AxesY = sz.PlotSectionY + sz.vcf + sz.AxesBottomMargin;
sz.AxesX = sz.PlotSectionX + sz.hcf + sz.AxesLeftMargin;

sz.AxesIQHeight = (sz.PlotSectionHeight ...
    - 2*sz.AxesTopMargin - 2*sz.AxesBottomMargin - 2*sz.vcf)/2;
sz.AxesQY = sz.PlotSectionY + sz.vcf + sz.AxesBottomMargin;
sz.AxesIY = sz.AxesQY + sz.vcf + sz.AxesBottomMargin + sz.AxesIQHeight;

%--------------------------------------------------------------------------
% Calculate sizes for the list
sz.ListY = sz.ListSectionY + sz.vcf;
sz.ListX = sz.AxesX;
sz.ListHeight = sz.ListSectionHeight - 2*sz.vcf - sz.tbh;
sz.ListWidth = sz.ListSectionWidth - sz.ListX - sz.hcf;

% Calculate sizes for list label
sz.ListLabelY = sz.ListY + sz.ListHeight;
sz.ListLabelX = sz.ListX;
sz.ListLabelHeight = sz.tbh;
sz.ListLabelWidth = sz.ListWidth;

% Calculate sizes for eye diagram management buttons
sz.ButtonHeight = sz.bh;
sz.ButtonWidth = sz.ButtonHeight;
sz.ButtonX = sz.ListX - sz.hcf - sz.ButtonWidth;
sz.AddY = sz.ListY + sz.ListHeight - sz.ButtonHeight;
sz.DelY = sz.AddY - sz.vcf - sz.ButtonHeight;

%--------------------------------------------------------------------------
% Calculate sizes for settings and measurements panels
sz.MeasurementsPanelY = sz.InfoSectionY + sz.vcf;
sz.MeasurementsPanelX = sz.InfoSectionX + sz.hcf;
sz.MeasurementsPanelHeight = sz.InfoSectionHeight*0.57 - 1.5*sz.vcf;
sz.MeasurementsPanelWidth = sz.InfoSectionWidth - 2*sz.hcf;

sz.SettingsPanelY = sz.MeasurementsPanelY + sz.MeasurementsPanelHeight + sz.vcf;
sz.SettingsPanelX = sz.MeasurementsPanelX;
sz.SettingsPanelHeight = sz.InfoSectionHeight*0.43 - 1.5*sz.vcf;
sz.SettingsPanelWidth = sz.MeasurementsPanelWidth;

%-------------------------------------------------------------------------------
% [EOF]
