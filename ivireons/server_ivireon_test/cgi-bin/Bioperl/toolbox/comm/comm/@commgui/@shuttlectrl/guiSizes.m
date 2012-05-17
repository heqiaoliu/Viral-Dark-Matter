function sz = guiSizes(this)
%GUISIZES Determine the widget sizes for the shuttle control GUI

%	@commgui\@shuttlectrl
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/05/31 23:15:01 $

% Get the standard size information and add eye scope specific sizing
sz = baseGuiSizes(this);

% Get the position
pos = this.Position;

% Set window size
sz.Width = pos(3);
sz.Height = pos(4);

% Determine quick help window size.  Note that there is a minimum size,
% depending on rendering of move up and move down buttons.
if this.RenderMoveUpDown
    MinQuickHelpHeight = 2*sz.bh + 2*sz.vcc;
else    
    MinQuickHelpHeight = sz.bh + 2*sz.vcc;
end
if MinQuickHelpHeight > this.QuickHelpHeight
    sz.QuickHelpHeight = MinQuickHelpHeight;
else
    sz.QuickHelpHeight = this.QuickHelpHeight;
end

% Determine list box size
sz.ListWidth = (sz.Width - 2*sz.hcc - sz.bw) / 2;
sz.ListHeight = sz.Height - sz.vcc - sz.lh  + sz.lbhTweak - sz.QuickHelpHeight;

% Determine list box label locations
sz.SelectListLabelX = sz.Width - sz.ListWidth;
sz.SelectListLabelY = sz.Height - sz.lh;
sz.AvailListLabelX = 0;
sz.AvailListLabelY = sz.SelectListLabelY;

% Determine list box location
sz.SelectListBoxX = sz.SelectListLabelX;
sz.SelectListBoxY = sz.SelectListLabelY - sz.ListHeight + sz.lbhTweak;
sz.AvailListBoxX = 0;
sz.AvailListBoxY = sz.SelectListBoxY;

% Determine Move Up / Move Down button locations
sz.MoveDownButtonX = sz.SelectListLabelX + sz.hcc + sz.bw;
sz.MoveDownButtonY = sz.SelectListBoxY - sz.vcc - sz.bh;
sz.MoveUpButtonX = sz.SelectListLabelX;
sz.MoveUpButtonY = sz.MoveDownButtonY;

% Set the object properties
this.AvailableListX = sz.AvailListBoxX;
this.SelectedListX = sz.SelectListBoxX;

% Determine Add / Remove button locations
sz.RemoveButtonX = sz.SelectListBoxX - sz.hcc - sz.bw;
sz.RemoveButtonY = sz.SelectListBoxY + (sz.ListHeight - sz.vcc - 2*sz.bh) / 2;
sz.AddButtonX = sz.RemoveButtonX;
sz.AddButtonY = sz.RemoveButtonY + sz.vcc + sz.bh;

% Determine quick help panel size/location
sz.QuickHelpX = sz.AvailListBoxX;
sz.QuickHelpY = 0;
sz.QuickHelpWidth = sz.ListWidth;
sz.QuickHelpHeight = sz.QuickHelpHeight + sz.plTweak;

% Determine quick help text box size/location
sz.QuickHelpTextX = sz.ptbTweak;
sz.QuickHelpTextY = sz.ptbTweak;
sz.QuickHelpTextWidth = sz.QuickHelpWidth-2*sz.lblTweak;
sz.QuickHelpTextHeight = sz.QuickHelpHeight - sz.ptTweak - sz.ptbTweak;

% Determine OK / Cancel button locations
sz.OKButtonX = sz.Width - sz.ListWidth;
sz.OKButtonY = 0;
sz.CancelButtonX = sz.OKButtonX + sz.hcc + sz.bw;
sz.CancelButtonY = sz.OKButtonY;

%-------------------------------------------------------------------------------
% [EOF]
