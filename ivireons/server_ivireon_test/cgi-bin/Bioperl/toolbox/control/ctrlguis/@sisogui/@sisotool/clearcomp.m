function clearcomp(this,idxC)
% Clears compensators

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2005/12/22 17:44:00 $
LoopData = this.LoopData;
Design = exportdesign(LoopData);
ClearedValue = zpk(1);

% Start transaction
T = ctrluis.transaction(LoopData,'Name','Clear',...
   'OperationStore','on','InverseOperationStore','on');

% Clear compensator data
if idxC==0
   % Clear all
   for ct=1:length(LoopData.C)
      Cdata = Design.(LoopData.C(ct).Identifier);
      Cdata.Value = ClearedValue;
      LoopData.C(ct).import(Cdata);
   end
   Status = 'Cleared compensators.';
else
   Cdata = Design.(LoopData.C(idxC).Identifier);
   Cdata.Value = ClearedValue;
   LoopData.C(idxC).import(Cdata);
   Status = sprintf('Cleared the %s.',LoopData.describe(idxC,false));
end

% Commit and register transaction
this.EventManager.record(T);

% Notify peers of data change
LoopData.dataevent('all');

% Update status bar and history
this.EventManager.newstatus(Status);
this.EventManager.recordtxt('history',Status);
