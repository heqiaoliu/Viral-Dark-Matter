%PDELAYOUT script to define dialog box layout parameters.
%

% Copied from matlab/uitools

%   Author(s): A. Potvin, 5-1-93
%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/11 22:50:37 $

mDoneButtonString = 'Done';
mOKButtonString = 'OK';
mRevertButtonString = 'Revert';
mCancelButtonString = 'Cancel';

% Following in  pixels
mStdButtonWidth = 90;
mStdButtonHeight = 20;
mOKButtonWidth = 50;
mOKButtonHeight = 20;

mEdgeToFrame = 1;
mFrameToText = 15;
COMPUTER = computer;
if strcmp(COMPUTER(1:2),'PC')
   mLineHeight = 13;
else
   mLineHeight = 15;
end

% end layout
