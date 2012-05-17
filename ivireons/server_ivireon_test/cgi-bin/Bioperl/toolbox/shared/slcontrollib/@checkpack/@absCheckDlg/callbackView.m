function callbackView(this)
%

% Author(s): A. Stothert 14-Oct-2009
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:51:18 $

% CALLBACKVIEW manage widget changes on the view panel and launch the check
% block visualization
%

checkpack.absCheckDlg.openBlkView(this.getBlock)
end