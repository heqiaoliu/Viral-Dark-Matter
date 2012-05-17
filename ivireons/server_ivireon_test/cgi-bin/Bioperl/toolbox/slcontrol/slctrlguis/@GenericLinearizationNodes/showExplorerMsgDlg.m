function showExplorerMsgDlg(msg)
% SHOWEXPLORERMSGDLG  Create a message dialog and put it infront of the
% CETM.
%
 
% Author(s): John W. Glass 17-Jan-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2009/08/29 08:32:27 $

% Show the message dialog
msgbox(msg,xlate('Simulink Control Design'),'modal');