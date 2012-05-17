function machine = actual_machine_referred_by(chart)
%
% Find the actual machine referenced by the activeInstance of the
% input chart.  
%
% This corrrectly returns the machineId of the parent model from which
% this chart's simulink block or library instance has been opened.
%

%	Copyright 1995-2008 The MathWorks, Inc.
%	$Revision: 1.7.2.3 $  $Date: 2008/11/13 18:41:30 $

chartMachine = sf('get', chart, '.machine');
activeInstance = sf('get', chart, '.activeInstance');

if (isequal(activeInstance, 0) || ~ishandle(activeInstance)),
    machine = chartMachine;
else
    modelH = bdroot(activeInstance);
    machine = sf('find','all','machine.simulinkModel', modelH);
    
    if(isempty(machine)), machine = chartMachine;	end;
end;
