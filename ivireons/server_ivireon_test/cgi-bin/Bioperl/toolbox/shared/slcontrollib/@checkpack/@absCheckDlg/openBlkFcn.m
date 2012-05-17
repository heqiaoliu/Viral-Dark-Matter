function openBlkFcn(hBlk) 
%
 
% Author(s): A. Stothert 17-Feb-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:51:25 $

% OPENBLKFCN open callback for all check blocks
%

if strcmp(hBlk.LaunchViewOnOpen,'on')
   checkpack.absCheckDlg.openBlkView(hBlk)   
else
   open_system(getFullName(hBlk),'mask')
end
end