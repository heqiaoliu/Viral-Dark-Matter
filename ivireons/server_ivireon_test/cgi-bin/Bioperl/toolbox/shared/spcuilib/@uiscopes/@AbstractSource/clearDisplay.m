function clearDisplay(this)
%CLEARDISPLAY clear image

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2008/04/28 03:26:43 $

% Remove any screen messages
this.Application.screenMsg(false);

% Clear the status bar.
hFrame = this.Application.getStatusControl('Frame');
hFrame.Text = '';

hRate = this.Application.getStatusControl('Rate');
hRate.Text = '';

hStatus = this.Application.getGUI.findchild('StatusBar').WidgetHandle;
hStatus.Text = '';

% [EOF]
