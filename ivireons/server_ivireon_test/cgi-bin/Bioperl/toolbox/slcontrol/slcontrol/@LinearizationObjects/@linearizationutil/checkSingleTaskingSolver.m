function checkSingleTaskingSolver(this,model)
% CHECKMULTITASKINGSOLVER  Checks to see if a model is using a multi-tasking
% solver.
%
 
% Author(s): John W. Glass 04-Aug-2006
% Copyright 2006-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/31 07:34:25 $

IsFixedStep = strcmp(get_param(model,'SolverType'),'Fixed-step');

% If the model is in fixed-step mode, check to be sure that multitasking
% will not be required.
if IsFixedStep
    modelSolverMode = get_param(model,'SolverMode');
    if strcmp(modelSolverMode,'Auto') || strcmp(modelSolverMode,'MultiTasking')
        %% Get the sample times of the model
        [sizes,x0,str,ts] = feval(model,[],[],[],'sizes');  %#ok
        %% Remove the continuous sample time if there is one.
        ts(find(ts(:,1) == 0),:) = [];          %#ok
        if size(ts,1) > 1
            ctrlMsgUtils.error('Slcontrol:linutil:SingleTaskingSolverRequired')
        end
    end
end