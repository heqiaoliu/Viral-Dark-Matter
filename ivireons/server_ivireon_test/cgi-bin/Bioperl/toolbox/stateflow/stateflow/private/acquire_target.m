function newTarget = acquire_target(machineNameOrId,targetName)
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.3.2.3 $  $Date: 2009/08/23 19:51:36 $
	
if(ischar(machineNameOrId))
   machineId = sf('find','all','machine.name',machineNameOrId);
else
   machineId = machineNameOrId;
end
targets = sf('TargetsOf',machineId);
newTarget = sf('find',targets,'target.name',targetName);
if(~isempty(newTarget))
   return;
end

%%% doesn't exist: create new one.
% g555501: save/restore the dirty flag otherwise CTRL-B dirties the model.
machineDirty = sf('get', machineId, '.dirty');
modelH = sf('get', machineId, '.simulinkModel');
modelDirty = get_param(modelH, 'dirty');

newTarget = new_target(machineId,targetName);

modelLocked = get_param(modelH, 'Lock');
set_param(modelH, 'Lock', 'off');
sf('set', machineId, '.dirty', machineDirty);
set_param(modelH, 'dirty', modelDirty);
set_param(modelH, 'Lock', modelLocked);
