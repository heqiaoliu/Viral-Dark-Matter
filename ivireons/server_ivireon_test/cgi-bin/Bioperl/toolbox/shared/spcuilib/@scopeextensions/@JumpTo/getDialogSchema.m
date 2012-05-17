function dlgstruct = getDialogSchema(this,arg)  %#ok
%GetDialogSchema Construct JumpTo dialog.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/04/27 19:54:12 $

% Frame number widgets
frame.Name    = 'Frame number:';
frame.Tag     = 'FrameNumber';
frame.Type    = 'edit';
frame.RowSpan = [1 1];
frame.ColSpan = [1 1];
frame.Value   = 1;
frame.Tag     = 'frame';

range.Name         = sprintf('  (max=%d)',this.maxframe);
range.Tag          = 'MaxFrame';
range.Type         = 'text';
range.RowSpan      = [1 1];
range.ColSpan      = [2 2];

% Widget container
prop.Type       = 'panel';
prop.Name       = '';  % don't show a name
prop.Tag        = 'FrameRange';
prop.LayoutGrid = [1 2];
prop.RowSpan    = [1 1];
prop.ColSpan    = [1 1];
prop.Items      = {frame,range};

% ----------------------------------------------
% Return main dialog structure
% ----------------------------------------------
%
dlgstruct = this.StdDlgProps;
dlgstruct.PostApplyMethod = 'postApply';
dlgstruct.LayoutGrid      = [1 1];
dlgstruct.RowStretch      = 1;
dlgstruct.ColStretch      = 1;
dlgstruct.Items           = {prop};
dlgstruct.StandaloneButtonSet = {'OK','Cancel','Apply'};
dlgstruct.DialogTag       = 'JumpTo';

% [EOF]
