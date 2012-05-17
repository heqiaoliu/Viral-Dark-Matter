function loadBlkFcn(blk) 
%

% Author(s): A. Stothert 17-Feb-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/04/30 00:44:21 $

% LOADBLKFCN load callback for all frequency domain check blocks
%

% Bypass for library block
Model = bdroot(blk);
if strcmp(Model,{'slctrlblks'})
   return
end

%Check to see if we need to open the block visualization
if strcmp(get_param(blk,'OpenViewOnLoad'),'on')
  checkpack.absCheckDlg.openBlkView(get_param(blk,'Object'))
end

%Make sure a CheckBlkExecutionEngine exists for the model. This ensures
%there is a listener for model EnginePostLibraryLinkResolve events so that the model
%can be configured for linearization.
eng = linearize.CheckBlkExecutionManager.getInstance(Model);
if isempty(eng)
   ctrlMsgUtils.error('SLControllib:checkpack:errUnexpected','Failed to create linearization engine');
end
end