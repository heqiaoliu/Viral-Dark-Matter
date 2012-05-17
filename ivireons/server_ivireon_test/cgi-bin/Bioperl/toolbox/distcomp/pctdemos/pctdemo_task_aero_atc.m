function meanRrange = pctdemo_task_aero_atc(rainfallVec, RrangeVec)
%PCTDEMO_TASK_AERO_ATC Run a sequence of aircraft radar simulations.
%   meanRrange = pctdemo_task_aero_atc(rainfallVec, RrangeVec) runs one 
%   aircraft radar simulation for each pair (rainfallVec(i), RrangeVec(i)) 
%   and calculates the mean location estimation error.
%  
%   The vectors rainfallVec and RrangeVec must be of the same length, and the 
%   output vector meanRrange will be of that same length.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2.2.1 $  $Date: 2010/06/14 14:25:06 $
    
    open_system('aero_atc.mdl');
    
    numiter = numel(rainfallVec);
    meanRrange = zeros(1, numiter);
    
    set_param('aero_atc', 'StopTime', '20000');
    set_param('aero_atc/Aircraft Range', 'LimitDataPoints', 'on');
    set_param('aero_atc/Aircraft Range', 'MaxDataPoints', '10000');
    set_param('aero_atc/Aircraft Range', 'SampleInput', 'on');
    set_param('aero_atc/Aircraft Range', 'SampleTime', '1');
    set_param('aero_atc/Aircraft Range', 'SaveToWorkspace', 'on');
    set_param('aero_atc/Aircraft Range', 'SaveName', 'outRrange');
    set_param('aero_atc/Aircraft Range', 'DataFormat', 'StructureWithTime');
    
    for i = 1:numiter
        rainfall = rainfallVec(i);
        Rrange = RrangeVec(i);
        initFcn = ['aero_init_atc;rainfall=' num2str(rainfall) ...
                   ';Rrange=' num2str(Rrange) ';'];
        set_param('aero_atc', 'InitFcn', initFcn)
        
        % Run the simulation.
        simOutputs = sim('aero_atc', 'ReturnWorkspaceOutputs', 'on');
    
        outRrange = simOutputs.get('outRrange');
        act_Rrange = outRrange.signals.values(:, 1);
        est_Rrange = outRrange.signals.values(:, 2);
        meanRrange(i) = mean(abs(act_Rrange - est_Rrange));
    end
    close_system('aero_atc', 0);
end % End of pctdemo_task_aero_atc.
