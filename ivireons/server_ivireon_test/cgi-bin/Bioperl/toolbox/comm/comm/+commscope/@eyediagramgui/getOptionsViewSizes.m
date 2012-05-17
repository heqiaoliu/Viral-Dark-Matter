function sz = getOptionsViewSizes(this)
%GETOPTIONSVIEWSIZES Get the optionsViewSizes.
%   OUT = GETOPTIONSVIEWSIZES(ARGS) <long description>

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/07/14 03:52:12 $

% Get the standard size information and add eye scope specific sizing
sz = baseGuiSizes(this);

% Set the font parameters
sz = setFontParams(this, sz);

% Set window size
sz.OptionsViewWidth = 500;
sz.OptionsViewHeight = 320;

% Quick help panel height
sz.QuickHelpHeight = 95;

% Determine OK / Cancel button locations
sz.OKButtonX = sz.hcc;
sz.OKButtonY = sz.vcc;
sz.CancelButtonX = sz.OKButtonX + sz.hcc + sz.bw;
sz.CancelButtonY = sz.OKButtonY;

%-------------------------------------------------------------------------------
% [EOF]
