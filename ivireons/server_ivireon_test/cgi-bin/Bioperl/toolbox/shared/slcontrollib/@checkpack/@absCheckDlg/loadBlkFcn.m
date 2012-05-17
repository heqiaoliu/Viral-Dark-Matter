function loadBlkFcn(blk) 
%

% Author(s): A. Stothert 17-Feb-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:51:24 $

% LOADBLKFCN load callback for all check blocks
%

% Bypass for library block
Model = bdroot(blk);
if strcmp(Model,{'slctrlblks'})
   return
end

if strcmp(get_param(blk,'OpenViewOnLoad'),'on')
   checkpack.absCheckDlg.openBlkView(get_param(blk,'Object'))
end
end
