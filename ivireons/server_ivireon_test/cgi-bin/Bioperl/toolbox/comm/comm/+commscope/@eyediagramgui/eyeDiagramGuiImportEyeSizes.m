function sz = eyeDiagramGuiImportEyeSizes(this)
%EYEDIAGRAMGUIIMPORTEYESIZES Sizes for import eye diagram object window

%   @commscope/@eyediagramgui
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:22:46 $

% Get the standard size information and add eye scope specific sizing
sz = baseGuiSizes(this);

% Set the font parameters
sz = setFontParams(this, sz);

% Set window size
sz.ImportEyeWidth = 500;
sz.ImportEyeHeight = 300;

%--------------------------------------------------------------------------
% Calculate the coordinates of the pushbuttons
sz.CancelButtonX = sz.ImportEyeWidth - sz.hcf - sz.bw;
sz.ImportButtonX = sz.CancelButtonX - sz.hcc - sz.bw;

%--------------------------------------------------------------------------
% Calculate the coordinates of the source and contents panels
availableWidth = sz.ImportEyeWidth - sz.hcf - sz.hff - sz.hcf;
availableHeight = sz.ImportEyeHeight - sz.vcf - sz.bh - sz.vcf - sz.vcf;

sz.SourcePanelX = sz.hcf;
sz.SourcePanelWidth = availableWidth * 1 / 3;
sz.SourcePanelY = sz.vcf + sz.bh + sz.vcf;
sz.SourcePanelHeight = availableHeight + sz.plTweak;

sz.ContentsPanelX = sz.SourcePanelX + sz.SourcePanelWidth + sz.hcc;
sz.ContentsPanelWidth = availableWidth * 2 / 3;
sz.ContentsPanelY = sz.SourcePanelY;
sz.ContentsPanelHeight = sz.SourcePanelHeight;

%--------------------------------------------------------------------------
% Calculate the coordinates of the source panel contents
tempLabels = {'From workspace', 'From file'};
sz.SourceRbWidth = largestuiwidth(tempLabels) + sz.rbwTweak;

sz.SourceRbWsY = sz.SourcePanelHeight - sz.vcf - sz.lh - sz.ptTweak;
sz.SourceRbFileY = sz.SourceRbWsY - sz.vcc - sz.lh;

tempLabels = {'MAT-file name:'};
sz.SourceFileNameLabelWidth = largestuiwidth(tempLabels);
sz.SourceFileNameLabelY = sz.SourceRbFileY - sz.vcc - sz.lh;
sz.SourceFileNameLabelX = sz.hcf + sz.rbwTweak;

sz.SourceFileNameY = sz.SourceFileNameLabelY - sz.vcc - sz.fs;
sz.SourceFileNameX = sz.SourceFileNameLabelX;
sz.SourceFileNameWidth = sz.SourcePanelWidth - sz.vcf - sz.SourceFileNameX;

sz.SourceBrowseY = sz.SourceFileNameY - sz.vcc - sz.lh;
sz.SourceBrowseX = sz.SourcePanelWidth - sz.vcf - sz.bw;

%--------------------------------------------------------------------------
% Calculate the coordinates of the contents panel contents
sz.ContentsListX = sz.hcc;
sz.ContentsListY = sz.vcc;
sz.ContentsListHeight = sz.ContentsPanelHeight - 2*sz.vcc - sz.plTweak;
sz.ContentsListWidth = sz.ContentsPanelWidth - 2*sz.hcc;

%-------------------------------------------------------------------------------
% [EOF]
