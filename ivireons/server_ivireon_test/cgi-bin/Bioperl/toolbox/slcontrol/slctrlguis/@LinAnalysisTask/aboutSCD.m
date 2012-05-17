function aboutSCD(Explorer)
% ABOUTSCD  Create an About SCD dialog and put it above the CETM Frame
%
 
% Author(s): John W. Glass 11-Oct-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/03/13 17:40:05 $

% Get the version number from ver
verdata = ver('slcontrol');
% Create the version message
message = sprintf('%s %s\n%s', verdata.Name, verdata.Version, ...
                            sprintf('Copyright 2004 - %s, The MathWorks, Inc.',verdata.Date(end-3:end)));
% Show the dialog
GenericLinearizationNodes.showExplorerMsgDlg(message);