function importplant(this) %#ok<*INUSD>
% IMPORTPLANT opens importdlg

% Author(s): R. Chen
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1.2.1 $ $Date: 2010/06/24 19:32:28 $

dlg = pidtool.ImportDialogBrowser(this);
dlg.show; 