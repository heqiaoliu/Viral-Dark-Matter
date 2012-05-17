function configapply(this,InitData)
% Applies configuration settings

%   Author(s): P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2008/05/31 23:16:17 $
LoopData = this.LoopData;

try
   % Save new and old config settings
   OldData = exportdesign(LoopData);
   NewData = InitData;
   
   % Apply new configuration
   LoopData.importdesign(InitData)
   
   % Register transaction
   T = ctrluis.ftransaction('Change Configuration');
   T.UndoFcn = {@importdesign LoopData OldData};
   T.RedoFcn = {@importdesign LoopData NewData};
   this.EventManager.record(T);
catch ME
   % Invalid data: abort
   % Pop up error dialog and abort apply
   errordlg(ltipack.utStripErrorHeader(ME.message),'Import Error')
   return
end

% Update status bar and history
this.EventManager.newstatus('Applied new configuration. Right-click on the plots for design options.');
this.EventManager.recordtxt('history','Changed control system configuration.');
