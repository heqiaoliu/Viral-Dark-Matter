function pctdemo_taskfin_aero_atc(task, varargin)
%PCTDEMO_TASKFIN_AERO_ATC Update graph with task results.
%   A task finished callback function.  Retrieves the output data
%   from the task and adds it to the figure found in the UserData
%   property of the task.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:06:01 $
    
    % If we can collect the task input and output arguments as well as the 
    % task UserData, we can call the plot routine.
    input = task.InputArguments;
    output = task.OutputArguments;
    if isempty(input)
        warning('distcomp:demo:EmptyTaskInput', ...
                'Could not obtain task input arguments');
        return;
    end
    if isempty(output)
        warning('distcomp:demo:EmptyTaskOutput', ...
                'Could not obtain task results');
        return;
    end
    [rainfall, Rrange] = input{:};
    meanRrange = output{1};
    
    sharedData = get(task, 'UserData');
    figHandles = sharedData.figHandles;
    iterations = sharedData.iterations;
    % We get the initialization and update functions from 
    % pctdemo_plot_aero_atc.  The graph has alread been initialized, and now
    % we would like to update it with the new results.
    [setup, update] = pctdemo_plot_aero_atc();
    update(figHandles, iterations, rainfall, Rrange, meanRrange);
end % End of pctdemo_taskfin_aero_atc.
