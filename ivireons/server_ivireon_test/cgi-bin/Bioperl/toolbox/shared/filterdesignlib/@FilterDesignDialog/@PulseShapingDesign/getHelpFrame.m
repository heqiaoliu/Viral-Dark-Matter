function helpFrame = getHelpFrame(this)
%GETHELPFRAME   Get the helpFrame.

%   Author(s): J. Schickler
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/21 04:23:28 $

helptext.Type     = 'text';
helptext.Name     = FilterDesignDialog.message('PulseShapingDesignHelpTxt');
helptext.Tag      = 'HelpText';
helptext.WordWrap = true;

helpFrame.Type  = 'group';
helpFrame.Name  = getDialogTitle(this);
helpFrame.Items = {helptext};
helpFrame.Tag   = 'HelpFrame';

% [EOF]
