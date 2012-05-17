function singletasking = checkSingleTaskingSolver(models, varargin)
% Check to be sure that a single tasking solver is being used in all the
% models.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $

if nargin==2
    isInSFun = varargin{1}; 
else
    isInSFun = false;
end

singletasking = true;

for ct = 1:numel(models)
    modelSolver = get_param(models{ct},'Solver');

    IsFixedStep = any(strcmp(getSolversByParameter('SolverType','Fixed Step'),modelSolver));

    % If the model is in fixed step mode, check to be sure that multitasking
    % will not be required.
    if IsFixedStep
        modelSolverMode = get_param(models{ct},'SolverMode');
        if strcmp(modelSolverMode,'Auto') || strcmp(modelSolverMode,'MultiTasking')
            if (isInSFun)
                %% in S-Function call back, do not compile model
                singletasking = false;
            else
                %% Get the sample times of the model
                [sys,x0,str,ts] = feval(models{ct},[],[],[],'sizes');
                %% Remove the continuous sample time if there is one.
                ts(ts(:,1) == 0,:) = [];
                if size(ts,1) > 1
                    singletasking = false;
                end
            end
        end
    end
end