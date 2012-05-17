function goto_target(machineName,targetName)
% GOTO_TARGET(MACHINENAME,TARGETNAME)
% opens the target manager dialog box for the specified
% (machinename,targetname) combination. Creates the target 
% object if it is not already present. To be used by
% sfcall.m and RTW build dialog box.
% 
%	Vijaya Raghavan
%	Copyright 1995-2005 The MathWorks, Inc.
%  $Revision: 1.9.2.9 $  $Date: 2008/05/20 00:37:34 $

if(ischar(machineName))
	machineId = sf('find','all','machine.name',machineName);
else
	machineId = machineName;
end

modelH = machine2model(machineId);
cs     = getActiveConfigSet(modelH);

switch(targetName)
case 'sfun'
	% dboissy says:
	% When 'Stateflow Simulation' settings in configset
	% are hooked up we can remove the comments from this
	% block of code.
	if sf('get', machineId, '.isLibrary')
		slCfgPrmDlg(modelH, 'OpenLibSim');
	else
		slCfgPrmDlg(modelH, 'Open');
		slCfgPrmDlg(modelH, 'TurnToPage', 'Simulation Target');
	end;

	% DELETE- Replaced by code above
	%goto_simulation_target(machineId);
case 'rtw'
	if sf('get', machineId, '.isLibrary')
		slCfgPrmDlg(modelH, 'OpenLibRTW');
	else
		slCfgPrmDlg(modelH, 'Open');
		slCfgPrmDlg(modelH, 'TurnToPage', 'Real-Time Workshop');
	end;
otherwise,
	goto_general_target(machineId,targetName);
end
	


function goto_simulation_target(machineId)
   simulationTargetId = sf('find',sf('TargetsOf',machineId),'target.simulationTarget',1);
   if isempty(simulationTargetId)
      warning('Stateflow:UnexpectedError','Machine has no simulation target!');
      return;
   end
	targetdlg('construct',simulationTargetId);

function goto_rtw_target(machineId)
   if ~sf('License','coder',machineId)
      warning('Stateflow:LicenseError','RTW targets require Stateflow Coder license.');
		return;
   end
   targets = sf('TargetsOf',machineId);
   % See if there is RTW Stateflow target for this machine
   rtwTarget = sf('find',targets,'.name','rtw');
   deleteOnCancel  = 0;
   switch length(rtwTarget)
   case 0 % No RTW targets => create one
      deleteOnCancel = 1;
      rtwTarget = new_target(machineId,'rtw');
   case 1
   otherwise
      warning('Stateflow:UnexpectedError','Multiple Stateflow RTW targets. Using the first one.');
      rtwTarget = rtwTarget(1);
   end
   targetdlg('construct',rtwTarget, deleteOnCancel);

function goto_general_target(machineId,targetName)
   if ~sf('License','coder',machineId)
      warning('Stateflow:LicenseError','Non-simulation targets require Stateflow Coder license.');
		return;
   end

   targets = sf('TargetsOf',machineId);
   generalTarget = sf('find',targets,'.name',targetName);
   deleteOnCancel = 0;
   switch length(generalTarget)
   case 0 % create one
      deleteOnCancel = 1;
      generalTarget = new_target(machineId,targetName);
   case 1
   otherwise
      warning('Stateflow:UnexpectedError','Multiple Stateflow targets. Using the first one.');
      generalTarget = generalTarget(1);
   end
	targetdlg('construct',generalTarget,deleteOnCancel);
