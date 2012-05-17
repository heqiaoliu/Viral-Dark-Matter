function sz = guiSizes(this)
%guiSizes Sizes for compare results window

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/06/11 15:56:45 $

% Get the standard size information and add eye scope specific sizing
sz = baseGuiSizes(this);

% Set the font parameters
sz = setFontParams(this, sz);

% Determine figure window size
pf = sz.pixf;
sz.FigWidth = 810 * pf;
sz.FigHeight = 600 * pf - sz.MenuHeight;

% Get the figure handle and set size
hFig = this.Parent;
pos = get(hFig, 'Position');
pos(3) = sz.FigWidth; 
pos(4) = sz.FigHeight;
set(hFig, 'Position', pos);

%--------------------------------------------------------------------------
% Determine the major are limits.  We will divide the window into three main
% areas as follows: A is the plot section, B is the hView section, and C is the
% table section
% -----------------
% |        |      |
% |   A    |  B   |
% |        |      |
% -----------------
% |      C        |
% |               |
% -----------------
sz.PlotSectionHeight = sz.FigHeight*0.7;
sz.PlotSectionWidth = sz.FigWidth*0.6;
sz.PlotSectionX = 0;
sz.PlotSectionY = sz.FigHeight - sz.PlotSectionHeight;

sz.SetupSectionHeight = sz.PlotSectionHeight;
sz.SetupSectionWidth = sz.FigWidth - sz.PlotSectionWidth;
sz.SetupSectionX = sz.PlotSectionX + sz.PlotSectionWidth;
sz.SetupSectionY = sz.PlotSectionY;

sz.TableSectionHeight = sz.FigHeight - sz.PlotSectionHeight;
sz.TableSectionWidth = sz.FigWidth;
sz.TableSectionX = 0;
sz.TableSectionY = 0;

%--------------------------------------------------------------------------
% Calculate sizes for the table
sz.TableY = sz.TableSectionY + sz.vcf;
sz.TableX = 0.13 * sz.PlotSectionWidth;  % This seems to be the ratio between 
                                         % outer position and position
sz.TableHeight = sz.TableSectionHeight - 2*sz.vcf;
sz.TableWidth = sz.TableSectionWidth - sz.TableX - sz.hcf;

% Calculate sizes for eye diagram management buttons
sz.ButtonHeight = sz.bh;
sz.ButtonWidth = sz.ButtonHeight;
sz.ButtonX = sz.TableX - sz.hcf - sz.ButtonWidth;
sz.AddY = sz.TableY + sz.TableHeight - sz.ButtonHeight;
sz.DelY = sz.AddY - sz.vcf - sz.ButtonHeight;
sz.UpY = sz.DelY - sz.vcf - sz.ButtonHeight;
sz.DownY = sz.UpY - sz.vcf - sz.ButtonHeight;

%--------------------------------------------------------------------------
% Calculate sizes for settings and measurements panels
sz.MeasurementsPanelY = sz.SetupSectionY;
sz.MeasurementsPanelX = sz.SetupSectionX + sz.hcf;
sz.MeasurementsPanelHeight = sz.SetupSectionHeight*0.6 - 1.5*sz.vcf;
sz.MeasurementsPanelWidth = sz.SetupSectionWidth - 2*sz.hcf;

sz.IQSelectorY = sz.vcf;
sz.IQSelectorX = sz.hcf;
sz.IQSelectorHeight = sz.lh;
sz.IQSelectorWidth = sz.MeasurementsPanelWidth - 2*sz.hcf;

sz.SelectorTableY = sz.IQSelectorY + sz.IQSelectorHeight + sz.vcf;
sz.SelectorTableX = 1;
sz.SelectorTableHeight = sz.MeasurementsPanelHeight - sz.IQSelectorHeight...
    - 2*sz.vcf - sz.ptTweak;
sz.SelectorTableWidth = sz.MeasurementsPanelWidth-4;

sz.SettingsPanelY = sz.MeasurementsPanelY + sz.MeasurementsPanelHeight + sz.vcf;
sz.SettingsPanelX = sz.MeasurementsPanelX;
sz.SettingsPanelHeight = sz.SetupSectionHeight*0.4 - 1.5*sz.vcf;
sz.SettingsPanelWidth = sz.MeasurementsPanelWidth;

%-------------------------------------------------------------------------------
% [EOF]
